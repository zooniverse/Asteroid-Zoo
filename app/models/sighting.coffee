class Sighting

  constructor: ->
    @allSightings = []

  addSightings: (sightings) ->
    @allSightings = sightings

  pushSighting: (newSighting) ->
    console.log 'sighting pushed'
    @allSightings.push newSighting

  popSighting: ->
    console.log 'sighting popped'
    @allSightings.pop()

  getSightingCount: ->
    return @allSightings.length

  # addSighting: (sighting) ->
  #   console.log 'inside Sighting::addSighting()'
  #   @allSightings.push sighting
  #   console.log @allSightings

  displaySummary: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-' 
    console.log 'ASTEROID '
    for sighting in @allSightings
      console.log '    -:-:-:-:-:-:-:-'
      console.log '      frame : ' + sighting.frame
      console.log '          x : ' + sighting.x
      console.log '          y : ' + sighting.y
      console.log '    visible : ' + sighting.visible
      console.log '    inverted: ' + sighting.inverted

module.exports = Sighting