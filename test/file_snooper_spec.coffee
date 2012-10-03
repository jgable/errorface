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
            result.lines[0].should.equal "var other = 456;"
            result.lines[4].should.equal "blah.doesntExist();"
            result.lines[8].should.equal ""

            done()

    it "can read CoffeeScript files", (done) ->
        filePath = process.cwd() + "/test/util/example.coffee"
        snooper.snoopFile filePath, 8, (err, result) ->
            throw err if err

            result.lines.length.should.equal 9
            result.lines[0].should.equal "var other = 456;"
            result.lines[4].should.equal "blah.doesntExist();"
            result.lines[8].should.equal ""

            done()        
