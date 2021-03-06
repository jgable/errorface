ErrorLine = require "./errorLine"
StackDetails = require "./stackDetails"

class ErrorParser

    parseStackDetails: (err, done) ->
        stack = new StackDetails

        lines = @parseErrorLines err
        header = @parseHeader err

        stack.parseLines lines, (err, stack) ->
            done err if err

            done err, header, stack, lines

    parseHeader: (err) ->
        header = new ErrorLine()
        details = err.stack.split("    at ")[0]
        lines = details.split("\n")
        header.details.error = lines.shift()
        header.details.message = lines.join("\n")
        return header

    parseErrorLines: (err) ->
        throw new Error "Stack not found" if not err.stack

        (@parseLine line for line in err.stack.split "\n")

    parseLine: (line) -> new ErrorLine(line)


module.exports = ErrorParser