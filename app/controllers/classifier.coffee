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

        # disable until (asteroid complete)
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
    @allSurfaces = []
    @asteroidMarkedInFrame = []
    @playTimeouts = []
    @el.attr tabindex: 0
    # @setClassification @classification
    @el.attr 'flicker', "true"
    artifactSubtype = "other" # not sure what this is for?
    
    @setState 'whatKind'
    @invert = false
    @currFrameIdx = 0

    window.classifier = @
    @setOfSightings = []
    @currAsteroid = null
    # @artifacts = [] # not used yet!

    # default to flicker mode
    @el.find('.four-up').hide()
    @flickerButton.attr 'disabled', true
    @finishButton.prop 'disabled', true

    # create master surface -- "flicker view"
    @masterMarkingSurface = new MarkingSurface
      tool: MarkingTool
    @masterMarkingSurface.svgRoot.attr 'id', "classifier-svg-root-master"
    this.masterMarkingSurface.el.id = "surface-master"
    @flickerContainer.append @masterMarkingSurface.el
    @masterMarkingSurface.on 'create-tool', (tool) =>
      console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
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
        # this could probably be cleaned up
        numFramesComplete = 0
        for status in @asteroidMarkedInFrame
          if status is true
            numFramesComplete++
        if numFramesComplete is 4
          @doneButton.prop 'disabled', false
      tool.controls.controller.setMark(@currFrameIdx, @currAsteroid.id)

    #create 4-up view surfaces
    @numFrames = 4
    @markingSurfaceList = new Array
    for i in [0...@numFrames]
      @markingSurfaceList[i] = new MarkingSurface
        tool: MarkingTool
      @markingSurfaceList[i].svgRoot.attr 'id', "classifier-svg-root-#{i}"
      @fourUpContainer.append @markingSurfaceList[i].el
      @markingSurfaceList[i].on 'create-tool', (tool) =>
        tool.controls.controller.setMark(@currFrameIdx, @currAsteroid.id)

    @allSurfaces = [@masterMarkingSurface, @markingSurfaceList...]

    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

    @masterMarkingSurface.on "create-mark", @onCreateMark

    for surface in @markingSurfaceList
      surface.on "create-mark", @onCreateMark

    @disableMarkingSurfaces()

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
    # keep a copy of all marks in here
    @finishButton.prop 'disabled', false
    if @asteroidMarkedInFrame[ @currFrameIdx ]
      @currAsteroid.popSighting()
    @currAsteroid.pushSighting mark

    @updateIconsForCreateMark()

    #sync surfaces for 4up
    setTimeout =>
      for surface in @allSurfaces
        theSurface = surface if mark in surface.marks

      for surface in @allSurfaces when surface isnt theSurface
        surface.addTool new theSurface.tool
          surface: surface
          mark: mark

  updateIconsForCreateMark: =>
    frameNum = @currFrameIdx+1
    @el.find("#number-#{frameNum}").hide()
    @el.find("#not-visible-icon-#{frameNum}").hide() # checked = false??
    @el.find("#marked-icon-#{frameNum}").show()
    @el.find(".asteroid-visible-#{frameNum}").hide()
    @el.find("#marked-status-#{frameNum}").html("Marked!")

  renderTemplate: =>
    super

  onChangeFrameSlider: =>
    frame = document.getElementById('frame-slider').value
    @activateFrame(frame)

  onKeyDown: (e) =>
    return if @el.hasClass 'playing'  # disable while playing
    switch e.which
      when KEYS.one   then @activateFrame(0)
      when KEYS.two   then @activateFrame(1)
      when KEYS.three then @activateFrame(2)
      when KEYS.four  then @activateFrame(3)
      when KEYS.space
        @onClickPlay()
        e.preventDefault()

  onUserChange: (e, user) =>
    Subject.next() unless @classification?

  onSubjectFetch: =>
    @startLoading()

  onSubjectSelect: (e, subject) =>
    @resetMarkingSurfaces()
    @classification = new Classification {subject}
    @loadFrames()

  resetMarkingSurfaces: =>
    for surface in @allSurfaces
      # @surface?.marks[0].destroy() until @surface?.marks.length is 0
      surface.reset()

  disableMarkingSurfaces: =>
    for surface in @allSurfaces
      surface.disable()

  enableMarkingSurfaces: =>
    for surface in @allSurfaces
      surface.enable()

  loadFrames: =>
    #TODO  this code could probably be cleaned up
    @destroyFrames()
    subject_info = @classification.subject.location
    frameImages = new Array()

    # create image elements for "master" view
    @frames = for i in [subject_info.standard.length-1..0]
      frame_id = "frame-id-#{i}"
      frameImage = @masterMarkingSurface.addShape 'image',
        id:  frame_id
        class: 'frame-image'
        width: '100%'
        height: '100%'
        preserveAspectRatio: 'true'

      if @invert is true
        img_src = subject_info.inverted[i]
      else
        img_src = subject_info.standard[i]

      #load the image for this frame
      do (img_src, frameImage)  =>
        loadImage img_src, (img) =>
        frameImage.attr
          'xlink:href': img_src          # get images from api
          # 'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    # create image elements for 4-up view
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

      if @invert is true
        img_src = subject_info.inverted[i]
      else
        img_src = subject_info.standard[i]

      do (img_src, frameImage)  =>
        loadImage img_src, (img) =>
        frameImage.attr
          'xlink:href': img_src          # get images from api
          # 'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    @activateFrame 0  # default to first frame after loading
    @stopLoading()

  onClickFourUp: ->
    console.log "4-up"
    @el.find(".four-up").show()
    @el.find(".flicker").hide()

    setTimeout =>
      for surface in @markingSurfaceList
        for tool in surface.tools
          tool.render()

    markingSurfaces = document.getElementsByClassName("marking-surface")
    @resizeElements(markingSurfaces, 254) # image sizing for 4up view

    @fourUpButton.attr 'disabled', true
    @flickerButton.attr 'disabled', false
    @el.attr 'flicker', "false"

  onClickFlicker: ->
    console.log "Flicker"
    @el.find(".flicker").show()
    @el.find(".four-up").hide()

    setTimeout => 
      for tool in @masterMarkingSurface.tools
        tool.render()

    markingSurfaces = document.getElementsByClassName("marking-surface")
    @resizeElements(markingSurfaces, 512) # image sizing for 4up view

    @flickerButton.attr 'disabled', true
    @fourUpButton.attr 'disabled', false

    @el.attr 'flicker', "true"

  resizeElements: (elements, newSize) ->
    for element in elements
      # element.style["-webkit-transform"] = "scale(0.5)"
      element.style.width = newSize + "px"
      element.style.height = newSize + "px"

  destroyMarksInFrame: (frame_idx, curr_ast_id) ->
    # debugger
    console.log "Destroy marks in frame: ", frame_idx
    for surface in @allSurfaces
      for theMark in surface.marks
        # console.log 'current frame: ', frame_idx
        # console.log theMark.frame
        if theMark?.frame is frame_idx and theMark?.asteroid_id is @currAsteroid.id
          theMark?.destroy()

  onClickAsteroidNotVisible: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    console.log 'onClickAsteroidNotVisible: '

    # get checkbox states
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
    # @el.find(".asteroid-visible-#{frameNum}").hide()
    @el.find("#marked-status-#{frameNum}").html("Not Visible")

  setAsteroidFrame: (frame_idx) ->
    return unless @state is 'asteroidTool'

    # show asteroid-visibility only on current frame
    @el.find(".asteroid-visibility-#{frame_idx}").show()

    # reminder: frame numbers not zero-indexed in view
    frameNum = frame_idx + 1
    for i in [1..@el.find('.asteroid-frame').length] 
      if i is frameNum
        classifier.el.find(".asteroid-frame-#{i}").addClass 'current-asteroid-frame'
      else
        classifier.el.find(".asteroid-frame-#{i}").removeClass 'current-asteroid-frame'

  onClickAsteroidDone: ->
    @currAsteroid.displaySummary() 

    # this should check for 'not-visible' attributes too!!!
    if @currAsteroid.sightingCount is 0
      @currAsteroid = null  # destroy asteroid
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
    @setCurrentFrameIdx(@currFrameIdx+1)
    @activateFrame(@currFrameIdx)

  onClickCancel: ->
    if @state is 'asteroidTool'
      @resetMarkingSurfaces
      surface?.reset() for surface in @allSurfaces
    @resetAsteroidVisibilityCheckboxes()
    @resetAsteroidCompleteCheckboxes()
    @setState 'whatKind' # return to initial state

  onClickPlay: ->
    return if @el.hasClass 'playing'  # play only once at a time
    @disableMarkingSurfaces
    @playButton.attr 'disabled', true
    @el.addClass 'playing'
    
    # flip the images back and forth once
    last = @classification.subject.location.standard.length - 1
    iterator = [0...last].concat [last...-1]

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 500

    @el.removeClass 'playing'
    @playButton.attr 'disabled', false
    @enableMarkingSurfaces

  activateFrame: (@active) ->
    @active = modulus +@active, @classification.subject.location.standard.length
    @setAsteroidFrame(@active)
    @showFrame(@active)

  setCurrentFrameIdx: (frame_idx) ->
    @currFrameIdx = frame_idx
    @el.attr 'data-on-frame', @currFrameIdx

  showFrame: (frame_idx) ->
    @el.find("#frame-id-#{frame_idx}").hide() for i in [0...4]
    @el.find("#frame-id-#{frame_idx}").show()
    @el.find("#frame-slider").val frame_idx
    @setCurrentFrameIdx(frame_idx)

  destroyFrames: ->
    for image, i in @el.find('.frame-image')
      image.remove()

  onClickInvert: ->
    if @invert is true
      @invert = false
      @invertButton.removeClass 'colorme'
    else
      @invert = true
      @invertButton.addClass 'colorme'

    @loadFrames()
    @showFrame(@currFrameIdx) # unless @currFrameIdx is undefined
    # bring marking tools back to front for each surface
    for surface in [ @masterMarkingSurface, @markingSurfaceList... ]
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