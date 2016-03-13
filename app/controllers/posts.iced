exports.show_post = (req, res) ->
  Core  = require "../models/core"
  urlid = req.params.id
  error = (err) -> res.render '500', pageTitle: "Error: #{err}"

  await Core.Post.findOne({urlid: urlid}).exec defer err, post
  return error err if err
  return res.render('404', pageTitle: 'Not Found') unless post

  res.render 'blog/show',
    pageTitle: "#{Core.config.blog_title}-#{post.title}"
    post: post

