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

# for keybindings
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
  currFrameIdx = 0 # keeps track of current (zero-indexed) frame

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

    #'click button[name="done"]': ->
      
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
    '.asteroid-frame-complete'       : 'asteroidCompleteCheckboxes'

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
        # console.log "STATE: \'asteroidTool/enter\'"
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
        # console.log "STATE: \'asteroidTool/exit\'"
        @disableMarkingSurfaces()
        @el.find('.asteroid-classifier').hide() 
        @doneButton.hide()
        @finishButton.show()

    artifactTool:
      enter: ->
        # console.log "STATE: \'artifactTool/enter\'"
        @enableMarkingSurfaces()
        @el.find('.artifact-classifier').show()
      exit: ->
        # console.log "STATE: \'artifactTool/exit\'"
        @disableMarkingSurfaces()
        @el.find('.artifact-classifier').hide() 

  constructor: ->
    super
    @allSurfaces = []
    @asteroidMarkedInFrame = []
    @playTimeouts = []                   # for image_changer
    @el.attr tabindex: 0                 # ...
    # @setClassification @classification  # ...
    @el.attr 'flicker', "true"
    artifactSubtype = "other" # not sure what this is for?
    
    @setState 'whatKind'      # set initial state
    @invert = false
    @currFrameIdx = 0

    window.classifier = @

    # asteroid and artifact "containers"
    @setOfSightings = []
    @currAsteroid = null
    # @artifacts = [] # not used yet!

    # default to flicker mode on initialization
    @el.find('.four-up').hide()
    @flickerButton.attr 'disabled', true
    @finishButton.prop 'disabled', true

    #######################################################
    # create marking surfaces for frames
    #######################################################
    # create master surface -- "flicker view"
    @masterMarkingSurface = new MarkingSurface
      tool: MarkingTool
    @masterMarkingSurface.svgRoot.attr 'id', "classifier-svg-root-master"
    this.masterMarkingSurface.el.id = "surface-master"
    @flickerContainer.append @masterMarkingSurface.el
    @masterMarkingSurface.on 'create-tool', (tool) =>
      if @state is 'asteroidTool'
        # enforce one mark per frame
        if @asteroidMarkedInFrame[@currFrameIdx]
          console.log 'frame already marked!'
          # undo last mark
          @masterMarkingSurface.marks.pop().destroy()
        else 
          console.log 'marked'
          # new mark
          @el.find(".asteroid-frame-complete-#{@currFrameIdx+1}").prop 'checked', true
          @asteroidMarkedInFrame[@currFrameIdx] = true

        # enable 'done' button only if all frames marked
        numFramesComplete = 0
        for status in @asteroidMarkedInFrame
          console.log status
          if status is true
            numFramesComplete++

        if numFramesComplete is 4
          @doneButton.prop 'disabled', false

        # DEBUG CODE
        # console.log @asteroidMarkedInFrame


      tool.controls.controller.setMark(@currFrameIdx)
        
    #create 4-up view surfaces
    @numFrames = 4
    @markingSurfaceList = new Array
    for i in [0...@numFrames]
      @markingSurfaceList[i] = new MarkingSurface
        tool: MarkingTool
      @markingSurfaceList[i].svgRoot.attr 'id', "classifier-svg-root-#{i}"
      @fourUpContainer.append @markingSurfaceList[i].el
      @markingSurfaceList[i].on 'create-tool', (tool) =>
        tool.controls.controller.setMark(@currFrameIdx)

    @allSurfaces = [@masterMarkingSurface, @markingSurfaceList...]

    #######################################################
    #  API event bindings
    #######################################################
    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

    #######################################################
    # adding a listener for each marking surface
    # on the master
    @masterMarkingSurface.on "create-mark", @onCreateMark

    # on the 4-up list
    for surface in @markingSurfaceList
      surface.on "create-mark", @onCreateMark

    @disableMarkingSurfaces()

  #######################################################
  # FINITE STATE MACHINE CONTROLLER
  #######################################################
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
    # keep a copy of all marks in here
    @finishButton.prop 'disabled', false
    if @asteroidMarkedInFrame[ @currFrameIdx ]
      @currAsteroid.popSighting()
    @currAsteroid.pushSighting mark

    # locate the surface this frame coresponds to
    setTimeout =>
      for surface in @allSurfaces
        theSurface = surface if mark in surface.marks

      for surface in @allSurfaces when surface isnt theSurface
        surface.addTool new theSurface.tool
          surface: surface
          mark: mark

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
    #reset the marking surface and load classifcation
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

  #######################################
  # ASTEROID TRACKING METHODS
  #######################################
  destroyMarksInFrame: (frame_idx) ->
    console.log "Destroy marks in frame: ", frame_idx
    for surface in @allSurfaces
      for foomark in surface.marks
        if foomark.frame is frame_idx
          foomark.destroy()
        

  onClickAsteroidNotVisible: ->
    console.log '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    console.log 'onClickAsteroidNotVisible: '
    console.log 'completeChecked: ', @asteroidCompleteCheckboxes[@currFrameIdx].checked
    console.log 'visibleChecked: ', @asteroidVisibilityCheckboxes[@currFrameIdx].checked

    # get checkbox states
    completeChecked   = @asteroidCompleteCheckboxes[@currFrameIdx].checked
    visibilityChecked = @asteroidVisibilityCheckboxes[@currFrameIdx].checked


    if @asteroidMarkedInFrame[@currFrameIdx]
      @currAsteroid.clearSightingsInFrame @currFrameIdx
      @destroyMarksInFrame @currFrameIdx

    # this needs work!
    # handle checkmark behavior
    if @asteroidMarkedInFrame[@currFrameIdx] and visibilityChecked
      console.log 'case 1'
      @asteroidVisibilityCheckboxes[@currFrameIdx].checked = true
      @asteroidCompleteCheckboxes[@currFrameIdx].checked = true
    else if @asteroidMarkedInFrame[@currFrameIdx] and not visibilityChecked
      console.log 'case 2'
      @currAsteroid.clearSightingsInFrame @currFrameIdx
      @asteroidVisibilityCheckboxes[@currFrameIdx].checked = false
      @asteroidCompleteCheckboxes[@currFrameIdx].checked = false
      @currAsteroid.clearSightingsInFrame @currFrameIdx
      @destroyMarksInFrame @currFrameIdx

    newAnnotation =
      frame: @currFrameIdx
      x: null
      y: null
      visible: false
      inverted: @invert
    @currAsteroid.pushSighting newAnnotation

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
    
    # reset
    @resetAsteroidFrameCheckboxes()
    @setState 'whatKind'
    
  resetAsteroidFrameCheckboxes: ->
      # reset checkboxes and radio buttons
      @asteroidMarkedInFrame = []
      for i in [1..@numFrames]
        @el.find(".asteroid-checkbox").prop 'checked', false

  onClickNextFrame: ->
    return if @currFrameIdx is 3
    @setCurrentFrameIdx(@currFrameIdx+1)
    @activateFrame(@currFrameIdx)

  # needs to be fixed!!!
  onClickCancel: ->
    if @state is 'asteroidTool'

      @resetMarkingSurfaces

      # still need to destroy current asteroid marks
      @resetAsteroidFrameCheckboxes()  
    @setState 'whatKind'  # return to initial state

  onClickPlay: ->
    return if @el.hasClass 'playing'  # play only once at a time

    @playButton.attr 'disabled', true
    @el.addClass 'playing'
    @disableMarkingSurfaces()
    # @markingSurfaceList.disable()   # no marking while playing
    # flip the images back and forth once
    last = @classification.subject.location.standard.length - 1
    iterator = [0...last].concat [last...-1]

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 500

    @playTimeouts.push setTimeout @pause, i * 500

  pause: =>
    clearTimeout timeout for timeout in @playTimeouts
    @playTimeouts.splice 0
    @playButton.attr 'disabled', false
    @el.removeClass 'playing'
    @enableMarkingSurfaces()
    # @markingSurfaceList.enable()

  activateFrame: (@active) ->
    @active = modulus +@active, @classification.subject.location.standard.length
    @setAsteroidFrame(@active)
    # update artifact marking
    @showFrame(@active)

  setCurrentFrameIdx: (frame_idx) ->
    @currFrameIdx = frame_idx
    # find way to communicate current frame with marking tool
    @el.attr 'data-on-frame', @currFrameIdx

  hideAllFrames: ->
    for i in [0...4]
      @hideFrame(i)

  showFrame: (frame_idx) ->
    @hideAllFrames()
    document.getElementById("frame-id-#{frame_idx}").style.visibility = "visible"
    document.getElementById("frame-slider").value = frame_idx
    @setCurrentFrameIdx(frame_idx)

  hideFrame: (frame_idx) ->
    document.getElementById("frame-id-#{frame_idx}").style.visibility = "hidden"

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
    #go back to the one up view
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