- explore: track_rank # for debugging
  hidden: true
   
- view: track_rank
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists]
    sql: |
      SELECT
        track_id
        , track_title 
        , artist_id
        , row_number() OVER( PARTITION BY artist_id ORDER BY num_plays DESC) as artist_rank
        , row_number() OVER( ORDER BY num_plays DESC) as overal_rank
      FROM (
        SELECT 
          playlists.tracks.data.id AS track_id,
          playlists.tracks.data.title AS track_title,
          playlists.tracks.data.artist.id AS artist_id,
          COUNT(*) as num_plays
        FROM (SELECT * FROM FLATTEN([bigquery-samples:playlists.playlists]
          ,tracks.data)) AS playlists
        WHERE playlists.tracks.data.artist.id IS NOT NULL
          AND playlists.tracks.data.title IS NOT NULL
        GROUP EACH BY 1,2,3
      )
      
  fields:
  - dimension: track_id
    primary_key: true
    hidden: true
    type: int
    sql: ${TABLE}.track_id

  - dimension: track_title
    sql: ${TABLE}.track_title

  - dimension: artist_id
    type: int
    sql: ${TABLE}.artist_id
    
  - dimension: rank_within_artist
    type: int
    sql: ${TABLE}.artist_rank

  - dimension: overal_rank
    view_label: Track
    type: int
    sql: ${TABLE}.overal_rank

  sets:
    detail:
      - track_id
      - artist_id
      - artist_rank
      - overal_rank
      