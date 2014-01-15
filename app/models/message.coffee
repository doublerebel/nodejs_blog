Base = require "./base"


class Message extends Base
  @name: "Message"

  @config:
    name: String
    email: String
    body: String
    date: Date


module.exports = Message
