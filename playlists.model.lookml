- connection: bigquery_publicdata

- include: "*.view.lookml"

- explore: playlists
  hidden: true
  joins:
  - join: track_rank
    sql_on: ${playlists.track_id} = ${track_rank.track_id}
    relationship: one_to_one
    type: left_outer_each
    view_label: Track
    fields: [track_id, overal_rank, rank_within_artist]
    
  - join: playlist_facts
    sql_on: ${playlists.playlist_id} = ${playlist_facts.playlist_id}
    relationship: one_to_one
    view_label: Playlists
    
    
    
- explore: recommender
  view: artist_artist
  always_filter:
    track_rank.rank_within_artist: <= 3
  joins:
  - join: track_rank
    sql_on: ${artist_artist.artist2_id} = ${track_rank.artist_id}
    relationship: one_to_many
    type: left_outer_each
    