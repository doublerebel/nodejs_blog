Core  = require "../../models/core"
utils = require "../../../lib/utils"


exports.index = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Post.find().sort("-date").exec defer err, posts
  return error err if err

  res.render "admin/posts/index",
    pageTitle: "Posts"
    layout:    "admin_layout"
    posts:     posts


exports.new_post = (req, res) ->
  post = new Core.Post()
  res.render "posts/new",
    pageTitle: "New Post"
    layout:    "admin_layout"
    post:      post


exports.create_post = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"
  {title, body, tags} = req.body.post
  urlid = utils.doDashes title

  await Core.Post.findOne(urlid: urlid).exec defer err, post
  return error err if err
  urlid += "-#{moment().format "DD-MM-YYYY-HH:mm"}" if post

  post = new Core.Post
    title: title
    body:  body
    urlid: urlid
    tags:  tags
    date:  new Date()

  saveError = (err) -> res.render "posts/new",
    pageTitle: "New Post"
    layout: "admin_layout"
    notice: "Error while saving the post: #{err}"

  post.save (err) ->
    return saveError err if err
    res.redirect "/admin/posts"


exports.show_post = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Post.findOne({_id : Core.ObjectId(req.params.id)}).exec defer err, post
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

    res.render "admin/posts/show",
      pageTitle: "New Post"
      layout: "admin_layout"
      post:post


exports.edit_post = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Post.findOne({_id : Core.ObjectId(req.params.id)}).exec defer err, post
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  res.render "posts/edit",
    pageTitle: "New Post"
    layout: "admin_layout"
    post:post


exports.update_post = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"
  {title, body, tags} = req.body.post
  urlid = utils.doDashes title

  await Core.Post.findOne(_id: (Core.ObjectId req.params.id)).exec defer err, post
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  saveError = (err) -> res.render "posts/new",
    pageTitle: "New Post"
    layout: "admin_layout"
    notice: "Error while saving the post: #{err}"
    post: post

  post.title = title
  post.body  = body
  post.tags  = tags
  post.urlid = urlid
  post.save (err) ->
    return saveError err if err
    res.redirect "/admin/posts"


exports.remove_post = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Post.findOne({_id : Core.ObjectId(req.params.id)}).exec defer err, post
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  post.remove (err) ->
    res.redirect "/admin/posts" unless err
