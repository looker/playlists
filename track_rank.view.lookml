- explore: track_rank # for debugging
  hidden: true
   
# Rank tracks both overall and within a given artist.   
   
- view: track_rank
  extends: track
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists]
    sql: |
      SELECT
        track_id
        , track_title 
        , artist_id
        , artist_name
        , row_number() OVER( PARTITION BY artist_id ORDER BY num_plays DESC) as artist_rank
        , row_number() OVER( ORDER BY num_plays DESC) as overall_rank
      FROM (
        SELECT 
          playlists.tracks.data.id AS track_id,
          playlists.tracks.data.title AS track_title,
          playlists.tracks.data.artist.id AS artist_id,
          playlists.tracks.data.artist.name AS artist_name,
          COUNT(*) as num_plays
        FROM (SELECT * FROM FLATTEN([bigquery-samples:playlists.playlists]
          ,tracks.data)) AS playlists
        WHERE playlists.tracks.data.artist.id IS NOT NULL
          AND playlists.tracks.data.title IS NOT NULL
        GROUP EACH BY 1,2,3,4
      )
      
  fields:
  - dimension: track_id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.track_id

  - dimension: track_title
    sql: ${TABLE}.track_title

  - dimension: artist_id
    type: number
    sql: ${TABLE}.artist_id
    
  - dimension: artist_name
    type: number
    sql: ${TABLE}.artist_name
    
    
  - dimension: rank_within_artist
    type: number
    sql: ${TABLE}.artist_rank

  - dimension: overall_rank
    view_label: Track
    type: number
    sql: ${TABLE}.overall_rank

  sets:
    detail:
      - track_id
      - artist_id
      - artist_rank
      - overall_rank
      