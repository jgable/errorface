should = require "should"
FileSnooper = require "../lib/fileSnooper"
LineReader = require "../lib/fileSnooper/lineReader"

describe "LineReader", ->
    reader = null
    example_filePath = process.cwd() + "/test/util/example.js"

    coffeeString = 
        """
        // Generated by CoffeeScript 1.3.3
        (function() {
          var blah, endVariable, evenMoreThings, moreThings, other, realySuperlongEnd, superEnd, thing;

          blah = 123;

          other = 456;

          thing = "thing";

          blah.doesntExist();

          endVariable = 2;

          moreThings = 4;

          evenMoreThings = 6;

          superEnd = 1;

          realySuperlongEnd = 4;

        }).call(this);

        """

    before ->
        reader = new LineReader()

    it "can load a file by name", (done) ->
        filePath = example_filePath
        loadedFile = false
        lineCb = -> loadedFile = true

        reader.readFileLines filePath, lineCb, ->
            loadedFile.should.equal true
            done()

    it "can load the correct number of lines from a file", (done) ->
        lineCount = 0
        lineCb = -> lineCount++

        reader.readFileLines example_filePath, lineCb, ->
            lineCount.should.equal 20
            done()

    it "can load a range of lines from a file", (done) ->
        lineCount = 0
        lines = []
        lineCb = (line) -> 
            lineCount++
            lines.push line

        reader.readFileRange example_filePath, lineCb, 0, 3, ->
            lineCount.should.equal 3
            lines[0].should.equal "// Some fluff up top"
            lines[1].should.equal "// more fluff"
            lines[2].should.equal ""

            done()

    it "can load all lines in a string", (done) ->

        lineCount = 0
        lineCb = -> 
            lineCount++

        reader.readStringLines coffeeString, lineCb, ->
            lineCount.should.equal 24

            done()

    it "can load a range of lines in a string", (done) ->

        lineCount = 0
        lines = []
        lineCb = (line) ->
            lineCount++
            lines.push line

        reader.readStringRange coffeeString, lineCb, 0, 3, ->
            lineCount.should.equal 3

            lines[0].should.equal "// Generated by CoffeeScript 1.3.3"
            lines[1].should.equal "(function() {"
            lines[2].should.equal "  var blah, endVariable, evenMoreThings, moreThings, other, realySuperlongEnd, superEnd, thing;"

            done()


describe "FileSnooper", ->
    snooper = null

    before ->
        snooper = new FileSnooper()

    it "can read straight Javascript files", (done) ->
        filePath = process.cwd() + "/test/util/example.js"
        snooper.snoopFile filePath, 9, (err, result) ->
            throw err if err

            result.lines.length.should.equal 9
            result.lines[0].line.should.equal "var other = 456;"
            result.lines[4].line.should.equal "blah.doesntExist();"
            result.lines[4].num.should.equal 9
            result.lines[8].line.should.equal ""

            done()

    it "can read CoffeeScript files", (done) ->
        filePath = process.cwd() + "/test/util/example.coffee"
        snooper.snoopFile filePath, 10, (err, result) ->
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
      
