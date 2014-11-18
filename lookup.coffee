dictionary = require './dictionary.json'
inflects = require './inflects.json'

readline = require 'readline'

prefixes = (prefix, word) -> word[...prefix.length] is prefix

contains = (a, b) ->
  if a is b
    return true
  else if a[a.length - 1] is '0' and a[...-1] is b[...-1]
    return true
  return false

inflect = (candidate) ->
  possibilities = []
  for inflection in inflects when contains(inflection.type, candidate.type)
    possibilities.push {
      string: candidate.principalParts[Math.max(0, inflection.transform[0] - 1)] + inflection.transform[1]
      inflection: inflection
    }
  return possibilities

lookup = (word) ->
  possibilities = []
  for candidate in dictionary
    couldBe = false
    for part in candidate.principalParts
      if prefixes part, word
        couldBe = true
        break
    if couldBe
      for possibility in inflect candidate
        if possibility.string is word
          possibilities.push {
            possiblity: possibility.string
            inflection: possibility.inflection
            definition: candidate
          }
  return possibilities

iface = readline.createInterface {
  input: process.stdin
  output: process.stdout
}

iface.question '> ', fn = (str) ->
  str = str.toString()
  console.log lookup str
  iface.question '> ', fn
