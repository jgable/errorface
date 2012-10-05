fs = require "fs"

class LineReader
    constructor: (opts) ->

        @settings = 
            encoding: "utf8"
            blockSize: 4096
            splitOn: "\n"

        @settings[key] = val for own key, val of opts

    readStringLines: (contents, lineCallback, done) ->
        @readStringRange contents, lineCallback, 0, null, done

    readStringRange: (contents, lineCallback, begin = 0, count, done) ->
        {completeLines, lastLine} = @_parseLines contents, @settings.splitOn

        currLine = 0
        end = begin + count if count?

        callbackWrap = (line) ->
            keepGoing = lineCallback(line) if currLine >= begin && (!end || (currLine < end))

            if keepGoing == false or (end && currLine >= end)
                currLine++
                return false 

            currLine++
            return true

        for l in completeLines
            keepGoing = callbackWrap(l)
            return done() if keepGoing == false

        done()

    readFileLines: (filePath, lineCallback, done) ->
        @readFileRange filePath, lineCallback, 0, null, done

    readFileRange: (filePath, lineCallback, begin = 0, count, done) ->

        currLine = 0
        end = begin + count if count?

        callbackWrap = (line) ->
            keepGoing = lineCallback(line) if currLine >= begin && (!end || (currLine < end))

            if keepGoing == false or (end && currLine >= end)
                currLine++
                return false 

            currLine++
            return true

        @_eachLineIn filePath, callbackWrap, done

    _eachLineIn: (filePath, func, done) ->

        blockSize = @settings.blockSize
        encoding = @settings.encoding
        splitOn = @settings.splitOn

        buffer = new Buffer(blockSize)
        fd = fs.openSync filePath, 'r'
        lastLine = ''

        processChunk = (err, bytesRead) =>
            throw err if err

            moreContent = bytesRead is blockSize

            wholeString = (lastLine || '') + buffer.toString(encoding, 0, bytesRead)
            
            {completeLines, lastLine} = @_parseLines wholeString, splitOn

            # Tack on the last line if we don't have any more content
            completeLines.push lastLine unless moreContent || lastLine == ''

            for line in completeLines
                keepGoing = func(line)
                break if keepGoing == false

            # If we have more to read, process the next chunk.
            if keepGoing and moreContent
                fs.read fd, buffer, 0, blockSize, null, processChunk
            else
                done()

            return true

        fs.read fd, buffer, 0, blockSize, 0, processChunk
        return

    _parseLines: (wholeString, splitOn) ->
        lines = wholeString.split splitOn
        
        # Destructured array assignment, so we can weed out the last line easily.
        [completeLines..., lastLine] = lines
        
        # Edge case: if the last characters were new lines, add the last line
        if wholeString.slice(-(splitOn.length)) == splitOn
            completeLines.push lastLine
            lastLine = ''

        {completeLines, lastLine}

module.exports = LineReader