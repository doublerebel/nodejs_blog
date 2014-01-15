crypto = require "crypto"
Base   = require "./base"


class User extends Base
  @name: "User"

  @config:
    username:
      type: String
      index:
        unique: true
    password: String
    email:
      type: String
      index:
        unique: true
    admin: Boolean

  @statics:
    createDefaultAdmin: (key = @key) =>
      pass_crypted = crypto.createHmac("md5", key).update("admin123").digest("hex")
      store = new @Store
        username: "admin"
        password: pass_crypted
        email: "admin@admin.com"
        admin: true

      store.save (err) ->
        console.log "Error when try to save admin user" if err

    authenticateUser: (user, pass, autocb) =>
      await @Store.findOne {username: user}, defer err, user
      return err if err
      return "User not found" unless user

      pass_crypted = crypto.createHmac("md5", @key).update(pass).digest("hex")
      return "Invalid user or password" unless pass_crypted is user.password
      user



module.exports = User
