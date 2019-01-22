# Base definition for artist
#  Declares external links

view: artist {
  dimension: artist_id {
    primary_key: yes
  }

  dimension: artist_name {
    link: {
      label: "YouTube"
      url: "http://www.google.com/search?q=site:youtube.com+{{value}}&btnI"
      icon_url: "http://youtube.com/favicon.ico"
    }

    link: {
      label: "Wikipedia"
      url: "http://www.google.com/search?q=site:wikipedia.com+{{value}}&btnI"
      icon_url: "https://en.wikipedia.org/static/favicon/wikipedia.ico"
    }

    link: {
      label: "Twitter"
      url: "http://www.google.com/search?q=site:twitter.com+{{value}}&btnI"
      icon_url: "https://abs.twimg.com/favicons/favicon.ico"
    }

    link: {
      label: "Facebook"
      url: "http://www.google.com/search?q=site:facebook.com+{{value}}&btnI"
      icon_url: "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
    }
  }
}
