# for debugging.
explore: artist_artist {
  hidden: yes
}

# The core of the recommendaiton engine.  Cross joins playlist_artist to build a list of
#  related artists.
include: "*.view.lkml"

view: artist_artist {
  extends: [artist]

  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists] ;;
    sql: SELECT
        *,
        row_number() OVER (partition by artist2_id order by num_playlists DESC) as closeness_rank
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
       ;;
  }

  # Inherited from 'view: artist'
  dimension: artist_id {}
  dimension: artist_name {}
  dimension: artist2_id {}
  dimension: artist2_name {}

  dimension: num_playlists {
    type: number
  }

  dimension: closeness_rank {
    type: number
  }

  measure: total_playlists {
    type: sum
    sql: ${num_playlists} ;;
  }

  measure: count {
    type: count
    drill_fields: [artist_id, artist_name, artist2_id, artist2_name, num_playlists]
  }
}
