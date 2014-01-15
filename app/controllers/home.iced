exports.index = (req, res) ->
  Core = require "../models/core"
  error = (err) -> res.render 'blog/index', pageTitle: "Error: #{err}", posts: []

  await Core.Post.tags defer categories
  return error categories if categories instanceof Error

  await Core.Post.postsByDate 10, defer posts
  return error posts if posts instanceof Error

  res.render 'blog/index',
    pageTitle: 'Blog'
    layout: 'layout'
    categories: categories.sort()
    posts: posts
