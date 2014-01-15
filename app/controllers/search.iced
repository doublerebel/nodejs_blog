exports.index = (req, res) ->
  Core    = require "../models/core"
  tag     = req.query["tag"]
  keyword = req.query["q"]
  error   = (err) -> res.render '500', pageTitle: "Error: #{err}"

  if tag then await Core.Post.postsByTag tag defer posts
  else        await Core.Post.postsByKeyword keyword defer posts
  return error posts if posts instanceof Error

  res.render 'blog/search',
    pageTitle: 'Search'
    posts: posts
