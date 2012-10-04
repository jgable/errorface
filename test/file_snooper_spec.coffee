should = require "should"
FileSnooper = require "../lib/fileSnooper"

describe "FileSnooper", ->
    snooper = null

    before ->
        snooper = new FileSnooper()

    it "can read straight Javascript files", (done) ->
        filePath = process.cwd() + "/test/util/example.js"
        snooper.snoopFile filePath, 8, (err, result) ->
            throw err if err

            result.lines.length.should.equal 9
            result.lines[0].line.should.equal "var other = 456;"
            result.lines[4].line.should.equal "blah.doesntExist();"
            result.lines[4].num.should.equal 9
            result.lines[8].line.should.equal ""

            done()

    it "can read CoffeeScript files", (done) ->
        filePath = process.cwd() + "/test/util/example.coffee"
        snooper.snoopFile filePath, 9, (err, result) ->
            throw err if err

            result.lines.length.should.equal 9
            result.lines[0].line.should.equal "  other = 456;"
            result.lines[4].line.should.equal "  blah.doesntExist();"
            result.lines[4].num.should.equal 10
            result.lines[8].line.should.equal "  moreThings = 4;"

            done()   

    it "cannot read node.js core files", (done) ->
        filePath = "events.js"
        snooper.snoopFile filePath, 115, (err, result) ->
            throw err if err

            result.lines.length.should.equal 0

            done()
      
