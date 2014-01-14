path    = require 'path'
express = require 'express'
ghm     = require 'marked'
moment  = require 'moment'
gzippo  = require 'gzippo'
{_}     = require 'underscore'
i18n    = require 'i18n'
Core    = require './blog_core'


class Blog
  constructor: (options = {}) ->
    config = require options.config
    @core  = new Core config
    @app   = options.app or express()
    @port  = process.env.PORT or 3000

    @initLocale()
    @initMiddleware()

  start: ->
    @app.listen @port
    console.log "Server running at http://0.0.0.0:#{@port}/"

  initLocale: ->
    i18n.configure
      #setup some locales - other locales default to en silently
      locales:['pt-br', 'en'],
      #where to register __() and __n() to, might be "global" if you know what you are doing
      register: global

    #SET SYSTEM LANGUAGE
    i18n.setLocale @core.config.locale
    moment.lang @core.config.locale

  initMiddleware: ->
    # NODEJS MIDDLEWARES
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use express.cookieParser()

    assets_dir = path.join "./themes", @core.config.theme, "assets"
    @app.use (require 'connect-assets')(src: assets_dir)
    @app.use express.static './public'

    @app.use express.responseTime()

    views_dir = path.join "./themes", @core.config.theme, "views"
    @app.set 'views', views_dir
    @app.set 'view engine', 'jade'
    @app.set 'view options', pretty: true

    @app.use gzippo.compress()

    MemStore = express.session.MemoryStore
    @app.use express.session
      secret: @core.config.crypto_key
      store: MemStore reapInterval: 60000 * 10

    @app.configure 'production', =>
      oneYear = 86400
      @app.use express.static (path.join __dirname, '/public'), maxAge: oneYear
      @app.use express.errorHandler()

    @app.use @localMiddleware
    @app.use @app.router
    routes = (require './routes')(@app)

  currentUser: (req, res, callback) =>
    return unless req.session?.userid
    @core.User.findOne {_id: (@core.ObjectId req.session.userid)}, callback

  localMiddleware: (req, res, next) ->
    res.locals.req         = req
    res.locals.session     = -> req.session if req.session?
    res.locals.token       = -> req.session._csrf if req.session?._csrf
    res.locals.currentUser = @currentUser
    res.locals.notice      = false
    res.locals.md          = ghm
    res.locals.moment      = moment
    res.locals.TrimStr     = @core.TrimStr
    res.locals.pageTitle   = @core.config.blog_title
    res.locals.config      = @core.config
    res.locals.__i         = i18n.__
    res.locals.__n         = i18n.__n
    next()


module.exports = Blog
