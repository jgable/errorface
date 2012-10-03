ErrorLine = require "./errorLine"

class ErrorParser

    parseErrorLines: (err) ->
        throw new Error "Stack not found" if not err.stack

        (@parseLine line for line in err.stack.split "\n")

    parseLine: (line) -> new ErrorLine(line)


module.exports = ErrorParser