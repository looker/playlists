connection: "lookerdata_publicdata"

include: "*.view"

case_sensitive: no

persist_for: "10000 hours"

explore: playlists {
  hidden: yes

  join: playlist_facts {
    sql_on: ${playlists.playlist_id} = ${playlist_facts.playlist_id} ;;
    relationship: one_to_one
    view_label: "Playlists"
  }

  join: track_rank {
    sql_on: ${playlists.track_id} = ${track_rank.track_id} ;;
    relationship: one_to_one
    type: left_outer_each
    view_label: "Track"
    fields: [track_id, overall_rank, rank_within_artist]
  }
}

explore: recommender {
  view_name: artist_artist

  always_filter: {
    filters: {
      field: track_rank.rank_within_artist
      value: "<= 3"
    }
  }

  join: track_rank {
    sql_on: ${artist_artist.artist_id} = ${track_rank.artist_id} ;;
    relationship: one_to_many
    type: left_outer_each
  }
}
