BaseController = require 'zooniverse/controllers/base-controller'
User = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'
Sighting = require '../models/sighting'
modulus = require '../lib/modulus'

loadImage = require '../lib/load-image'
Classification = require 'zooniverse/models/classification'
MarkingSurface = require 'marking-surface'
MarkingTool = require './marking-tool'
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
  './dev-subjects-images/registered_1.png'
  './dev-subjects-images/registered_2.png'
  './dev-subjects-images/registered_3.png'
  './dev-subjects-images/registered_4.png'
]

NEXT_DEV_SUBJECT = ->
  #console.log "In NEXT_DEV_SUBJECT()"
  DEV_SUBJECTS.push DEV_SUBJECTS.shift()
  DEV_SUBJECTS[0]

class Classifier extends BaseController
  className: 'classifier'
  template: require '../views/classifier'
  currFrameIdx = 0

  events:
    'click button[name="play-frames"]'    : 'onClickPlay'
    'click button[name="invert"]'         : 'onClickInvert'
    'click button[name="finish-marking"]' : 'onClickFinishMarking'
    'click button[name="four-up"]'        : 'onClickFourUp'
    'click button[name="flicker"]'        : 'onClickFlicker'
    'click button[name="next-frame"]'     : 'onClickNextFrame'
    'click button[name="asteroid-done"]'  : 'onClickAsteroidDone'
    'click button[name="cancel"]'         : 'onClickCancel'
    'change input[name="current-frame"]'  : 'onChangeFrameSlider'
    'keydown'                             : 'onKeyDown'
    'change .asteroid-not-visible'        : 'onClickAsteroidNotVisible'
    'click .marking-surface'              : 'onClickMarkingSurface'

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

    'change input[name="selected-artifact"]': ->      
      @artifactSubtype = @selectedArtifactRadios.filter(':checked').val() 
      
    'click button[name="delete"]': ->
      @tool.mark.destroy()

    'click button[name^="done"]': ->
      @tool.deselect()

  elements:
    '.subject'                       : 'subjectContainer'
    '.flicker'                       : 'flickerContainer'
    '.four-up'                       : 'fourUpContainer'
    '.frame-image'                   : 'imageFrames'   # not being used (yet?)
    '.current-frame input'           : 'frameRadioButtons'
    'input[name="current-frame"]'    : 'currentFrameRadioButton'
    'button[name="play-frames"]'     : 'playButton'
    'button[name="invert"]'          : 'invertButton'
    'button[name="flicker"]'         : 'flickerButton'
    'button[name="four-up"]'         : 'fourUpButton'
    'button[name="finish-marking"]'  : 'finishButton'
    'button[name="asteroid-done"]'   : 'doneButton'
    'button[name="next-frame"]'      : 'nextFrame'
    'button[name="cancel"]'          : 'cancel'
    'input[name="selected-artifact"]': 'selectedArtifactRadios'  
    'input[name="classifier-type"]'  : 'classifierTypeRadios'
    '.asteroid-not-visible'          : 'asteroidVisibilityCheckboxes'
    '.asteroid-checkbox'             : 'asteroidCompleteCheckboxes'

  states:
    whatKind:
      enter: ->
        # console.log "STATE: \'whatKind/enter\'"
        @disableMarkingSurfaces()

        # reset asteroid/artifact selector
        for e in @el.find('input[name="classifier-type"]')
          e.checked = false

        @el.find('button[name="to-select"]').addClass 'hidden' 
        @el.find('.what-kind').show()

      exit: ->
        # console.log "STATE: \'whatKind/exit\'"
        @el.find('button[name="to-select"]').removeClass 'hidden'
        @el.find('.what-kind').hide()

    asteroidTool:
      enter: ->
        @activateFrame 0
        # create new asteroid
        @currAsteroid = new Sighting({type:"asteroid"})
        @enableMarkingSurfaces()
        @el.find('.asteroid-classifier').show()
        @finishButton.hide()
        @doneButton.show()

        @doneButton.prop 'disabled', true

      exit: ->
        @disableMarkingSurfaces()
        @el.find('.asteroid-classifier').hide() 
        @doneButton.hide()
        @finishButton.show()

    artifactTool:
      enter: ->
        @enableMarkingSurfaces()
        @el.find('.artifact-classifier').show()
      exit: ->
        @disableMarkingSurfaces()
        @el.find('.artifact-classifier').hide() 

  constructor: ->
    super
    @asteroidMarkedInFrame = []
    @playTimeouts = []
    @el.attr tabindex: 0
    @el.attr 'flicker', "true"

    @setState 'whatKind'
    @invert = false
    @currFrameIdx = 0

    window.classifier = @
    @setOfSightings = []
    @currAsteroid = null

    @el.find('.four-up').show()
    @flickerButton.attr 'disabled', true
    @finishButton.prop 'disabled', true

    @numFrames = 4
    @markingSurfaceList = new Array
    for i in [0...@numFrames]
      @markingSurfaceList[i] = new MarkingSurface
        tool: MarkingTool
      @markingSurfaceList[i].svgRoot.attr 'id', "classifier-svg-root-#{i}"
      @fourUpContainer.append @markingSurfaceList[i].el
      @markingSurfaceList[i].on 'create-tool', (tool) =>
        if @state is 'asteroidTool'
          # enforce one mark per frame
          if @asteroidMarkedInFrame[@currFrameIdx]
            # console.log 'frame already marked!'
            @destroyMarksInFrame @currFrameIdx, @currAsteroid.id
          else 
            # console.log 'frame was empty'
            @el.find(".asteroid-frame-complete-#{@currFrameIdx+1}").prop 'checked', true
            @asteroidMarkedInFrame[@currFrameIdx] = true
          # enable 'done' button only if all frames marked
          numFramesComplete = 0
          for status in @asteroidMarkedInFrame
            if status is true
              numFramesComplete++
          if numFramesComplete is 4
            @doneButton.prop 'disabled', false
        tool.controls.controller.setMark(@currFrameIdx, @currAsteroid.id)

    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

    for surface in @markingSurfaceList
      surface.on "create-mark", @onCreateMark

    @disableMarkingSurfaces()

  renderTemplate: =>
    super

  onClickMarkingSurface: (e) =>
    elementId = e.target.id #frame-id-(x)
    @setAsteroidFrame(elementId.charAt elementId.length-1)

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

  onCreateMark:(mark) =>
    console.log 'mark created'
    @finishButton.prop 'disabled', false
    if @asteroidMarkedInFrame[ @currFrameIdx ]
      @currAsteroid.popSighting()
    @currAsteroid.pushSighting mark
    @updateIconsForCreateMark()

  updateIconsForCreateMark: =>
    frameNum = @currFrameIdx+1
    @el.find("#number-#{frameNum}").hide()
    @el.find("#not-visible-icon-#{frameNum}").hide() # checked = false??
    @el.find("#marked-icon-#{frameNum}").show()
    @el.find(".asteroid-visible-#{frameNum}").hide()
    @el.find("#marked-status-#{frameNum}").html("Marked!")

  onChangeFrameSlider: =>
    frame = document.getElementById('frame-slider').value
    @activateFrame(frame)
    @showFrame(frame)

  onKeyDown: (e) =>
    return if @el.hasClass 'playing'  # disable while playing
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
    console.log "disabled should have been called" #TODO

  enableMarkingSurfaces: =>
    surface.enable() for surface in @markingSurfaceList

  loadFrames: =>
    @destroyFrames()
    subject_info = @classification.subject.location

    numImages = subject_info.standard.length
    for i in [0...numImages]
      frame_id = "frame-id-#{i}"
      frameImage =
        @markingSurfaceList[i].addShape 'image',
        id:  frame_id
        class:  'frame-image'
        width:  '100%'
        height: '100%'
        preserveAspectRatio: 'true'

      img_src = if @invert is true then subject_info.inverted[i] else subject_info.standard[i]

      do (img_src, frameImage)  =>
        loadImage img_src, (img) =>
        frameImage.attr
          'xlink:href': img_src          # get images from api
          # 'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    @activateFrame 0  # default to first frame after loading
    @stopLoading()

  onClickFourUp: ->
    @el.find("#frame-id-#{i}").closest("div").show() for i in [0...4]

    markingSurfaces = document.getElementsByClassName("marking-surface")
    @resizeElements(markingSurfaces, 254) # image sizing for 4up view

    @enableSliderControls true
    @fourUpButton.attr 'disabled', true
    @flickerButton.attr 'disabled', false
    @el.attr 'flicker', "false"
    @rerenderMarks()

  onClickFlicker: ->
    markingSurfaces = document.getElementsByClassName("marking-surface")
    @resizeElements(markingSurfaces, 512) # image sizing for 4up view

    @enableSliderControls false
    @flickerButton.attr 'disabled', true
    @fourUpButton.attr 'disabled', false
    @el.attr 'flicker', "true"
    @rerenderMarks()
    setTimeout => @activateFrame 0

  rerenderMarks: ->
    setTimeout =>
      for surface in @markingSurfaceList
        for tool in surface.tools
          tool.render()

  enableSliderControls: (bool) ->
    document.getElementById("frame-slider").disabled = bool
    @playButton.attr 'disabled', bool

  resizeElements: (elements, newSize) ->
    for element in elements
      element.style.width = newSize + "px"
      element.style.height = newSize + "px"

  destroyMarksInFrame: (frame_idx, curr_ast_id) ->
    console.log "Destroy marks in frame: ", frame_idx
    for surface in @markingSurfaceList
      for theMark in surface.marks
        if theMark?.frame is frame_idx and theMark?.asteroid_id is @currAsteroid.id
          theMark?.destroy()

  onClickAsteroidNotVisible: ->
    console.log 'onClickAsteroidNotVisible: '

    completeChecked   = @asteroidCompleteCheckboxes[@currFrameIdx].checked
    visibilityChecked = @asteroidVisibilityCheckboxes[@currFrameIdx].checked

    if @asteroidMarkedInFrame[@currFrameIdx]
      @currAsteroid.clearSightingsInFrame @currFrameIdx
      @destroyMarksInFrame @currFrameIdx, @currAsteroid.id

    @updateIconsForNotVisible()

    newAnnotation =
      frame: @currFrameIdx
      x: null
      y: null
      visible: false
      inverted: @invert
    @currAsteroid.pushSighting newAnnotation

  updateIconsForNotVisible: ->
    frameNum = @currFrameIdx + 1
    @asteroidMarkedInFrame[@currFrameIdx] = true # frame done ("Marked" is a bit misleading here. Fix later!)
    @el.find(".asteroid-frame-complete-#{frameNum}").prop 'checked', true
    @el.find("#number-#{frameNum}").toggle()
    @el.find("#not-visible-icon-#{frameNum}").show()
    @el.find("#marked-status-#{frameNum}").html("Not Visible")

  setAsteroidFrame: (frame_idx) ->
    return unless @state is 'asteroidTool'
    @setCurrentFrameIdx(frame_idx)

    @el.find("#frame-slider").val frame_idx
    @el.find(".asteroid-visibility-#{frame_idx}").show()

    frameNum = frame_idx + 1
    for i in [1..@el.find('.asteroid-frame').length] 
      if i is frameNum
        classifier.el.find(".asteroid-frame-#{i}").addClass 'current-asteroid-frame'
      else
        classifier.el.find(".asteroid-frame-#{i}").removeClass 'current-asteroid-frame'

  onClickAsteroidDone: ->
    @currAsteroid.displaySummary() 

    if @currAsteroid.sightingCount is 0
      @currAsteroid = null
    else
      @setOfSightings.push @currAsteroid

    @asteroid_num++
    @resetAsteroidCompleteCheckboxes()
    @resetAsteroidVisibilityCheckboxes()
    @setState 'whatKind'

  resetAsteroidCompleteCheckboxes: ->
    @asteroidMarkedInFrame = []
    for i in [1..@numFrames]
      @el.find(".asteroid-checkbox").prop 'checked', false
      @el.find("#marked-icon-#{i}").hide()
      @el.find(".asteroid-checkbox").show()
      @el.find(".asteroid-visible-#{i}").show()

  resetAsteroidVisibilityCheckboxes: ->
    for i in [1..@numFrames]
      @el.find(".asteroid-not-visible").prop 'checked', false
      @el.find(".asteroid-not-visible").show()
      @el.find("#marked-status-#{i}").html("Not Visible?")
      @el.find("#not-visible-icon-#{i}").hide()
      @el.find("#number-#{i}").show()

  onClickNextFrame: ->
    return if @currFrameIdx is 3
    @currFrameIdx++
    @activateFrame(@currFrameIdx)

  onClickCancel: ->
    if @state is 'asteroidTool'
      @resetMarkingSurfaces
      surface?.reset() for surface in @markingSurfaceList
    @resetAsteroidVisibilityCheckboxes()
    @resetAsteroidCompleteCheckboxes()
    @setState 'whatKind' # return to initial state

  onClickPlay: ->
    return if @el.hasClass 'playing'  # play only once at a time
    @disableMarkingSurfaces()
    @playButton.attr 'disabled', true
    @el.addClass 'playing'

    last = @classification.subject.location.standard.length - 1
    iterator = [0...last].concat [last...-1]

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 500

    @el.removeClass 'playing'
    @playButton.attr 'disabled', false
    @enableMarkingSurfaces()

  activateFrame: (@active) ->
    @setAsteroidFrame(@active)
    return if @el.attr('flicker') is "false"
    @showFrame(@active)

  setCurrentFrameIdx: (frame_idx) ->
    @currFrameIdx = frame_idx
    @el.attr 'data-on-frame', @currFrameIdx

  showFrame: (frame_idx) ->
    @el.find("#frame-id-#{i}").closest("div").hide() for i in [0...4]
    @el.find("#frame-id-#{frame_idx}").closest("div").show()

  destroyFrames: ->
    image.remove() for image in @el.find('.frame-image')

  onClickInvert: ->
    if @invert is true
      @invert = false
      @invertButton.removeClass 'colorme'
    else
      @invert = true
      @invertButton.addClass 'colorme'

    @loadFrames()
    @activateFrame(@currFrameIdx)
    # bring marking tools back to front for each surface
    for surface in @markingSurfaceList
      markElements = surface.el.getElementsByClassName('marking-tool-root')
      for i in [0...markElements.length]
        markElements[0].parentElement.appendChild markElements[0]

  onClickFinishMarking: ->
    radio.checked = false for radio in @classifierTypeRadios
    @sendClassification()
    @destroyFrames()
    @destroyMarksInFrame(i) for i in [0,1,2,3]
    Subject.next()
    document.getElementById('frame-slider').value = 0 #reset slider to first frame
    @finishButton.prop 'disabled', true
    @onClickFlicker()

  rescale: =>
    setTimeout =>
      over = innerHeight - document.body.clientHeight
      @subjectContainer.height parseFloat(@subjectContainer.height()) + over

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