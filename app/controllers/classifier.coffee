BaseController = require 'zooniverse/controllers/base-controller'
User           = require 'zooniverse/models/user'
Subject        = require 'zooniverse/models/subject'
Sighting       = require '../models/sighting'
# GhostMark      = require '..models/ghost-mark'
modulus        = require '../lib/modulus'

loadImage      = require '../lib/load-image'
Classification = require 'zooniverse/models/classification'
MarkingSurface = require 'marking-surface'
MarkingTool    = require './marking-tool'
MarkingToolControls = require './marking-tool-controls'
$ = window.jQuery

KEYS =
  space:  32
  return: 13
  esc:    27
  one:    49
  two:    50
  three:  51
  four:   52

DEV_SUBJECTS = [ 
  # './dev-subjects-images/01_12DEC02_N04066_0001-45-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0002-45-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0003-45-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0004-45-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0001-50-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0002-50-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0003-50-scaled.png'
  # './dev-subjects-images/01_12DEC02_N04066_0004-50-scaled.png' 
  './dev-subjects-images/01_12DEC02_N04066_0001-51-scaled.png'
  './dev-subjects-images/01_12DEC02_N04066_0002-51-scaled.png'
  './dev-subjects-images/01_12DEC02_N04066_0003-51-scaled.png'
  './dev-subjects-images/01_12DEC02_N04066_0004-51-scaled.png'
]

NEXT_DEV_SUBJECT = ->
  DEV_SUBJECTS.push DEV_SUBJECTS.shift()
  DEV_SUBJECTS[0]

