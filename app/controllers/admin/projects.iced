Core  = require "../../models/core"
utils = require "../../../lib/utils"


exports.index = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Project.find().sort('name').exec defer err, projects
  return error err if err

  res.render 'admin/projects/index',
    pageTitle: 'Projects'
    layout:    'admin_layout'
    projects:  projects


exports.new_project = (req,res) ->
  project = new Core.Project()
  res.render 'admin/projects/new',
    pageTitle: 'New Project'
    layout:    'admin_layout'
    project:   project


exports.create_project = (req, res) ->
  newproject = req.body.project
  project    = new Core.Project
    name:               newproject.name
    description:        newproject.description
    project_image_url:  newproject.project_image_url
    download_link:      newproject.download_link
    website_link:       newproject.website_link
    ios_app_store_link: newproject.ios_app_store_link
    mac_app_store_link: newproject.mac_app_store_link
    marketplace_link:   newproject.marketplace_link
    google_play_link:   newproject.google_play_link

  saveError = (err) -> res.render "projects/new",
    pageTitle: "New Project"
    layout: "admin_layout"
    notice: "Error while saving the project: #{err}"

  project.save (err) ->
    return saveError err if err
    res.redirect '/admin/projects'


exports.show_project = (req,res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Project.findOne({_id : Core.ObjectId(req.params.id)}).exec defer err, project
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  res.render 'admin/projects/show',
    pageTitle: 'Project'
    project:   project


exports.edit_project = (req,res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Project.findOne({_id : Core.ObjectId(req.params.id)}).exec defer err, project
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  res.render 'admin/projects/edit',
    pageTitle: 'Edit Project'
    project:   project


exports.update_project = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Project.findOne({_id:Core.ObjectId(req.params.id)}).exec defer err, project
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  newproject = req.body.project
  project.name               = newproject.name
  project.description        = newproject.description
  project.project_image_url  = newproject.project_image_url
  project.download_link      = newproject.download_link
  project.website_link       = newproject.website_link
  project.ios_app_store_link = newproject.ios_app_store_link
  project.mac_app_store_link = newproject.mac_app_store_link
  project.marketplace_link   = newproject.marketplace_link
  project.google_play_link   = newproject.google_play_link

  saveError = (err) -> res.render "admin/projects/edit",
    pageTitle: "Edit Project"
    notice:    "Error while saving the project: #{err}"
    project:   project

  project.save (err) ->
    return saveError err if err
    res.redirect 'admin/projects'


exports.remove_project = (req, res) ->
  error = (err) -> res.render "500", pageTitle: "Error: #{err}"

  await Core.Project.findOne({_id : Core.ObjectId(req.params.id)}).exec defer err, project
  return error err if err
  res.render("404", pageTitle: "Not Found") unless post

  project.remove (err) ->
    res.redirect '/admin/projects' unless err

