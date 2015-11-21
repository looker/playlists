# Base definition for artist
#  Declares external links

- view: artist
  fields:
  - dimension: artist_id
  - dimension: artist_name
    links:
    - label: YouTube
      url: http://www.google.com/search?q=site:youtube.com+{{value}}&btnI
      icon_url: http://youtube.com/favicon.ico
    - label: Wikipedia
      url: http://www.google.com/search?q=site:wikipedia.com+{{value}}&btnI
      icon_url: https://en.wikipedia.org/static/favicon/wikipedia.ico
    - label: Twitter
      url: http://www.google.com/search?q=site:twitter.com+{{value}}&btnI
      icon_url: https://abs.twimg.com/favicons/favicon.ico
    - label: Facebook
      url: http://www.google.com/search?q=site:facebook.com+{{value}}&btnI
      icon_url: https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico
