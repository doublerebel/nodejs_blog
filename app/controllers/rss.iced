exports.index = (req, res) ->
  RSS   = require "rss"
  Core  = require "../models/core"
  error = (err) -> res.render '500', pageTitle: "Error: #{err}"
  feed  = new RSS
    title: core.config.blog_title
    description: core.config.blog_description
    feed_url: core.config.feed_url
    site_url: core.config.site_url
    image_url: core.config.site_image_url
    author: core.config.site_author

  await Core.Post.find().exec defer err, posts
  return error err if err

  posts.map (post) -> feed.item
    title: post.title
    url:   "#{core.config.site_url}/#{post.urlid}"

  res.contentType "rss"
  res.send feed.xml()
