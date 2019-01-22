# for debugging
explore: playlist_facts {
  hidden: yes
}

# Facts about playlists, number of different artists and number of tracks on eacy playlist
#  Used to filter out crappy playlists.

view: playlist_facts {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists] ;;
    max_billing_tier: 3
    sql: SELECT
        id as playlist_id
        , COUNT(DISTINCT tracks.data.artist.id) as num_artists
        , COUNT(DISTINCT tracks.data.id) as num_tracks
      FROM FLATTEN([bigquery-samples:playlists.playlists],tracks.data)
      GROUP BY 1
      HAVING num_artists > 0
       ;;
  }

  dimension: playlist_id {
    hidden: yes
  }

  dimension: num_artists {
    type: number
  }

  dimension: num_tracks {
    type: number
  }
}
