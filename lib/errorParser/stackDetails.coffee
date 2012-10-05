FileSnooper = require "../fileSnooper"

class StackDetails
    constructor: ->
        @snooper = new FileSnooper

    parseLines: (lines, done) ->
        
        result = []
        idx = 0
        max = lines.length

        handleFinishedSnoop = (err, snoopResult) =>
            done err if err

            currLine = lines[idx]

            result.push 
                level: idx
                trace: currLine
                file: snoopResult.lines

            idx++
            currLine = lines[idx]
            if idx < max
                return @snoopFile currLine, handleFinishedSnoop

            done null, result

        idx++ while lines[idx].type != "file"

        currLine = lines[idx]
        if idx < max
            @snoopFile currLine, handleFinishedSnoop
        else
            done null, result

    snoopFile: (currLine, done) ->
        @snooper.snoopFile currLine.details.file, currLine.details.line, done

module.exports = StackDetails
