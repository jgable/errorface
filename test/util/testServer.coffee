express = require "express"
app = express()

init = (configureThis) ->
    app.get "/", (req, res) ->
        res.send "Hello World"

    app.get "/error", (req, res, next) ->
        throw new Error("Some Error")

    app.use (err, req, res, next) ->
        console.log err, err.stack
        next(err)

    configureThis?(app)

    app.listen 3000

stop = ->
    app.close()

module.exports = { init, stop }