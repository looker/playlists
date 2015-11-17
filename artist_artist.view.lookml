- explore: playlist_artist
- view: playlist_artist
  derived_table:
    sql: |
      SELECT 
        playlists.tracks.data.artist.id AS artist_id,
        playlists.tracks.data.artist.name AS artist_name,
        playlists.id AS playlist_id
      FROM (SELECT * FROM FLATTEN([bigquery-samples:playlists.playlists]
        ,tracks.data)) AS playlists
      WHERE playlists.tracks.data.artist.id IS NOT NULL
      GROUP EACH BY 1,2,3
  fields:
  - dimension: artist_id
  - dimension: artist_name
  - dimension: playlist_id

    
- explore: artist_artist      
- view: artist_artist
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists]
    sql: |
      SELECT
        a.artist_id as artist_id1,
        a.artist_name as artist_name1,
        b.artist_id as artist_id2,
        b.artist_name as artist_name2,
        COUNT(*) as num_playlists
      FROM ${playlist_artist.SQL_TABLE_NAME} AS a
      JOIN EACH ${playlist_artist.SQL_TABLE_NAME} as b 
        ON a.playlist_id = b.playlist_id
      WHERE a.artist_id <> b.artist_id
      GROUP EACH BY 1,2,3,4
  fields:
  - dimension: artist_id1
  - dimension: artist_id2
  - dimension: artist_name1
  - dimension: artist_name2
  - dimension: num_playlists
  
  - measure: total_playlists
    type: sum
    sql: ${num_playlists}
    
  - measure: count
    type: count
    drill_fields: [artist_id1, artist_name2, artist_id2, artist_name2, num_playlists]