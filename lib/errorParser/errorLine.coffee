
descriptRegex = new RegExp("^(.*): (.*)$")
atRegex = new RegExp(".*?at (.*) \\((.*?):(.*?):(.*?)\\)")

class ErrorLine 
    constructor: (line) ->
        @parse line

    parse: (line) ->
        throw new Error("Must provide line") if not line

        match = descriptRegex.exec line

        return @_fillForDescript match if match

        match = atRegex.exec line

        return @_fillForAt match if match

        throw new Error("Unable to parse error line: #{line}")

    _fillForDescript: (match) ->
        @type = "description"
        @details = 
            error: match[1]
            message: match[2]

    _fillForAt: (match) ->
        @type = "file"
        @details = 
            method: match[1]
            file: match[2]
            line: match[3]
            column: match[4]


module.exports = ErrorLine