mongoose = require "mongoose"


class Core
  @ObjectId: (id) -> new mongoose.Types.ObjectId id

  @init: (@config) ->
    Message  = require "./message"
    Post     = require "./post"
    Project  = require "./project"
    User     = require "./user"

    User.key = @config.crypto_key
    @db      = mongoose.createConnection @config.dbUrl

    for Model in [Message, Post, Project, User]
      @[Model.name] = Model.init @db

    @User.find {username: "admin"}, (err, users) =>
      @User.createDefaultAdmin() unless err or users.length

    this


module.exports = Core
