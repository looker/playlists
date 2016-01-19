- explore: artist_suggest  # for debugging
  hidden: true

# Simplifed view of the top 5000 artists so we can make resonable suggestions for artists.
   
- view: artist_suggest
  derived_table:
    sql_trigger_value: SELECT COUNT(*) FROM ${playlist_artist.SQL_TABLE_NAME}
    sql: |
      SELECT 
        artist_name
        , COUNT(*)
      FROM ${playlist_artist.SQL_TABLE_NAME}
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 5000
          
  fields:
  - dimension: artist_name
