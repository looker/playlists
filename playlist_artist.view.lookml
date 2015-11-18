- explore: playlist_artist  # for debugging.
  hidden: true
  
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

