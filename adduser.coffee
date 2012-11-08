crypto = require 'crypto'
core   = require './blog_core'
config = require './config'

username = 'newuser'
password = 'newpassword'
pass_crypted = (crypto.createHmac "md5", config.crypto_key).update(password).digest("hex")

user = new core.User
  username: username
  password: pass_crypted
  email: 'charles@doublerebel.com'
  admin: true

user.save (err) -> console.log err

core.User.findOne {username : username}, (err, user2) ->
  console.log user2.email
  console.log user2.username
  console.log user2.password
  console.log user2.admin
  (console.log err) if err

console.log 'completed processing calls'
