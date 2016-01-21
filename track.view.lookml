# reusable track definition so we can link to external places from within the model.

- view: track
  fields:
  - dimension: track_id
  - dimension: track_title
    links:
    - label: YouTube
      url: http://www.google.com/search?q=site:youtube.com+{{artist_name._value}}+{{value}}&btnI
      icon_url: http://youtube.com/favicon.ico
    - label: iTunes
      url: http://www.google.com/search?q=itunes.com+{{artist_name._value}}+{{value}}&btnI