class Classifier extends BaseController
  className: 'classifier'
  template: require '../views/classifier'

  events:
    'click button[name="play-frames"]'      : 'onClickPlay'
    'click button[name="invert"]'           : 'onClickInvert'
    'click button[name="finish-marking"]'   : 'onClickFinishMarking'
    'click button[name="four-up"]'          : 'onClickFourUp'
    'click button[name="flicker"]'          : 'onClickFlicker'
    'click button[name="next-frame"]'       : 'onClickNextFrame'
    'click button[name="asteroid-done"]'    : 'onClickAsteroidDone'
    'click button[name="cancel"]'           : 'onClickCancel'
    'change input[name="frame-slider"]'     : 'onChangeFrameSlider'
    'change input[name="selected-artifact"]': 'onSelectArtifact'
    'change .asteroid-not-visible'          : 'onClickAsteroidNotVisible'
    'keydown'                               : 'onKeyDown'

    # state controller events
    'change input[name="classifier-type"]': (e) ->
      if e.currentTarget.value is 'asteroid'
        @setState 'asteroidTool'
      else if  e.currentTarget.value is 'artifact'
        @setState 'artifactTool'
      else if e.currentTarget.value is 'nothing'
        @finishButton.prop 'disabled', false
      else
        console.log("Error: unknown classifier-type")

    'click button[name="asteroid-delete"]': ->
      currentFrame = +document.getElementById('frame-slider').value
      @destroyMarksInFrame currentFrame

    'click button[name^="done"]': ->
      @tool.deselect()

  elements:
    '.subject'                       : 'subjectContainer'
    '.surfaces-container'            : 'surfacesContainer'
    '.frame-image'                   : 'imageFrames'
    'button[name="play-frames"]'     : 'playButton'
    'button[name="invert"]'          : 'invertButton'
    'button[name="flicker"]'         : 'flickerButton'
    'button[name="four-up"]'         : 'fourUpButton'
    'button[name="finish-marking"]'  : 'finishButton'
    'button[name="asteroid-done"]'   : 'doneButton'
    'button[name="asteroid-delete"]' : 'deleteButton'
    'button[name="next-frame"]'      : 'nextFrame'
    'button[name="cancel"]'          : 'cancel'
    'input[name="selected-artifact"]': 'artifactSelector'
    'input[name="classifier-type"]'  : 'classifierTypeRadios'
    '.asteroid-not-visible'          : 'asteroidVisibilityCheckboxes'
    '.asteroid-checkbox'             : 'asteroidCompleteCheckboxes'
    '.current-frame'                 : 'frameSlider'

  states:
    whatKind:
      enter: ->
        @disableMarkingSurfaces()

        # reset asteroid/artifact selector
        for e in @el.find('input[name="classifier-type"]')
          e.checked = false
        @el.find('button[name="to-select"]').addClass 'hidden'
        @el.find('.what-kind').show()

      exit: ->
        @el.find('button[name="to-select"]').removeClass 'hidden'
        @el.find('.what-kind').hide()

    asteroidTool:
      enter: ->
        if @el.attr('flicker') is 'true' then @activateFrame 0 else @showAllTrackingIcons()
        @enableMarkingSurfaces()
        @currSighting = new Sighting({type:"asteroid"})
        @el.find('.asteroid-classifier').show()
        @finishButton.hide()
        @doneButton.show()
        @doneButton.prop 'disabled', true

      exit: ->
        @disableMarkingSurfaces()
        @el.find('.asteroid-classifier').hide()
        @doneButton.hide()
        @finishButton.show()
        @onClickFlicker() unless @el.attr('flicker') is 'true'

    artifactTool:
      enter: ->
        @enableMarkingSurfaces()
        @currSighting = new Sighting({type:"artifact"})
        @el.find('.artifact-classifier').show()
        @nextFrame.hide()
        @finishButton.hide()
        @doneButton.show()
        @doneButton.prop 'disabled', true
      exit: ->
        @disableMarkingSurfaces()
        @el.find('.artifact-classifier').hide()
        @nextFrame.show()
        @doneButton.hide()
        @finishButton.show()
        el.checked = false for el in [ @artifactSelector ... ] # reset artifact selector
          
  constructor: ->
    super
    @asteroidMarkedInFrame = [ null, null, null, null ]
    @playTimeouts = []
    @el.attr tabindex: 0
    @el.attr 'flicker', "true"
    @invert = false

    window.classifier = @
    @setOfSightings = []
    @currSighting = null

    @flickerButton.attr 'disabled', true
    @finishButton.prop 'disabled', true

    @createMarkingSurfaces()

    @setState 'whatKind'
    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

  onSelectArtifact: ->
    @currSighting.subType = @artifactSelector.filter(':checked').val()

  createMarkingSurfaces: ->
    @numFrames = 4
    @markingSurfaceList = new Array
    for i in [0...@numFrames]
      @markingSurfaceList[i] = new MarkingSurface
        tool: MarkingTool
      @markingSurfaceList[i].svgRoot.attr 'id', "classifier-svg-root-#{i}"
      @surfacesContainer.append @markingSurfaceList[i].el

    for surface in @markingSurfaceList
      surface.on 'create-mark', @onCreateMark
      surface.on 'create-tool', @onCreateTool
      surface.on 'destroy-mark', @onDestroyMark

  renderTemplate: =>
    super

  setState: (newState) ->
    if @state
      @states[@state]?.exit.call @
    else
      exit.call @ for state, {exit} of @states when state isnt newState

    @state = newState
    @states[@state]?.enter.call @
    @el.attr 'data-state', @state

    setTimeout =>
      @el.find('a, button, input, textarea, select').filter('section *:visible').first().focus()

  onCreateMark: (mark) =>
    @currSighting.pushSighting mark
    
    setTimeout => # otherwise mark properties undefined
      @removeGhostMarks() # remove unworthy ghosts
      @addGhostMark(mark)

  addGhostMark: (mark) ->
    svgElement = null
    for surface, i in @markingSurfaceList
      if i isnt +mark.frame
        if @el.attr('flicker') is 'true'
          [xVal, yVal] = [mark.x, mark.y]
        else
          [xVal, yVal] = [mark.x / 2, mark.y / 2]
        svgElement = surface.addShape 'circle', class: "ghost-mark", opacity: 1, cx: xVal, cy: yVal, r: 16, fill: "none", stroke: "#25b4c5", strokewidth: 1
        svgElement.el.setAttribute 'from-frame', mark.frame
        svgElement.el.setAttribute 'from-asteroid', @currSighting.id

  removeGhostMarks: ->
    for ghostMark in [ @el.find(".ghost-mark")... ]
      ghostMark.remove()

  onDestroyMark: (mark) =>
    @destroyMarksInFrame mark.frame
    @updateIconsForDestroyMark mark.frame
    @currSighting.clearSightingsInFrame mark.frame
    @removeGhostMarks()
    if @state is 'asteroidTool' and @currSighting.allSightings.length < @numFrames
      @doneButton.prop 'disabled', true

  onCreateTool: (tool) =>
    surfaceIndex = +@markingSurfaceList.indexOf tool.surface

    if @asteroidMarkedInFrame[surfaceIndex]
      @currSighting.clearSightingsInFrame surfaceIndex
      @destroyMarksInFrame(surfaceIndex)
    else
      @el.find(".asteroid-frame-complete-#{surfaceIndex}").prop 'checked', true
      @asteroidMarkedInFrame[surfaceIndex] = true
    @updateIconsForCreateMark(surfaceIndex)

    if @state is 'asteroidTool' and @currSighting.allSightings.length is @numFrames \
      or @state is 'artifactTool' and @currSighting.allSightings.length > 0
        @doneButton.prop 'disabled', false

    tool.controls.controller.setMark(surfaceIndex, @currSighting.id)

  onChangeFrameSlider: =>
    frame = document.getElementById('frame-slider').value
    @activateFrame(frame)

  onKeyDown: (e) =>
    return if @el.hasClass 'playing' or @el.attr('flicker') is 'false' # disable while playing or in 4up
    switch e.which
      when KEYS.one   then @activateFrame(0)
      when KEYS.two   then @activateFrame(1)
      when KEYS.three then @activateFrame(2)
      when KEYS.four  then @activateFrame(3)
      when KEYS.space
        e.preventDefault()
        @onClickPlay()

  onUserChange: (e, user) =>
    Subject.next() unless @classification?

  onSubjectFetch: =>
    @startLoading()

  onSubjectSelect: (e, subject) =>
    @resetMarkingSurfaces()
    @classification = new Classification {subject}
    @loadFrames()

  resetMarkingSurfaces: =>
    surface.reset() for surface in @markingSurfaceList

  disableMarkingSurfaces: =>
    surface.disable() for surface in @markingSurfaceList

  enableMarkingSurfaces: =>
    surface.enable() for surface in @markingSurfaceList

  loadFrames: =>
    @destroyFrames()
    subject_info = @classification.subject.location
    for i in [0...@numFrames]
      frame_id = "frame-id-#{i}"
      frameImage =
        @markingSurfaceList[i].addShape 'image',
        id:  frame_id
        class:  'frame-image'
        width:  '100%'
        height: '100%'
        preserveAspectRatio: 'true'

      img_src = if @invert then subject_info.inverted[i] else subject_info.standard[i]

      do (img_src, frameImage)  =>
        loadImage img_src, (img) =>
        frameImage.attr
          # 'xlink:href': img_src          # get images from api
          'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    @stopLoading()
    @activateFrame 0  # default to first frame after loading

  onClickFourUp: ->
    @el.find("#frame-id-#{i}").closest("div").show() for i in [0...@numFrames]
    @nextFrame.hide()
    @playButton.hide()
    @frameSlider.hide()
    markingSurfaces = document.getElementsByClassName("marking-surface")
    @resizeElements(markingSurfaces, 255) # image sizing for 4up view
    @fourUpButton.attr 'disabled', true
    @flickerButton.attr 'disabled', false
    @el.attr 'flicker', "false"
    @deleteButton.hide()
    @rerenderMarks()
    @showAllTrackingIcons()
    ghostMark.setAttribute 'visibility', 'hidden' for ghostMark in [ @el.find('.ghost-mark')... ]

  onClickFlicker: ->
    markingSurfaces = document.getElementsByClassName("marking-surface")
    @resizeElements(markingSurfaces, 512) # image sizing for 4up view
    @nextFrame.show()
    @playButton.show()
    @frameSlider.show()
    @flickerButton.attr 'disabled', true
    @fourUpButton.attr 'disabled', false
    @el.attr 'flicker', "true"
    @deleteButton.show()
    @rerenderMarks()
    setTimeout => @activateFrame 0
    ghostMark.setAttribute 'visibility', 'visible' for ghostMark in [ @el.find('.ghost-mark')... ]

  rerenderMarks: ->
    setTimeout =>
      for surface in @markingSurfaceList
        for tool in surface.tools
          tool.render()

  resizeElements: (elements, newSize) ->
    for element in elements
      element.style.width = newSize + "px"
      element.style.height = newSize + "px"

  destroyMarksInFrame: (frame_idx) ->
    for surface in @markingSurfaceList
      for theMark in surface.marks
        theMark?.destroy() if theMark?.frame is frame_idx and theMark?.id is @currSighting.id

  onClickAsteroidNotVisible: (e) ->
    frameNum = +e.target.id.slice(-1)
    visibilityChecked = @asteroidVisibilityCheckboxes[frameNum].checked

    if @asteroidMarkedInFrame[frameNum]
      @currSighting.clearSightingsInFrame frameNum
      @destroyMarksInFrame frameNum

    @updateIconsForNotVisible(frameNum)

    newAnnotation =
      frame: frameNum
      x: null
      y: null
      visible: false
      inverted: @invert
    @currSighting.pushSighting newAnnotation

    if @state is 'asteroidTool' and @currSighting.allSightings.length is @numFrames
      @doneButton.prop 'disabled', false

  updateIconsForCreateMark: (frameNum) =>
    @el.find("#number-#{frameNum}").hide()
    @el.find(".asteroid-frame-complete-#{frameNum}").prop 'checked', true
    @el.find("#not-visible-icon-#{frameNum}").hide() # checked = false??
    @el.find("#marked-icon-#{frameNum}").show()
    @el.find("#asteroid-visible-#{frameNum}").prop 'checked', false
    @el.find(".asteroid-visible-#{frameNum}").hide()
    @el.find("#marked-status-#{frameNum}").show().html("Marked!")

  updateIconsForDestroyMark: (frameNum) =>
    @el.find("#number-#{frameNum}").show()
    @el.find(".asteroid-frame-complete-#{frameNum}").prop 'checked', false
    @el.find("#marked-icon-#{frameNum}").hide()
    @el.find(".asteroid-visible-#{frameNum}").show()
    # @el.find("#asteroid-visible-#{frameNum}").prop 'checked', false
    @el.find("#marked-status-#{frameNum}").hide()

  updateIconsForNotVisible: (frameNum) ->
    @asteroidMarkedInFrame[frameNum] = true # frame done ("Marked" is a bit misleading here. Fix later!)
    @el.find(".asteroid-frame-complete-#{frameNum}").prop 'checked', true
    @el.find("#number-#{frameNum}").hide()
    @el.find("#not-visible-icon-#{frameNum}").show()
    @el.find(".asteroid-visible-#{frameNum}").hide()
    @el.find("#marked-status-#{frameNum}").show().html("Not Visible")

  showAllTrackingIcons: ->
    for frameNum in [0...@numFrames]
      classifier.el.find(".asteroid-frame-#{frameNum}").addClass 'current-asteroid-frame'

  setAsteroidFrame: (frameNum) ->
    @el.find("#frame-slider").val frameNum
    @el.find(".asteroid-visibility-#{frameNum}").show()

    for i in [0...@el.find('.asteroid-frame').length]
      if i is frameNum
        classifier.el.find(".asteroid-frame-#{i}").addClass 'current-asteroid-frame'
      else
        classifier.el.find(".asteroid-frame-#{i}").removeClass 'current-asteroid-frame'

  onClickAsteroidDone: ->
    @removeGhostMarks()
    @currSighting.displaySummary()
    if @currSighting.allSightings.length is 0
      @currSighting = null
    else
      @finishButton.prop 'disabled', false
      @setOfSightings.push @currSighting

    @resetAsteroidCheckboxes()
    @setState 'whatKind'

  resetAsteroidCheckboxes: ->
    @asteroidMarkedInFrame = [null, null, null, null]
    for i in [0...@numFrames]
      @el.find(".asteroid-checkbox").prop 'checked', false
      @el.find("#marked-icon-#{i}").hide()
      @el.find("#marked-status-#{i}").hide()
      @el.find("#not-visible-icon-#{i}").hide()
      @el.find("#number-#{i}").show()
      @el.find(".asteroid-visible").show()

  onClickNextFrame: ->
    nextFrame = +(document.getElementById('frame-slider').value) + 1
    if nextFrame is @numFrames then @onClickFourUp() else @activateFrame(nextFrame) 

  onClickCancel: ->
    @resetMarkingSurfaces() if @state is 'asteroidTool' or 'artifactTool'
    @resetAsteroidCheckboxes()
    @setState 'whatKind' # return to initial state

  onClickPlay: ->
    return if @el.hasClass 'playing'  # play only once at a time
    @disableMarkingSurfaces()
    @playButton.attr 'disabled', true
    @el.addClass 'playing'

    iterator = [0...@numFrames].concat [@numFrames-2..0]
    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 500

    # reset after animation complete
    setTimeout (=>
      @el.removeClass 'playing'
      @playButton.attr 'disabled', false
      @enableMarkingSurfaces()
    ), iterator.length * 500

  activateFrame: (frame) ->
    @setAsteroidFrame(frame)
    classifier.el.find(".asteroid-frame-#{frame}").addClass 'current-asteroid-frame'
    return if @el.attr('flicker') is "false"
    @showFrame(frame)
    @el.attr 'data-on-frame', frame

  showFrame: (frame_idx) ->
    @el.find("#frame-id-#{i}").closest("div").hide() for i in [0...@numFrames]
    @el.find("#frame-id-#{frame_idx}").closest("div").show()

  destroyFrames: ->
    image.remove() for image in @el.find('.frame-image')

  onClickInvert: ->
    @invert = !@invert
    @invertButton.toggleClass 'colorme'

    @loadFrames()
    # bring marking tools back to front for each surface
    for surface in @markingSurfaceList
      markElements = surface.el.getElementsByClassName('marking-tool-root')
      for i in [0...markElements.length]
        markElements[0].parentElement.appendChild markElements[0]

  onClickFinishMarking: ->
    radio.checked = false for radio in @classifierTypeRadios
    @sendClassification()
    @destroyFrames()
    Subject.next()
    document.getElementById('frame-slider').value = 0 #reset slider to first frame
    @finishButton.prop 'disabled', true
    @onClickFlicker()

  startLoading: ->
    @el.addClass 'loading'

  stopLoading: ->
    @el.removeClass 'loading'

  sendClassification: ->
    @finishButton.prop 'disabled', true
    @classification.set 'setOfSightings', [@setOfSightings...]
    console?.log JSON.stringify @classification
    @classification.send()

module.exports = Classifier
