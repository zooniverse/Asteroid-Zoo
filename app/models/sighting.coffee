class Sighting

  Sighting.id = 0 

  constructor: (params) ->
    @type = params.type
    @subType =  params.subType if subType?
    @id = Sighting.nextId()
    @allSightings = []

  addSightings: (sightings) ->
    @allSightings = sightings

  pushSighting: (newSighting) ->
    console.log 'sighting pushed'
    newSighting.timeStamp = new Date()
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
    console.log '      type : ' + @type
    console.log '      subtype: ' + @subType if @subType?
    console.log '      id : ' + @id 
    for sighting in @allSightings
      console.log '    -:-:-:-:-:-:-:-'
      console.log '      frame : ' + sighting.frame
      console.log '          x : ' + sighting.x
      console.log '          y : ' + sighting.y
      console.log '    visible : ' + sighting.visible
      console.log '    inverted: ' + sighting.inverted
      console.log '   timestamp: ' + sighting.timeStamp

  @nextId: ->
    Sighting.id += 1
    Sighting.id    

module.exports = Sighting