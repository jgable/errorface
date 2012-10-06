fs = require "fs"
ErrorParser = require "./ErrorParser"
Mustache = require "mustache"

# TODO: I'm not crazy about how this is setup with the util, 
# but the errorHandler is called with a different this context from express.
util = 
    settings: 
        log: console.log
        logErrors: false
        errorPageTemplate: null
        errorPageTemplatePath: __dirname + "/views/errorPage.stache"
        templateFunc: Mustache.render
        preProcessTemplateData: (data) -> data

    _getErrStack: (err, done) ->
        parser = new ErrorParser()
        parser.parseStackDetails err, done

    _renderTemplateHtml: (headLine, stack, lines, done) ->
        renderTemplate = (tplString) ->
            tplData = 
                headLine: headLine
                stack: stack
                lines: lines
                projectDirectory: process.cwd()

            # Offer the chance to pre process the template data.
            tplData = util.settings.preProcessTemplateData tplData

            # process the template with the passed in template function.
            errorHtml = util.settings.templateFunc tplString, tplData

            done errorHtml

        if util.settings.errorPageTemplate
            renderTemplate util.settings.errorPageTemplate
        else
            fs.readFile util.settings.errorPageTemplatePath, (err, contents) ->
                throw err if err

                renderTemplate contents.toString()

    _renderErrorPage: (resp, headLine, stack, lines) ->
        util._renderTemplateHtml headLine, stack, lines, (html) ->
            resp.send html

    _renderErrorJson: (resp, headLine, stack, lines) ->
        util._renderTemplateHtml headLine, stack, lines, (html) ->

            resp.json 
                error: true
                data: { headLine, stack, lines }
                debug: html

class ErrorFaceApi
    constructor: (opts = {}) ->
        for own key, val of opts
            util.settings[key] = val

    errorHandler: (err, req, resp, next) ->
        util.settings.log err if util.settings.logErrors
        
        util._getErrStack err, (stackErr, headLine, stack, lines) =>
            throw stackErr if stackErr

            method = util._renderErrorJson
            method = util._renderErrorPage if req.accepts 'html'

            method resp, headLine, stack, lines

module.exports = 
    errorHandler: (opts) -> return new ErrorFaceApi(opts).errorHandler
