mongoose = require "mongoose"
{extend} = require "../../lib/utils"


class BaseModel
  @init: (@db) ->
    @schema = mongoose.Schema @config
    extend @schema.statics, @statics if @statics
    extend @schema.methods, @methods if @methods
    @Store = @db.model @name, @schema


module.exports = BaseModel