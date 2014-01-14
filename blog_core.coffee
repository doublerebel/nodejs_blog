mongoose = require 'mongoose'
crypto   = require 'crypto'
{_}      = require 'underscore'


#UTILS
TrimStr = (str) ->
  return str.replace(/^\s+|\s+$/g,"")


userSchema = mongoose.Schema
  username:
    type: String
    index: unique: true
  password: String
  email:
    type: String
    index: unique: true
  admin: Boolean

postSchema = mongoose.Schema
  urlid:
    type: String
    index: unique: true
  title: String
  body: String
  tags: String
  date: Date

messageSchema = mongoose.Schema
  name: String
  email: String
  body: String
  date: Date

projectSchema = mongoose.Schema
  name: String
  description: String
  project_image_url: String
  website_link: String
  download_link: String
  ios_app_store_link: String
  mac_app_store_link: String
  marketplace_link: String
  google_play_link: String


class Model
  TrimStr: TrimStr

  doDashes: (str) -> str.replace(/[^a-z0-9]+/gi, '-').replace(/^-*|-*$/g, '').toLowerCase()

  constructor: (@config) ->
    @db       = mongoose.createConnection @config.dbUrl
    @ObjectId = (id) -> new mongoose.Types.ObjectId id

    @User     = db.model 'User', userSchema
    @Post     = db.model 'Post', postSchema
    @Message  = db.model 'Message', messageSchema
    @Project  = db.model 'Project', projectSchema

    @User.find {username: 'admin'}, (err, users) =>
      @createDefaultAdminUser() unless err or users.length

  PostsTags: =>
    @Post.find().select('tags').exec (err, tags) ->
      return unless tags

      filtered_tags = for tag in tags when tag.tags
        tag2 for tag2 in (tag.tags.split ',') when (tag2 = (TrimStr tag2).toUpperCase()) and tag2 not in filtered_tags

  createDefaultAdminUser: =>
    pass_crypted = crypto.createHmac("md5", @config.crypto_key).update('admin123').digest("hex")
    gui = new @User
      username: 'admin'
      password: pass_crypted
      email: 'admin@admin.com'
      admin: true

    gui.save (err) ->
      console.log 'Error when try to save admin user' if err


module.exports = Model
