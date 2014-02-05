class Sighting

  Sighting.id = 0

  constructor: (params) ->
    @type = params.type
    @subType =  params.subType if subType?
    @id = Sighting.nextId()
    @annotations = []

  pushSighting: (newAnnotation) ->
    newAnnotation.timeStamp = new Date()
    @annotations.push newAnnotation

  popSighting: ->
    @annotations.pop()

  getSightingCount: ->
    return @annotations.length

  clearSightingsInFrame: (frame_num) ->
    for annoattion, i in @annotations
      if annoattion?.frame is frame_num
        @annotations.splice i, 1

  displaySummary: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    console.log '      type : ' + @type
    console.log '      subtype: ' + @subType if @subType?
    console.log '      id : ' + @id
    for annoattion in @annotations
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
