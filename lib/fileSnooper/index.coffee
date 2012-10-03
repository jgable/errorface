fs = require "fs"
lazy = require "./Lazy"
coffeescript = require "coffee-script"

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
        jsFileStream = fs.createReadStream(filePath)
        
        @_commonProcessJS jsFileStream, row, done

    _processCoffeeFile: (filePath, row, done) ->
        fs.readFile filePath, (err, contents) =>
            throw err if err
            # Compile the coffee script files
            js = coffeescript.compile contents.toString()
            
            begin = row - @settings.preLineCount
            begin = 0 if begin < 0

            end = row + @settings.postLineCount

            result = []
            i = 0
            console.log "Begin processing"
            lines = new lazy().lines.map(String).forEach (line) ->
                console.log "Process line", line
                result.push line.trim() if begin <= i <= end
                
                i++

            console.log "After processing"
            lines.join () ->
                done null, 
                    lines: result

            lines.emit('data', js)

    _commonProcessJS: (lazyValue, row, done) ->
        begin = row - @settings.preLineCount
        begin = 0 if begin < 0

        end = row + @settings.postLineCount

        result = []
        i = 0
        console.log "Begin processing"
        lines = new lazy(lazyValue).lines.map(String).forEach (line) ->
            console.log "Process line", line
            result.push line.trim() if begin <= i <= end
            
            i++

        console.log "After processing"
        lines.join () ->
            done null, 
                lines: result




module.exports = FileSnooper