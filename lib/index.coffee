fs = require "fs"
ErrorParser = require "./ErrorParser"
Mustache = require "mustache"

class ErrorFaceApi
    constructor: (opts = {}) ->
        @settings =
            log: console.log
            logErrors: false
            showPage: true
            errorPageTemplate: null
            errorPageTemplatePath: __dirname + "/views/errorPage.stache"
            templateFunc: Mustache.render
            preProcessTemplateData: (data) -> 
                console.log JSON.stringify(data)
                data

        for own key, val of opts
            @settings[key] = val

    errorHandler: ->
        
        (err, req, resp, next) =>
            # Offer the chance to circumvent the showing of the page.
            return next() if @settings.showPage == false || @settings.showPage?(err, req) == false

            @settings.log err if @settings.logErrors
            
            @_getErrStack err, (stackErr, headLine, stack, lines) =>
                throw stackErr if stackErr

                method = @_renderErrorJson
                method = @_renderErrorPage if req.accepts 'html'

                method.apply @, [resp, headLine, stack, lines]

    _getErrStack: (err, done) ->
        parser = new ErrorParser()
        parser.parseStackDetails err, done

    _renderTemplateHtml: (headLine, stack, lines, done) ->
        renderTemplate = (tplString) =>
            tplData = 
                headLine: headLine
                stack: stack
                lines: lines
                projectDirectory: process.cwd()

            # Offer the chance to pre process the template data.
            tplData = @settings.preProcessTemplateData tplData

            # process the template with the passed in template function.
            errorHtml = @settings.templateFunc tplString, tplData

            done errorHtml

        if @settings.errorPageTemplate
            renderTemplate @settings.errorPageTemplate
        else
            fs.readFile @settings.errorPageTemplatePath, (err, contents) ->
                throw err if err

                renderTemplate contents.toString()

    _renderErrorPage: (resp, headLine, stack, lines) ->
        @_renderTemplateHtml headLine, stack, lines, (html) ->
            resp.send html

    _renderErrorJson: (resp, headLine, stack, lines) ->
        @_renderTemplateHtml headLine, stack, lines, (html) ->

            resp.json 
                error: true
                data: { headLine, stack, lines }
                debug: html

module.exports = 
    # Export our api for extending or testing
    ErrorFaceApi: ErrorFaceApi
    # Helper for creating an errorHandler easily.
    errorHandler: (opts) -> return new ErrorFaceApi(opts).errorHandler()
