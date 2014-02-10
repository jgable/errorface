crypto = require "crypto"


descriptRegex = new RegExp("^(.*): (.*)$")
atRegex = new RegExp(".*?at (.*) \\((.*?):(.*?):(.*?)\\)")


makeHash = (str) -> crypto.createHash("md5").update(str).digest("hex")

projectPath = process.cwd()
makeRelativePath = (path) -> path.replace(projectPath, '').replace("/node_modules", "[module]")

class ErrorLine 
    constructor: (line) ->
        @parse line

    parse: (line) ->
        return @_fillUnknown() if not line

        match = descriptRegex.exec line

        return @_fillForDescript match if match

        match = atRegex.exec line

        return @_fillForAt match if match

        @_fillUnknown()

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
            fileHash: makeHash match[2]
            fileRelative: makeRelativePath match[2]
            line: parseInt match[3], 10
            column: parseInt match[4], 10

    _fillUnknown: ->
        @type = "?"

        @details =
            method: "?"
            file: "?"
            fileHash: "?"
            fileRelative: "?"
            line: "?"
            column: "?"


module.exports = ErrorLine