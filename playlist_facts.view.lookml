- explore: playlist_facts   # for debugging
  hidden: true
  
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
        
    

