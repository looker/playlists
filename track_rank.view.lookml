- view: track_rank
  derived_table:
    sql: |
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
        WHERE playlists.tracks.data.artist.id IS NOT NULL
          AND playlists.tracks.data.title IS NOT NULL
        GROUP EACH BY 1,2
      )
      
  fields:
  - dimension: track_id
    hidden: true
    primary_key: true
    type: int
    sql: ${TABLE}.track_id

  - dimension: artist_id
    type: int
    hidden: true
    sql: ${TABLE}.artist_id

  - dimension: rank_within_artist
    view_label: Track
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
