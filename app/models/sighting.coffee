class Sighting

  Sighting.id = 0

  constructor: (params) ->
    @type = params.type
    @subType =  params.subType if subType?
    @id = Sighting.nextId()
    @labels = []

  pushSighting: (newAnnotation) ->
    newAnnotation.timeStamp = new Date()
    @labels.push newAnnotation

  popSighting: ->
    @labels.pop()

  getSightingCount: ->
    return @labels.length

  clearSightingsInFrame: (frame_num) ->
    for label, i in @labels
      if label?.frame is frame_num
        @labels.splice i, 1

  displaySummary: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    console.log '      type : ' + @type
    console.log '      subtype: ' + @subType if @subType?
    console.log '      id : ' + @id
    for label in @labels
      console.log '    -:-:-:-:-:-:-:-'
      console.log '      frame : ' + label.frame
      console.log '          x : ' + label.x_actual
      console.log '          y : ' + label.y_actual
      console.log '    visible : ' + label.visible
      console.log '    inverted: ' + label.inverted
      console.log '   timestamp: ' + label.timeStamp

  @nextId: ->
    Sighting.id += 1
    Sighting.id

module.exports = Sighting
