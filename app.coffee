http          = require "http"
path          = require "path"

express       = require "express"
assets        = require "connect-assets"
bodyParser    = require "body-parser"
compression   = require "compression"
favicon       = require "serve-favicon"
override      = require "method-override"
responseTime  = require "response-time"
session       = require "express-session"

Flannel       = require "flannel"
Consul        = require "consul"
ErrorHandlers = require "./app/controllers/error-handlers"


ghm     = require 'marked'
moment  = require 'moment'
i18n    = require 'i18n'
utils   = require './lib/utils'


class Blog
  logPrefix: "(Blog)"
  port: 3000

  constructor: (options = {}) ->
    Flannel.init Console: level: "debug" unless Flannel.winston
    Flannel.shirt this
    @debug "initializing"

    @address = process.env.OPTIK_PRIVATE_IP
    @port    = process.env.PORT or options.port or @port
    @app     = options.app or express()

    @Core    = (require "./app/models/core").init options.config

    @initMiddleware()

    @bindRoutes()
    @handleRouteErrors()

  initLocale: ->
    i18n.configure
      #setup some locales - other locales default to en silently
      locales:['pt-br', 'en']

    #SET SYSTEM LANGUAGE
    i18n.setLocale @Core.config.locale
    moment.locale @Core.config.locale

  initMiddleware: ->
    @debug "loading middleware"
    # method-override must come before any middleware that relies on METHOD
    @app.use override()

    @initLocale()
    theme_dir   = @findTheme @Core.config.theme
    subdirs     = ["assets/js", "assets/fonts", "assets/css", "assets/img"]
    assets_dirs = (path.join theme_dir, subdir for subdir in subdirs)
    @app.use assets paths: assets_dirs

    @app.use responseTime()

    views_dir = path.join theme_dir, "views"
    @app.set 'views', views_dir
    @app.set 'view engine', 'jade'
    @app.set 'view options', pretty: true

    MemStore = session.MemoryStore
    @app.use session
      secret: @Core.config.crypto_key
      store: MemStore reapInterval: 60000 * 10
      resave: false
      saveUninitialized: false

    if (@app.get "env") is "development"
      @app.use express.static './public'
      # @app.use errorHandler()
    else
      oneYear = 86400
      @app.use express.static (path.join __dirname, '/public'), maxAge: oneYear

    # uncomment after placing your favicon in /public
    # @app.use favicon path.join __dirname, "public", "favicon.ico"
    @app.use Flannel.morgan " info"
    @app.use compression()
    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded extended: true
    @app.use express.static path.join __dirname, "../", "public"


  localMiddleware: (req, res, next) =>
    res.locals.req         = req
    res.locals.session     = -> req.session if req.session?
    res.locals.token       = -> req.session._csrf if req.session?._csrf
    res.locals.currentUser = @currentUser
    res.locals.notice      = false
    res.locals.md          = ghm
    res.locals.moment      = moment
    res.locals.TrimStr     = utils.trim
    res.locals.pageTitle   = @Core.config.blog_title
    res.locals.config      = @Core.config
    res.locals.__          = i18n.__
    res.locals.__n         = i18n.__n
    next()

  bindRoutes: ->
    @debug "loading routes"
    @app.use @localMiddleware
    @Routes = (require "./app/controllers/routes").init @app, @Core

  handleRouteErrors: ->
    @app.use ErrorHandlers.error404
    @app.use ErrorHandlers.catchAllDev if (@app.get "env") is "development"
    @app.use ErrorHandlers.catchAllProd

  listen: (port = @port) ->
    @server = http.createServer @app
    @server.listen port
    @server.on "error", @error
    @server.on "listening", @listening

  error: (error) ->
    throw error if error.syscall isnt "listen"

    bind = if typeof @port is "string" then "Pipe #{@port}" else "Port #{@port}"

    # handle specific listen errors with friendly messages
    switch error.code
      when "EACCES"
        console.error "#{bind} requires elevated privileges"
        process.exit 1
      when "EADDRINUSE"
        console.error "#{bind} is already in use"
        process.exit 1
      else
        throw error

  listening: => @info "listening on #{@server.address().port}"

  register: (callback) ->
    @debug "registering with Consul"

    consul = new Consul host: process.env.OPTIK_ADMIN_IP
    website =
      name: "nextorig.in-website"
      id: "nextorigin-website"
      tags: ["urlprefix-nextorig.in/"]
      address: @address
      port: @port
      check:
        http: "http://#{@address}:#{@port}/"
        interval: "10s"
        timeout: "2s"

    consul.agent.service.register website, callback

  findTheme: (theme) =>
    subfolder = path.join "themes", theme
    if      local    = path.join process.cwd(), subfolder then local
    else if included = path.join "./", subfolder          then included
    else throw new Error "theme #{@Core.config.theme} not found"

  currentUser: (req, res, callback) =>
    return unless req.session?.userid
    @Core.User.findOne {_id: (@Core.ObjectId req.session.userid)}, callback



module.exports = Blog
