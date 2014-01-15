exports.index = (req, res) ->
  res.render 'contact/index', pageTitle: 'Contact'

exports.new_message = (req, res) ->
  Core    = require "../models/core"
  name    = req.body.name
  email   = req.body.email
  body    = req.body.message
  message = new Core.Message
    name: name
    email: email
    body: body
    date: new Date()

  await message.save defer err
  return res.send(500, error: err) if err

  res.json ['OK']
