- explore: playlist_facts
- view: playlist_facts
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists]
    sql: |
      SELECT
        id as playlist_id
        , COUNT(DISTINCT tracks.data.artist.id) as num_artists
        , COUNT(DISTINCT tracks.data.id) as num_tracks
      FROM FLATTEN([bigquery-samples:playlists.playlists],tracks.data)
      GROUP BY 1
      HAVING num_artists > 0
  fields:
  - dimension: playlist_id
  - dimension: num_artists
    type: number
  - dimension: num_tracks
    type: number
        
    

- explore: playlist_artist
- view: playlist_artist
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists]
    sql: |
        SELECT 
          playlists.tracks.data.artist.id AS artist_id,
          playlists.tracks.data.artist.name AS artist_name,
          playlists.id AS playlist_id
        FROM (SELECT * FROM FLATTEN([bigquery-samples:playlists.playlists]
          ,tracks.data)) AS playlists
        JOIN ${playlist_facts.SQL_TABLE_NAME} AS playlist_facts 
          ON playlists.id = playlist_facts.playlist_id
        WHERE playlists.tracks.data.artist.id IS NOT NULL
          AND playlist_facts.num_artists < 10  
        GROUP EACH BY 1,2,3
  fields:
  - dimension: artist_id
  - dimension: artist_name
  - dimension: playlist_id

    
- explore: recommender
  view: artist_artist
  always_filter:
    track_rank.rank_within_artist: <= 3
  joins:
  - join: track_rank
    sql_on: ${artist_artist.artist2_id} = ${track_rank.artist_id}
    relationship: one_to_many
    type: left_outer_each
    
- explore: artist_artist    
- view: artist_artist
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists]
    sql: |
      SELECT 
        *,
        row_number() OVER (partition by artist_id order by num_playlists DESC) as closeness_rank
      FROM (
        SELECT
          a.artist_id as artist_id,
          a.artist_name as artist_name,
          b.artist_id as artist2_id,
          b.artist_name as artist2_name,
          COUNT(*) as num_playlists
        FROM ${playlist_artist.SQL_TABLE_NAME} AS a
        JOIN EACH ${playlist_artist.SQL_TABLE_NAME} as b 
          ON a.playlist_id = b.playlist_id
        WHERE a.artist_id <> b.artist_id
        GROUP EACH BY 1,2,3,4
      )
  fields:
  - dimension: artist_id
  - dimension: artist_name
  - dimension: artist2_id
  - dimension: artist2_name
  - dimension: num_playlists
    type: int
  - dimension: closeness_rank
    type: int
  
  - measure: total_playlists
    type: sum
    sql: ${num_playlists}
    
  - measure: count
    type: count
    drill_fields: [artist_id1, artist_name2, artist_id2, artist_name2, num_playlists]