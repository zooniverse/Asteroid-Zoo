class Sighting

  Sighting.id = 0

  constructor: (params) ->
    @type = params.type
    @subType =  params.subType if subType?
    @id = Sighting.nextId()
    @allAnnotations = []

  pushSighting: (newAnnotation) ->
    newAnnotation.timeStamp = new Date()
    @allAnnotations.push newAnnotation

  popSighting: ->
    @allAnnotations.pop()

  getSightingCount: ->
    return @allAnnotations.length

  clearSightingsInFrame: (frame_num) ->
    for annoattion, i in @allAnnotations
      if annoattion?.frame is frame_num
        @allAnnotations.splice i, 1

  displaySummary: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    console.log '      type : ' + @type
    console.log '      subtype: ' + @subType if @subType?
    console.log '      id : ' + @id
    for annoattion in @allAnnotations
      console.log '    -:-:-:-:-:-:-:-'
      console.log '      frame : ' + annoattion.frame
      console.log '          x : ' + annoattion.x
      console.log '          y : ' + annoattion.y
      console.log '    visible : ' + annoattion.visible
      console.log '    inverted: ' + annoattion.inverted
      console.log '   timestamp: ' + annoattion.timeStamp

  @nextId: ->
    Sighting.id += 1
    Sighting.id

module.exports = Sighting
