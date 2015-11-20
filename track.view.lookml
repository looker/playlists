- view: track
  fields:
  - dimension: track_id
  - dimension: track_title
    links:
    - label: YouTube
      url: http://www.google.com/search?q=site:youtube.com+{{value}}&btnI
    - label: iTunes
      url: http://www.google.com/search?q=itunes.com+{{artist_name._value}}+{{value}}&btnI
