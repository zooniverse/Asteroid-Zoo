class Sighting

  Sighting.id = 0

  constructor: (params) ->
    @type = params.type
    @subType =  params.subType if subType?
    @id = Sighting.nextId()
    @annotations = []

  pushSighting: (newAnnotation) ->
    newAnnotation.timeStamp = new Date()
    # newAnnotation.x = newAnnotation.x/2    
    # newAnnotation.y = newAnnotation.y/2
    @annotations.push newAnnotation

  popSighting: ->
    @annotations.pop()

  getSightingCount: ->
    return @annotations.length

  clearSightingsInFrame: (frame_num) ->
    for annotation, i in @annotations
      if annotation?.frame is frame_num
        @annotations.splice i, 1

  displaySummary: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    console.log '      type : ' + @type
    console.log '      subtype: ' + @subType if @subType?
    console.log '      id : ' + @id
    for annotation in @annotations
      console.log '    -:-:-:-:-:-:-:-'
      console.log '      frame : ' + annotation.frame
      console.log '          x : ' + annotation.x
      console.log '          y : ' + annotation.y
      console.log '    visible : ' + annotation.visible
      console.log '    inverted: ' + annotation.inverted
      console.log '   timestamp: ' + annotation.timeStamp

  @nextId: ->
    Sighting.id += 1
    Sighting.id

module.exports = Sighting
