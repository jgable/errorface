fs = require "fs"
lazy = require "./Lazy"
coffeescript = require "coffee-script"
Stream = require "stream"

class FileSnooper
    constructor: (opts = {}) ->

        @settings = 
            preLineCount: 4
            postLineCount: 4

        for own key, val of opts
            @settings[key] = val

    snoopFile: (filePath, row, done) ->

        return @_processJSFile(filePath, row, done) if @_isJSFile filePath

        @_processCoffeeFile filePath, row, done

    _isJSFile: (filePath) -> filePath.slice(-2) == "js"

    _processJSFile: (filePath, row, done) ->
        fs.exists filePath, (exists) =>
            unless exists
                return done null,
                    lines: []

            jsFileStream = fs.createReadStream(filePath)
            
            @_commonProcessJS jsFileStream, row, done

    _processCoffeeFile: (filePath, row, done) ->
        fs.readFile filePath, (err, contents) =>
            done err if err
            
            # Compile the coffee script files
            js = coffeescript.compile contents.toString()
            jsStream = new Stream

            @_commonProcessJS jsStream, row, done

            # We have to fake a stream because this is just a string
            jsStream.emit 'open'
            jsStream.emit 'data', js
            jsStream.emit 'end'
            jsStream.emit 'close'

    _commonProcessJS: (lazyValue, row, done) ->
        begin = row - @settings.preLineCount
        begin = 0 if begin < 0

        end = row + @settings.postLineCount

        result = []
        i = 0
        lines = new lazy(lazyValue).lines.map(String).forEach (line) ->
            if begin <= i <= end
                result.push 
                    num: i + 1
                    line: line.replace(/\s+$/,'')
            
            i++

        lines.join ->
            done null, 
                lines: result


module.exports = FileSnooper