express = require "express"
fs = require "fs"
app = express()
errorface = require "../.."

init = (configureThis) ->
    app.get "/", (req, res) ->
        res.send "Hello World"

    app.get "/error", (req, res, next) ->
        app.doesntExist()

    app.get "/*", (req, res) ->
        throw new Error("Not Found")

    app.use errorface.errorHandler

    configureThis?(app)

    app.listen 3000

stop = ->
    app.close()

module.exports = { init, stop }