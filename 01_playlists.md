# Data Hacking a Shitty Pandora

I love Pandora.  Type in an artists name and it starts playing similar stuff.  Pandora is pretty magic.

BigQuery provides a sample data set of some playlist data.  The data is pretty simple, there is, essentially, a row for each track in the playlist.  BigQuery provides nested data, so tracks are embedded in playlist objects in the table.  

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



