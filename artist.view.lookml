# Base definition for artist
#  Declares external links

- view: artist
  fields:
  - dimension: artist_id
  - dimension: artist_name
    links:
    - label: Google Play
      url: http://www.google.com/search?q=site:play.gooogle.com+{{value}}&btnI
    - label: YouTube
      url: http://www.google.com/search?q=site:youtube.com+{{value}}&btnI
    - label: Wikipedia
      url: http://www.google.com/search?q=site:wikipedia.com+{{value}}&btnI
    - label: Twitter
      url: http://www.google.com/search?q=site:twitter.com+{{value}}&btnI
    - label: Facebook
      url: http://www.google.com/search?q=site:facebook.com+{{value}}&btnI      