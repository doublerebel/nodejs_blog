exports.index = (req, res) ->
  Core  = require "../../models/core"
  error = (err) -> res.render '500', pageTitle: "Error: #{err}"

  await Core.Message.find().exec defer err, messages
  return error messages if messages instanceof Error

  res.render 'admin/messages/index',
  	layout:   'admin_layout'
  	messages: messages