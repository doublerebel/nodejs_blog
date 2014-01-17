path    = require 'path'
express = require 'express'
ghm     = require 'marked'
moment  = require 'moment'
gzippo  = require 'gzippo'
i18n    = require 'i18n'
utils   = require './lib/utils'


class Blog
  constructor: (options = {}) ->
    @Core = (require "./app/models/core").init options.config
    @app  = options.app or express()
    @port = process.env.PORT or options.port or 3000

    @initLocale()
    @initMiddleware()

  start: ->
    @app.listen @port
    console.log "Server running at http://0.0.0.0:#{@port}/"

  initLocale: ->
    i18n.configure
      #setup some locales - other locales default to en silently
      locales:['pt-br', 'en']
      #where to register __() and __n() to, might be "global" if you know what you are doing
      register: global

    #SET SYSTEM LANGUAGE
    i18n.setLocale @Core.config.locale
    moment.lang @Core.config.locale

  initMiddleware: ->
    # NODEJS MIDDLEWARES
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use express.cookieParser()

    theme_dir  = @findTheme @Core.config.theme
    assets_dir = path.join theme_dir, "assets"
    @app.use (require 'connect-assets')(src: assets_dir)
    @app.use express.static './public'

    @app.use express.responseTime()

    views_dir = path.join theme_dir, "views"
    @app.set 'views', views_dir
    @app.set 'view engine', 'jade'
    @app.set 'view options', pretty: true

    @app.use gzippo.compress()

    MemStore = express.session.MemoryStore
    @app.use express.session
      secret: @Core.config.crypto_key
      store: MemStore reapInterval: 60000 * 10

    @app.configure 'production', =>
      oneYear = 86400
      @app.use express.static (path.join __dirname, '/public'), maxAge: oneYear
      @app.use express.errorHandler()

    @app.use @localMiddleware
    @app.use @app.router
    @Routes = (require "./app/controllers/routes").init @app

  findTheme: (theme) =>
    subfolder = path.join "themes", theme
    if      local    = path.join process.cwd(), subfolder then local
    else if included = path.join "./", subfolder          then included
    else throw new Error "theme #{@Core.config.theme} not found"

  currentUser: (req, res, callback) =>
    return unless req.session?.userid
    @Core.User.findOne {_id: (@Core.ObjectId req.session.userid)}, callback

  localMiddleware: (req, res, next) =>
    res.locals.req         = req
    res.locals.session     = -> req.session if req.session?
    res.locals.token       = -> req.session._csrf if req.session?._csrf
    res.locals.css         = css
    res.locals.js          = js
    res.locals.currentUser = @currentUser
    res.locals.notice      = false
    res.locals.md          = ghm
    res.locals.moment      = moment
    res.locals.TrimStr     = utils.trim
    res.locals.pageTitle   = @Core.config.blog_title
    res.locals.config      = @Core.config
    res.locals.__i         = i18n.__
    res.locals.__n         = i18n.__n
    next()


module.exports = Blog
