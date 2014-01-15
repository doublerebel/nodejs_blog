exports.login = (req, res) ->
  req.session.userid = null
  res.render 'sessions/new', pageTitle: 'Login', notice: ''

exports.logout = (req, res) ->
  req.session.userid = null
  res.redirect '/'

exports.create_session = (req, res) ->
  Core = require "../models/core"

  await Core.User.authenticateUser req.body.user.username, req.body.user.password, defer user
  unless user instanceof Core.User
    return res.render 'sessions/new', pageTitle: 'Admin', notice: user

  req.session.userid = user._id
  res.redirect '/admin'
