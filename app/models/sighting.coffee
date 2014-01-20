class Sighting

  Sighting.id = 0 

  constructor: (params) ->
    @type = params.type
    @subType =  params.subType if subType?
    @id = Sighting.nextId()
    @allSightings = []

  pushSighting: (newSighting) ->
    console.log 'sighting pushed'
    newSighting.timeStamp = new Date()
    @allSightings.push newSighting

  popSighting: ->
    console.log 'sighting popped'
    @allSightings.pop()

  getSightingCount: ->
    return @allSightings.length

  clearSightingsInFrame: (frame_num) ->
    for sighting, i in @allSightings
      if sighting.frame is frame_num
        console.log 'remove: ', sighting
        @allSightings.splice i, 1

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