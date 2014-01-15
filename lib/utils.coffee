utils =
  trim: (str) -> str.replace /^\s+|\s+$/g, ""

  doDashes: (str) -> str.replace(/[^a-z0-9]+/gi, '-').replace(/^-*|-*$/g, '').toLowerCase()

  extend: (target, sources...) ->
    target[key] = val for key, val of source for source in sources
    target


module.exports = utils