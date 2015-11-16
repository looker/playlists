- view: playlists
  sql_table_name: |
      [bigquery-samples:playlists.playlists]

  fields:
  - measure: count
    type: count_distinct
    sql: ${playlist_id}
    drill_fields: [playlist_id]
    
  - dimension: rating
    type: int
    sql: ${TABLE}.rating

  - dimension: playlist_id
    type: int
    sql: ${TABLE}.id

  - dimension: artist_id
    view_label: Artist
    type: int
    sql: ${TABLE}.tracks.data.artist.id
    fanout_on: tracks.data

  - dimension: artist_name
    view_label: Artist
    type: string
    sql: ${TABLE}.tracks.data.artist.name
    fanout_on: tracks.data
    
  - measure: artist_count
    type: count_distinct
    sql: ${artist_id}
    drill_fields: [artist_id, artist_name, count, 
      track_count, track_instance_count, album_count]

  - dimension: album_id
    view_label: Album
    type: int
    sql: ${TABLE}.tracks.data.album.id
    fanout_on: tracks.data

  - dimension: album_title
    view_label: Album
    type: string
    sql: ${TABLE}.tracks.data.album.title
    fanout_on: tracks.data

  - measure: album_count
    type: count_distinct
    sql: ${album_id}
    drill_fields: [album_id, album_title, count, track_count, artist_count]

  - dimension: track_title
    view_label: Track
    type: string
    sql: ${TABLE}.tracks.data.title
    fanout_on: tracks.data

  - dimension: track_id
    view_label: Track
    type: int
    sql: ${TABLE}.tracks.data.id
    fanout_on: tracks.data
    
  - measure: track_count
    type: count_distinct
    sql: ${track_id}
    drill_fields: [track_id, track_title, count]

  - measure: track_instance_count
    type: count_distinct
    sql: CONCAT(CAST(${track_id} AS STRING),CAST(${playlist_id} AS STRING))
    drill_fields: detail

  sets:
    detail:
    - playlist_id
    - artist_name
    - album_title
    - track_title

      
   