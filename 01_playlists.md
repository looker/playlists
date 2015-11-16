# Data Hacking: Coding up a Shitty Pandora

I love Pandora.  Type in an artists name and it starts playing similar stuff.  Pandora's recomendation engine feels like magic.

BigQuery provides a sample data set of some playlist data.  The data is pretty simple, there is, essentially, a row for each track in the playlist.  BigQuery provides nested data, so tracks are embedded in playlist objects in the table.  

Using this data, we are going to build a rudimentary recommendation engine in LookML.

## Step 1: Building out a Simple Model

The table structure is as follows:

### Table: Playlists
<img src="https://discourse.looker.com/uploads/default/original/2X/c/c549f9f91a9dd1fff6e01af0ef5a37e07d72af2f.png" width="433" height="390">

## Simple LookML model

First step is to build out a LookML model.  For each field in the table, we build out a dimension.  We label each 'object' (things that would be in their own table in a de-normalized schema).  For example, tracks.data.artist.id becomes 'artist_id'.  

```
  - dimension: artist_id
    view_label: Artist
    type: int
    sql: ${TABLE}.tracks.data.artist.id
    fanout_on: tracks.data
```

For each object, we also build a count.  To count artists, we want to count the distinct values of artist_id.  When drilling into an artist count, we want the artist's id, name and the other counts.

```
  - measure: artist_count
    type: count_distinct
    sql: ${artist_id}
    drill_fields: [artist_id, artist_name, count, track_count,
      track_instance_count, album_count]
```

>**[See the complete model](https://learn.looker.com/projects/playlists/files/playlists.view.lookml)**

## Learning about the Data Set

Looks like there are about 500K playlist, with a total of about 12M tracks.  92K-ish different artists, with about 900K individual songs.

<look>
  model: playlists
  explore: playlists
  measures: [playlists.album_count, playlists.artist_count, playlists.count, playlists.track_count,
    playlists.track_instance_count]
  sorts: [playlists.album_count desc]
  limit: 500
</look>

### Who is the Top Artist (in this data set?)

Of course, it depends on how you count it.  Which artist has the most instances of songs on playlists?  Looks like *Linkin Park*.  The really fun part of this is that **clicking any number, takes you to the album, track or artist**.

<look height="300">
  model: playlists
  explore: playlists
  dimensions: [playlists.artist_name, playlists.artist_id]
  measures: [playlists.album_count, playlists.count, playlists.track_count, playlists.track_instance_count]
  sorts: [playlists.track_instance_count desc]
  limit: 500
</look>

Maybe we should measure artist success by appearence on a playlist?  Looks like *Rhiana* is top.

<look height="300">
  model: playlists
  explore: playlists
  dimensions: [playlists.artist_name, playlists.artist_id]
  measures: [playlists.album_count, playlists.count, playlists.track_count, playlists.track_instance_count]
  sorts: [playlists.count desc]
  limit: 500
</look>

## Step 2: Building out Facts about what is popular.

We need to rank tracks (songs) in their overall popularity and their popularity within an artist.  We'd like to end up with a table like:

<table>
<tr><th>track_id</th><th>artist_id</th><th>overall_rank</th><th>artist_rank
</th></tr></table>

We can do this with a relatively simple 2 level query.  The first level, groups by track_id and artist_id and counts the number of playlists the song appears on.  The second level (using [window functions](http://www.looker.com/blog/a-window-into-the-soul-of-your-data)), calculates the overall rank of the song and the rank within (partitioned by), the artist.

```
 SELECT
    track_id
    , artist_id
    , row_number() OVER( PARTITION BY artist_id ORDER BY num_plays DESC) as artist_rank
    , row_number() OVER( ORDER BY num_plays DESC) as overal_rank
  FROM (
    SELECT 
      playlists.tracks.data.id AS track_id,
      playlists.tracks.data.artist.id AS artist_id,
      COUNT(*) as num_plays
    FROM (SELECT * FROM FLATTEN([bigquery-samples:playlists.playlists]
      ,tracks.data)) AS playlists
    GROUP EACH BY 1,2
  )
```

We build this into a derived table and add a couple of dimensions ([see the full code](https://learn.looker.com/projects/playlists/files/track_rank.view.lookml)):


```
  - dimension: rank_within_artist
    view_label: Track
    type: int
    sql: ${TABLE}.artist_rank

  - dimension: overal_rank
    view_label: Track
    type: int
    sql: ${TABLE}.overal_rank
```

### Top 40 Songs

With these new rankings we can now see the top 40 songs on our playlists.

<look height="300">
  model: playlists
  explore: playlists
  dimensions: [playlists.artist_id, playlists.artist_name, playlists.track_id, playlists.track_title,
    track_rank.overal_rank]
  measures: [playlists.track_instance_count, playlists.count]
  filters:
    track_rank.overal_rank: to 41
  sorts: [track_rank.overal_rank]
  limit: 500
</look>

Next, look at rank the songs within an artist.  We'd like more popular songs to have lower numbers. We've already computed rank_with_artist, let's look at Frank Sinatra's and Joan Baez's top three songs.  Notice the data problem, there are two 'Frank Sinatra's.

<look>
  model: playlists
  explore: playlists
  dimensions: [playlists.artist_id, playlists.artist_name, playlists.track_id, playlists.track_title,
    track_rank.rank_within_artist]
  measures: [playlists.track_instance_count, playlists.count]
  filters:
    playlists.artist_name: '"Frank Sinatra","Joan Baez"'
    track_rank.rank_within_artist: to 3
  sorts: [playlists.artist_name desc]
  limit: 500
  column_limit: 50
</look>


## Step 3: Finding Artists that Appear Together.

We're going to first build our shitty recommedation engine by simply looking at artists that appear together on playlists.  SQL's cross join (cross product) will allow us to build a mapping table that looks like:

<table>
<tr><th>playlist_id</th><th>artist_id</th><th>artist_id2</th>
</th></tr></table>

