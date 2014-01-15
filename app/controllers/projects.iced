exports.index = (req, res) ->
  Core  = require "../models/core"
  error = (err) -> res.render '500', pageTitle: "Error: #{err}"

  await Core.Project.find().sort('name').exec defer err, projects
  return error err if err

  res.render 'projects/index',
    pageTitle: 'Projects'
    projects: projects
