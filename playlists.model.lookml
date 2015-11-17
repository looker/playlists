- connection: bigquery_publicdata

- include: "*.view.lookml"

- explore: playlists
  hidden: true
  joins:
  - join: track_rank
    sql_on: ${playlists.track_id} = ${track_rank.track_id}
    relationship: one_to_one
    type: left_outer_each