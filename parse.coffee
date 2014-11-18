fs = require 'fs'
class Word
  constructor: (line) ->
    @partOfSpeech = line[line.length - 3]
    @principalParts = line[...line.length - 3]
    @definition = line[line.length - 1][10..]
    @info = line[line.length - 1][...9]
    @subtype = line[line.length - 2]
    @type = @getTypeIdentFlag()

  inflect: (inflect) ->
    @principalParts[Math.max(0, Math.min(@principalParts.length - 1, inflect.transform[0] - 1))] + inflect.transform[1]

  getTypeIdentFlag: ->
    if @subtype?
      match = @subtype.match(/^\d \d/)
      if match?
        return @partOfSpeech + ' ' + match[0]
    return @partOfSpeech

fs.readFile 'DICTLINE.GEN', (err, data) ->
  words = data.toString().split('\n').map (line) -> new Word line.split /\s\s+/

  class Inflect
    constructor: (line) ->
      @partOfSpeech = line[0]
      @subtype = line[1]
      if line.length > 3
        transformStr = line[2].split(' ')
        if transformStr[1] is 0
          @transform = [Number(transformStr[0]), '']
        else
          @transform = [Number(transformStr[0]),  transformStr[2]]
        @info = line[3]
      else
        @transform = [0, '']
        @info = line[2]
      @type = @getTypeIdentFlag()

    getTypeIdentFlag: ->
      if @subtype?
        match = @subtype.match(/^\d \d/)
        if match?
          return @partOfSpeech + ' ' + match[0]
      return @partOfSpeech

  fs.readFile 'inflects.txt', (err, data) ->
    inflects = data.toString().split('\n')
      # Get rid of comments
      .map((line) -> line.replace(/--.*/, '').trim())
      .filter((line) -> line.length > 0)

      # Parse
      .map (line) -> new Inflect line.split /\s\s+/

    fs.writeFileSync 'inflects.json', JSON.stringify inflects, null, 2
    fs.writeFileSync 'dictionary.json', JSON.stringify words, null, 2
    console.log 'done'
