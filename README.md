&#9785; errorface
=================

[Express](http://expressjs.com) middleware for showing detailed error information when errors happen in your app.

[![Build Status](https://secure.travis-ci.org/jgable/errorface.png)](http://travis-ci.org/jgable/errorface)

## Example

Visit the [example error page](http://jgable.github.com/errorface/example.html) to see it in action.

## Installation

    npm install errorface

## Usage

    express = require "express"
    errorface = require "errorface"

    # Create your express app
    app = express()

    # Register your routes
    app.get "/", (req, res) ->
        res.send "Hello World"
    
    app.get "/error", (req, res, next) ->
        app.doesntExist()
    
    app.get "/*", (req, res) -> throw new Error("Not Found")
    
    # Register the errorHandler middleware after your routes.
    app.use errorface.errorHandler()

    # Start your app
    app.listen 3000

## Advanced Usage

You can extend the middleware with a couple options, here are the defaults:

    # Default options
    options =
        # Output to console.log
        log: console.log
        # We don't output errors to log unless you want to
        logErrors: false
        # We use Mustache to render templates by default
        templateFunc: Mustache.render
        # You can pass a string in as a template
        errorPageTemplate: null
        # Or, you can pass a path to a file to use as the template
        errorPageTemplatePath: __dirname + "/views/errorPage.stache"
        # If you want to twiddle with the data before it gets sent to the template
        preProcessTemplateData: (data) -> data

    # Just pass them to the errorHandler when you register with your express app
    app.use errorface.errorHandler(options)

Here is an example of the data that gets sent to the template

    {
       "headLine":{
          "type":"description",
          "details":{
             "error":"Error",
             "message":"Not Found"
          }
       },
       "stack":[
          {
             "level":1,
             "trace":{
                "type":"file",
                "details":{
                   "method":"init",
                   "file":"''/projects/errorface/test/util/testServer.coffee",
                   "fileHash":"2c57b3f110c76c5348e3e03296430f6b",
                   "fileRelative":"/test/util/testServer.coffee",
                   "line":18,
                   "column":13
                }
             },
             "focused":"throw new Error(\"Not Found\");",
             "file":[
                {
                   "num":14,
                   "isFocus":false,
                   "line":"    app.get(\"/error\", function(req, res, next) {"
                }
             ]
          }
       ],
       "lines":[
          {
             "type":"description",
             "details":{
                "error":"Error",
                "message":"Not Found"
             }
          },
          {
             "type":"file",
             "details":{
                "method":"init",
                "file":"''/projects/errorface/test/util/testServer.coffee",
                "fileHash":"2c57b3f110c76c5348e3e03296430f6b",
                "fileRelative":"/test/util/testServer.coffee",
                "line":18,
                "column":13
             }
          },
          {
             "type":"file",
             "details":{
                "method":"callbacks",
                "file":"''/projects/errorface/node_modules/express/lib/router/index.js",
                "fileHash":"ba7d97ee1f59f2aa0920257deb060e46",
                "fileRelative":"[module]/express/lib/router/index.js",
                "line":162,
                "column":11
             }
          }
       ],
       "projectDirectory":"''/projects/errorface"
    }