should = require "should"
{ErrorFaceApi} = require "../lib"

describe "ErrorFaceApi", ->
    api = null

    beforeEach ->
        api = new ErrorFaceApi

    it "returns an error handler to use with expressjs", ->
        handler = api.errorHandler()

        should.exist handler

    it "renders an error page if the request accepts html", (done) ->
        errToThrow = new Error "errorface"
        
        api._getErrStack = (_, cb) -> cb()

        api._renderErrorPage = -> 
            done()

        handler = api.errorHandler()

        handler errToThrow, 
            accepts: (contentDisposition) -> 
                contentDisposition == "html"

    it "renders error data if the request accepts json", (done) ->
        errToThrow = new Error "errorface"
        
        api._getErrStack = (_, cb) -> cb()

        api._renderErrorJson = ->
            done()
 
        api._renderErrorPage = -> 
            false.should.equal true, "Should not call _renderErrorPage"
            done()

        handler = api.errorHandler()

        fakeReq = 
            accepts: (contentDisposition) -> 
                contentDisposition == "json"

        handler errToThrow, fakeReq, null, ->
            done()


    it "logs errors to log function if logErrors is true", (done) ->
        errToThrow = new Error "errorface"
        logCount = 0
        
        api.settings.logErrors = true
        api.settings.log = (msg) ->
            logCount++
            msg.should.equal errToThrow
        
        api._getErrStack = (_, cb) -> cb()

        handler = api.errorHandler()

        fakeReq = 
            accepts: -> false

        handler errToThrow, fakeReq, null, ->
            done()

    it "invokes next middleware if the request doesn't accepts json and html", (done) ->
        errToThrow = new Error "errorface"
        logCount = 0
        
        api.settings.logErrors = true
        api.settings.log = (msg) ->
            logCount++
            msg.should.equal errToThrow
        
        api._getErrStack = (_, cb) -> cb()
        
        api._renderErrorPage = -> 
            logCount.should.equal 1
            done()

        handler = api.errorHandler()

        fakeReq = 
            accepts: -> false

        handler errToThrow, fakeReq, null, ->
            done()

    it "allows you to short circuit showing an error page with a function", (done) ->
        errToThrow = new Error "errorface"
        
        api._getErrStack = (_, cb) -> cb()

        api._renderErrorJson = ->
            false.should.equal true, "Should not call _renderErrorJson"
            done()

        api._renderErrorPage = -> 
            false.should.equal true, "Should not call _renderErrorPage"
            done()

        api.settings.showPage = (err, req) ->
            err.should.equal errToThrow
            req.should.equal fakeReq

            return false

        handler = api.errorHandler()

        fakeReq = 
            accepts: (contentDisposition) -> 
                false

        handler errToThrow, fakeReq, null, ->
            done()

    it "allows you to short circuit showing an error page with a false value", (done) ->
        errToThrow = new Error "errorface"
        
        api._getErrStack = (_, cb) -> cb()

        api._renderErrorJson = ->
            false.should.equal true, "Should not call _renderErrorJson"
            done()

        api._renderErrorPage = -> 
            false.should.equal true, "Should not call _renderErrorPage"
            done()

        api.settings.showPage = false

        handler = api.errorHandler()

        fakeReq = 
            accepts: (contentDisposition) -> 
                false

        handler errToThrow, fakeReq, null, ->
            done()

    it "processes normally if you return null from showPage", (done) ->
        errToThrow = new Error "errorface"
        
        api._getErrStack = (_, cb) -> cb()

        api._renderErrorJson = ->
            false.should.equal true, "Should not call _renderErrorJson"
            done()
        
        api._renderErrorPage = -> 
            done()

        api.settings.showPage = (err, req) -> null

        handler = api.errorHandler()

        fakeReq = 
            accepts: -> true

        handler errToThrow, fakeReq

    it "processes normally if you return true from showPage", (done) ->
        errToThrow = new Error "errorface"
        
        api._getErrStack = (_, cb) -> cb()

        api._renderErrorJson = ->
            false.should.equal true, "Should not call _renderErrorJson"
            done()
        
        api._renderErrorPage = -> 
            done()

        api.settings.showPage = (err, req) -> true

        handler = api.errorHandler()

        fakeReq = 
            accepts: -> true

        handler errToThrow, fakeReq
            