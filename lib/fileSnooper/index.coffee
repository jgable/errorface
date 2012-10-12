fs = require "fs"
LineReader = require "./lineReader"
coffeescript = require "coffee-script"
Stream = require "stream"

class FileSnooper
    constructor: (opts = {}) ->

        @settings = 
            preLineCount: 5
            postLineCount: 5

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

            @_commonProcessJS true, filePath, row, done

    _processCoffeeFile: (filePath, row, done) ->
        fs.readFile filePath, (err, contents) =>
            done err if err
            
            # Compile the coffee script files
            js = coffeescript.compile contents.toString()
            
            @_commonProcessJS false, js, row, done

    _commonProcessJS: (isFile, filePathOrContents, row, done) ->
        # Make double sure we have an integer
        row = parseInt row, 10
        
        begin = row - (@settings.preLineCount)
        begin = 0 if begin < 0

        end = row + (@settings.postLineCount - 1)

        count = end - begin
        
        result = []
        focused = ""
        i = begin

        reader = new LineReader()
        method = "readFileRange"
        unless isFile
            method = "readStringRange"

        lineCallback = (line) ->
            num = i + 1
            isFocus = (num == row)
            line = line.replace(/\s+$/,'')

            focused = line if isFocus
            
            result.push 
                num: num
                isFocus: (num == row)
                line: line.replace(/\s+$/,'')

            i++

        reader[method] filePathOrContents, lineCallback, begin, count, ->
            done null,
                focused: focused
                lines: result

        true

module.exports = FileSnooper