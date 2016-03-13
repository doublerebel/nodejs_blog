#!/usr/bin/iced

crypto = require "crypto"
Core   = require "guilherme-blog/app/models/core"
config = require "./config"
{log}  = console

username = ""
password = ""
pass_crypted = (crypto.createHmac "md5", config.crypto_key).update(password).digest("hex")

Core.init require "./config"
user = new Core.User
  username: username
  password: pass_crypted
  email: "email@domain.com"
  admin: true

await user.save defer err
if err
  log "unable to save user"
  log err
  process.exit 1

await Core.User.findOne {username : username}, defer err, user2
log user2.email
log user2.username
log user2.password
log user2.admin
(log err) if err

log "completed processing calls"
process.exit 0