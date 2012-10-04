ErrorLine = require "./errorLine"
StackDetails = require "./stackDetails"

class ErrorParser

    parseStackDetails: (err, done) ->
        stack = new StackDetails

        lines = @parseErrorLines err

        stack.parseLines lines, (err, stack) ->
            done err if err

            done err, lines?[0], stack, lines

    parseErrorLines: (err) ->
        throw new Error "Stack not found" if not err.stack

        (@parseLine line for line in err.stack.split "\n")

    parseLine: (line) -> new ErrorLine(line)


module.exports = ErrorParser