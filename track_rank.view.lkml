# for debugging
explore: track_rank {
  hidden: yes
}

# Rank tracks both overall and within a given artist.
include: "*.view.lkml"
view: track_rank {
  extends: [track]

  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM [bigquery-samples:playlists.playlists] ;;
    max_billing_tier: 3
    sql: SELECT
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
       ;;
  }

  dimension: track_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.track_id ;;
  }

  dimension: track_title {
    sql: ${TABLE}.track_title ;;
  }

  dimension: artist_id {
    type: number
    sql: ${TABLE}.artist_id ;;
  }

  dimension: artist_name {
    type: number
    sql: ${TABLE}.artist_name ;;
  }

  dimension: rank_within_artist {
    type: number
    sql: ${TABLE}.artist_rank ;;
  }

  dimension: overall_rank {
    view_label: "Track"
    type: number
    sql: ${TABLE}.overall_rank ;;
  }

  set: detail {
    fields: [track_id, artist_id, rank_within_artist, overall_rank]
  }
}
