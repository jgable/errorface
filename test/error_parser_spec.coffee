should = require "should"
ErrorParser = require "../lib/errorParser"
ErrorLine = require "../lib/errorParser/errorLine"
StackDetails = require "../lib/errorParser/stackDetails"

describe "ErrorLine", ->

    it "can parse Error description lines", ->
        line = new ErrorLine "Error: Some Error"

        line.type.should.equal "description"
        line.details.error.should.equal "Error"
        line.details.message.should.equal "Some Error"

    it "can parse TypeError description lines", ->
        line = new ErrorLine "TypeError: Object function app(req, res){ app.handle(req, res); } has no method 'doesntExist'"

        line.type.should.equal "description"
        line.details.error.should.equal "TypeError"
        line.details.message.should.equal "Object function app(req, res){ app.handle(req, res); } has no method 'doesntExist'"

    it "can parse at file lines", ->
        line = new ErrorLine "at init (/projects/errorface/test/util/testServer.coffee:13:18)"

        line.type.should.equal "file"
        line.details.method.should.equal "init"
        line.details.file.should.equal "/projects/errorface/test/util/testServer.coffee"
        line.details.line.should.equal 13
        line.details.column.should.equal 18

describe "ErrorParser", ->
    parser = null

    before ->
        parser = new ErrorParser()

    it "can parse 'Not Found'", ->
        err =
            stack: """Error: Not Found
                at init (/projects/errorface/test/util/testServer.coffee:16:13)
                at callbacks (/projects/errorface/node_modules/express/lib/router/index.js:162:11)
                at param (/projects/errorface/node_modules/express/lib/router/index.js:136:11)
                at pass (/projects/errorface/node_modules/express/lib/router/index.js:143:5)
                at Router._dispatch (/projects/errorface/node_modules/express/lib/router/index.js:170:5)
                at Object.router (/projects/errorface/node_modules/express/lib/router/index.js:33:10)
                at next (/projects/errorface/node_modules/express/node_modules/connect/lib/proto.js:190:15)
                at Object.expressInit [as handle] (/projects/errorface/node_modules/express/lib/middleware.js:31:5)
                at next (/projects/errorface/node_modules/express/node_modules/connect/lib/proto.js:190:15)
                at Object.query [as handle] (/projects/errorface/node_modules/express/node_modules/connect/lib/middleware/query.js:44:5)"""

        lines = parser.parseErrorLines err

        lines.length.should.equal 11
        lines[0].type.should.equal "description"
        lines[0].details.message.should.equal "Not Found"

        for line in lines[1..]
            line.type.should.equal "file"

        true

    it "can parse 'Type Error'", ->
        err = 
            stack: """TypeError: Object function app(req, res){ app.handle(req, res); } has no method 'doesntExist'
                at init (/projects/errorface/test/util/testServer.js:17:20)
                at Object.oncomplete (fs.js:297:15)"""

        lines = parser.parseErrorLines err

        lines.length.should.equal 3
        lines[0].type.should.equal "description"
        lines[0].details.message.should.equal "Object function app(req, res){ app.handle(req, res); } has no method 'doesntExist'"

        for line in lines[1..]
            line.type.should.equal "file"

        true

describe "StackDetails", ->
    stack = null
    lines = null

    before ->
        stack = new StackDetails
        
        lines = []
        lines.push 
            type: "description"
            details:
                error: "Error"
                message: "Not Found"

        lines.push
            type: "file"
            details:
                file: process.cwd() + "/test/util/example.js"
                line: 8
                col: 0

        lines.push
            type: "file"
            details:
                file: process.cwd() + "/test/util/example.js"
                line: 5
                col: 0

    it "can parse 'Not Found'", (done) ->

        stack.parseLines lines, (err, results) ->
            throw err if err

            should.exist results

            results.length.should.equal 2

            results[0].trace.should.equal lines[1]
            results[0].file.length.should.be.above 0

            done()
