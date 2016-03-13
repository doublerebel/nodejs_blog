ErrorHandlers =
  # catch 404 and forward to error handler
  error404: (req, res, next) ->
    err = new Error("Not Found")
    err.status = 404
    next err

  # error handlers
  # development error handler
  # will print stacktrace
  catchAllDev: (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err

  # production error handler
  # no stacktraces leaked to user
  catchAllProd: (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: {}


module.exports = ErrorHandlers
