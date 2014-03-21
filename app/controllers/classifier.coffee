BaseController        = require 'zooniverse/controllers/base-controller'
User                  = require 'zooniverse/models/user'
Subject               = require 'zooniverse/models/subject'
Sighting              = require '../models/sighting'
loadImage             = require '../lib/load-image'
Classification        = require 'zooniverse/models/classification'
MarkingSurface        = require 'marking-surface'
MarkingTool           = require './marking-tool'
InvertSvg             = require '../lib/invert-svg-image'
tutorialSteps         = require '../lib/tutorial-steps'
createTutorialSubject = require '../lib/create-tutorial-subject'
{ Tutorial }          = require 'zootorial'
translate             = require 't7e'
ChannelCycler         = require 'channel-cycler'

BIG_MODE = !!~location.search.indexOf 'big=1'

KEYS =
  space:  32
  return: 13
  esc:    27
  one:    49
  two:    50
  three:  51
  four:   52

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
    'click button[name="reset"]'            : 'onClickReset'
    'click button[name="next-subject"]'     : 'onClickNextSubject'
    'click button[name="start-tutorial"]'   : 'onStartTutorial'
    'click button[name="cancel"]'           : 'onClickCancel'
    'click button[name="cycle-channels"]'   : 'onClickCycleChannels'
    'click #favorite'                       : 'onClickFavorite'
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

    'click .asteroid-done-screen': ->
      @notify translate 'classifier.rightPanel.asteroidDoneScreen' if @state is 'asteroidTool' and @doneButton.prop('disabled')

    'click .artifact-done-screen': ->
      @notify translate 'classifier.rightPanel.artifactDoneScreen' if @state is 'artifactTool' and @doneButton.prop('disabled')

    'click .finished-screen': ->
      if @state is 'whatKind' and @finishButton.prop("disabled") and !@nextSubjectButton.is(":visible")
        @notify translate 'classifier.finished.finishedButtonScreen'

    'click .right-panel': ->
      if @playTimeout? and @summaryImageContainer.is(':empty')
        @stopPlayingFrames()
        @togglePausePlayIcons()
      else if @cycling
        @cc.destroy()
        @cycling = false
        @playButton.attr 'disabled', false
        @frameSlider.attr 'disabled', false

  elements:
    '.subject'                       : 'subjectContainer'
    '.surfaces-container'            : 'surfacesContainer'
    '.summary-container'             : 'summaryContainer'
    '.frame-image'                   : 'imageFrames'
    'button[name="play-frames"]'     : 'playButton'
    'button[name="invert"]'          : 'invertButton'
    'button[name="flicker"]'         : 'flickerButton'
    'button[name="four-up"]'         : 'fourUpButton'
    'button[name="finish-marking"]'  : 'finishButton'
    'button[name="asteroid-done"]'   : 'doneButton'
    'button[name="asteroid-delete"]' : 'deleteButton'
    'button[name="next-frame"]'      : 'nextFrame'
    'button[name="reset"]'           : 'reset'
    'button[name="next-subject"]'    : 'nextSubjectButton'
    'button[name="cycle-channels"]'  : 'cycleButton'
    'input[name="selected-artifact"]': 'artifactSelector'
    'input[name="classifier-type"]'  : 'classifierTypeRadios'
    '.asteroid-not-visible'          : 'asteroidVisibilityCheckboxes'
    '.asteroid-checkbox'             : 'asteroidCompleteCheckboxes'
    '.current-frame'                 : 'frameSlider'
    '.right-panel'                   : 'rightPanel'
    '.right-panel-summary'           : 'rightPanelSummary'
    '.left-panel'                    : 'leftPanel'
    "#asteroid-count"                : 'asteroidCount'
    '#starbleed-count'               : 'starbleedCount'
    '#hotpixel-count'                : 'hotpixelCount'
    "#notification"                  : 'notification'
    "#favorite"                      : 'favoriteBtn'
    '.summary-image-container'       : 'summaryImageContainer'
    '.known-asteroid-message'        : 'knownAsteroidMessage'

  states:
    whatKind:
      enter: ->
        @disableMarkingSurfaces()
        @summaryContainer.hide()
        # reset asteroid/artifact selector
        for e in @el.find('input[name="classifier-type"]')
          e.checked = false
        @el.find('button[name="to-select"]').addClass 'hidden'
        @el.find('.what-kind').show()

      exit: ->
        @el.find('button[name="to-select"]').removeClass 'hidden'
        @el.find('.what-kind').hide()
        @removeElementsOfClass(".known-asteroid")

    asteroidTool:
      enter: ->
        if @el.attr('flicker') is 'true'
          @activateFrame 0
        else
          @showAllTrackingIcons()
          @nextFrame.hide()
        @enableMarkingSurfaces()
        @currSighting = new Sighting({type:"asteroid"})
        @el.find('.asteroid-classifier').show()
        @doneButton.show()
        @doneButton.prop 'disabled', true
        @finishButton.prop 'disabled', true

      exit: ->
        @disableMarkingSurfaces()
        @el.find('.asteroid-classifier').hide()
        @doneButton.hide()
        @onClickFlicker() unless @el.attr('flicker') is 'true'

    artifactTool:
      enter: ->
        @enableMarkingSurfaces()
        @currSighting = new Sighting({type:"artifact"})
        @el.find('.artifact-classifier').show()
        @nextFrame.hide()
        @doneButton.show()
        @doneButton.prop 'disabled', true
        @finishButton.prop 'disabled', true
      exit: ->
        @disableMarkingSurfaces()
        @el.find('.artifact-classifier').hide()
        @nextFrame.show()
        @doneButton.hide()
        el.checked = false for el in [ @artifactSelector ... ] # reset artifact selector

  constructor: ->
    super
    @asteroidMarkedInFrame = [ null, null, null, null ]
    @playTimeouts = []
    @el.attr tabindex: 0
    @el.attr 'flicker', "true"
    @invert = false
    @cycling = false
    window.classifier = @
    @setOfSightings = []
    @currSighting = null
    @flickerButton.attr 'disabled', true
    @finishButton.prop 'disabled', true
    @createMarkingSurfaces()
    @setState 'whatKind'
    @summaryContainer.hide()
    @rightPanelSummary.hide()
    @nextSubjectButton.hide()
    @tutorial = new Tutorial
      steps: tutorialSteps
      firstStep: 'welcome'
    @tutorial.el.on 'start-tutorial enter-tutorial-step', =>
      translate.refresh @tutorial.el.get 0
    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect
    @Subject = Subject
    @Subject.group = '532b37203ae740fc7a000002'

    console.log @el.find(".frame-image")

  onSelectArtifact: ->
    @currSighting.subType = @artifactSelector.filter(':checked').val()
    if @currSighting.annotations.length > 0 then @doneButton.prop 'disabled', false

  createMarkingSurfaces: ->
    @numFrames = 4
    @markingSurfaceList = new Array
    for i in [0...@numFrames]
      @markingSurfaceList[i] = new MarkingSurface
        tool: MarkingTool
      @markingSurfaceList[i].svg.attr 'viewBox', '256 0 256 256' if BIG_MODE
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

  addGhostMark: (mark) ->
    svgElement = null
    for surface, i in @markingSurfaceList when i isnt +mark.frame
      if @el.attr('flicker') is 'true'
        [xVal, yVal] = [mark.x, mark.y]
      else
        [xVal, yVal] = [mark.x / 2, mark.y / 2]
      svgElement = surface.addShape 'circle', class: "ghost-mark", opacity: 1, cx: xVal, cy: yVal, r: 16, fill: "none", stroke: "#25b4c5", strokewidth: 1
      svgElement.el.setAttribute 'from-frame', mark.frame
      svgElement.el.setAttribute 'from-asteroid', @currSighting.id

  onCreateMark: (mark) =>
    @currSighting.pushSighting mark

  onDestroyMark: (mark) =>
    @destroyMarksInFrame mark.frame
    @updateIconsForDestroyMark mark.frame
    @currSighting.clearSightingsInFrame mark.frame
    @removeElementsOfClass(".ghost-mark")
    if @state is 'asteroidTool' and @currSighting.annotations.length < @numFrames
      @doneButton.prop 'disabled', true
    else if @state is 'artifactTool' and !@currSighting.annotations.length
      @doneButton.prop 'disabled', true

  onCreateTool: (tool) =>
    surfaceIndex = +@markingSurfaceList.indexOf tool.surface
    tool.mark.id = @currSighting.id
    tool.mark.on 'change', =>
      @removeElementsOfClass(".ghost-mark")
      @addGhostMark(tool.mark)

    if @asteroidMarkedInFrame[surfaceIndex]
      @currSighting.clearSightingsInFrame surfaceIndex
      @destroyMarksInFrame(surfaceIndex)
    else
      @el.find(".asteroid-frame-complete-#{surfaceIndex}").prop 'checked', true
      @asteroidMarkedInFrame[surfaceIndex] = true

    switch @state
      when 'asteroidTool'
        tool.setMarkType 'asteroid'
        @doneButton.prop 'disabled', false if @currSighting.annotations.length is @numFrames
      when 'artifactTool'
        tool.setMarkType 'artifact'
        otherFrames = [0...@numFrames].filter (num) -> num isnt surfaceIndex
        @destroyMarksInFrame(frame) for frame in otherFrames
        @doneButton.prop 'disabled', false if @currSighting.annotations and @artifactSelector.filter(':checked').length

    @updateIconsForCreateMark(surfaceIndex)

  onChangeFrameSlider: =>
    frame = document.getElementById('frame-slider').value
    @activateFrame(frame)

  onKeyDown: (e) =>
    return if @playTimeout? or @el.attr('flicker') is 'false' # disable while playing or in 4up
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

  onStartTutorial: =>
    @onClickReset()
    @onClickFlicker()
    # TODO: designate tutorial subject
    # tutorialSubject = createTutorialSubject()
    # tutorialSubject.select()
    @tutorial.start()

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
        width:  if BIG_MODE then '512' else '100%'
        height: if BIG_MODE then '512' else '100%'
        preserveAspectRatio: 'true'
      img_src = if @invert then subject_info.inverted[i] else subject_info.standard[i]
      do (img_src, frameImage)  =>
        loadImage img_src, (img) =>
          frameImage.attr
            'xlink:href': img.src
    @stopLoading()
    @activateFrame 0  # default to first frame after loading

  onClickFourUp: ->
    @el.find("#frame-id-#{i}").closest("div").show() for i in [0...@numFrames]
    element.hide() for element in [@nextFrame, @playButton, @frameSlider, @deleteButton]
    markingSurfaces = document.getElementsByClassName("marking-surface")
    @fourUpButton.attr 'disabled', true
    @flickerButton.attr 'disabled', false
    @el.attr 'flicker', "false"
    @rerenderMarks()
    @showAllTrackingIcons()
    ghostMark.setAttribute 'visibility', 'hidden' for ghostMark in [ @el.find('.ghost-mark')... ]

  onClickFlicker: ->
    markingSurfaces = document.getElementsByClassName("marking-surface")
    element.show() for element in [@nextFrame, @playButton, @frameSlider, @deleteButton]
    @flickerButton.attr 'disabled', true
    @fourUpButton.attr 'disabled', false
    @el.attr 'flicker', "true"
    @rerenderMarks()
    setTimeout => @activateFrame 0
    ghostMark.setAttribute 'visibility', 'visible' for ghostMark in [ @el.find('.ghost-mark')... ]

  onClickCycleChannels: ->
    if @cycling
      @cc.destroy()
      @playButton.attr 'disabled', false
      @frameSlider.attr 'disabled', false
    else
      images = document.querySelectorAll(".frame-image")
      sources = (img.getAttribute('href') for img in images).reverse()
      @cc = new ChannelCycler(sources)
      @subjectContainer.append(@cc.canvas)
      @cc.start()
      @cc.period = 600
      @playButton.attr 'disabled', true
      @frameSlider.attr 'disabled', true
    @cycling = !@cycling

  rerenderMarks: ->
    setTimeout =>
      for surface in @markingSurfaceList
        for tool in surface.tools
          tool.render()

  destroyMarksInFrame: (frame_idx) ->
    for surface in @markingSurfaceList
      for theMark in surface.marks
        theMark?.destroy() if theMark?.frame is frame_idx and theMark?.id is @currSighting.id

  onClickAsteroidNotVisible: (e) ->
    frameNum = +e.target.id.slice(-1)
    visibilityChecked = @asteroidVisibilityCheckboxes[frameNum].checked
    @asteroidMarkedInFrame[frameNum] = true
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
    if @state is 'asteroidTool' and @currSighting.annotations.length is @numFrames
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
    @removeElementsOfClass(".ghost-mark")
    @currSighting.displaySummary()
    if @currSighting.annotations.length is 0
      @currSighting = null
    else
      @finishButton.prop 'disabled', false
      @setOfSightings.push @currSighting
    @resetAsteroidCheckboxes()
    @setState 'whatKind'

  notify: (message) =>
    return if new Date().getTime() - @lastNotifyTime < 3000
    @notification.html(message).fadeIn(300).delay(3000).fadeOut()
    @lastNotifyTime = new Date().getTime()

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
    if nextFrame is @numFrames
      @onClickFourUp()
    else
      @activateFrame(nextFrame)

  onClickReset: ->
    @setOfSightings = []
    @resetMarkingSurfaces()
    @resetAsteroidCheckboxes()
    @finishButton.prop 'disabled', true
    @setState 'whatKind' # return to initial state

  onClickCancel: ->
    @destroyMarksInFrame frame for frame in [0..@numFrames]
    @finishButton.prop 'disabled', if @setOfSightings.length is 0 then true else false
    @resetAsteroidCheckboxes()
    @setState 'whatKind'

  onClickPlay: ->
    currentFrame = +document.getElementById('frame-slider').value
    if @playTimeout? then @stopPlayingFrames() else @startPlayingFrames(currentFrame)
    @togglePausePlayIcons()

  startPlayingFrames: (startingFrame) ->
    startingFrame %= @markingSurfaceList.length
    @activateFrame startingFrame
    @playTimeout = setTimeout (=> @startPlayingFrames startingFrame + 1), 500

  stopPlayingFrames: ->
    clearTimeout @playTimeout
    @playTimeout = null

  togglePausePlayIcons: ->
    @el.find("#play-content").toggle()
    @el.find("#pause-content").toggle()

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
    image.remove?() for image in @el.find('.frame-image')

  onClickInvert: ->
    @invert = !@invert
    @invertButton.toggleClass 'colorme'
    @loadFrames()

    # invert using separate images
    # for surface in @markingSurfaceList
    #   markElements = surface.el.getElementsByClassName('marking-tool-root')
    #   for i in [0...markElements.length]
    #     markElements[0].parentElement.appendChild markElements[0]

    # invert using svg inverter - implement when cross origin ready
    images = document.getElementsByClassName('frame-image')
    InvertSvg(image) for image in images

  onClickFinishMarking: ->
    console.log "onClickFinishedMarking()"
    radio.checked = false for radio in @classifierTypeRadios
    @showSummary()
    @sendClassification()

  showSummary: ->
    console.log 'showSummary()'
    @resetMarkingSurfaces() # remove previous marks 
    @knownAsteroidMessage.hide() 
    console.log @Subject.current.metadata.known_objects
    
    objectsData = @Subject.current.metadata.known_objects 
    for frame, i in ['0001'] when objectsData[frame] isnt undefined # display only first frame
      for knownObject, i in [objectsData[frame]...] when knownObject.good_known #and knownObject.object is '(161969)'        
        @knownAsteroidMessage.show()
        # console.log 'knownObject (',knownObject.x,',',knownObject.y,'): ', knownObject
        radius = 10
        x = Math.round(knownObject.x)/256 * 190
        y = Math.round(knownObject.y)/256 * 190
        for surface in [@markingSurfaceList...]
          surface.addShape 'ellipse', class: "known-asteroid", opacity: 0.75, cx: x, cy: y, rx: radius, ry: radius, fill: "none", stroke: "rgb(20,200,20)", 'stroke-width': 2
    
    # # console.log @Subject.current.metadata.known_objects
    # for knownAsteroid in @Subject.current.metadata.known_objects
    #   # console.log 'knownAsteroid: ', knownAsteroid
    #   # console.log 'knownAsteroid.'
    #   xs = (coord.x for coord in knownAsteroid)
    #   ys = (coord.y for coord in knownAsteroid)
    #   x_sum = xs.reduce (sum, x) -> sum + x
    #   y_sum = ys.reduce (sum, y) -> sum + y

    #   # should be changed to @surface.el.offsetWidth, as in marking-tool
    #   x_avg = Math.round(x_sum/@numFrames)/512 * 190
    #   y_avg = Math.round(y_sum/@numFrames)/512 * 190
    #   dx = Math.abs( (Math.max xs...) - (Math.min xs...) )
    #   dy = Math.abs( (Math.max ys...) - (Math.min ys...) )
    #   radius = Math.max( dx, dy, 5)
    #   for surface in [@markingSurfaceList...]
    #     surface.addShape 'ellipse', class: "known-asteroid", opacity: 0.75, cx: x_avg, cy: y_avg, rx: radius, ry: radius, fill: "none", stroke: "rgb(20,200,20)", 'stroke-width': 2
    
    @el.attr 'flicker', 'true'
    @surfacesContainer.children().clone().appendTo(@summaryImageContainer)
    element.hide() for element in [@surfacesContainer, @playButton, @frameSlider, @finishButton, @rightPanel.find('.answers'), @cycleButton]
    @startPlayingFrames(0)
    @populateSummary()
    @leftPanel.find(".answers:lt(5)").css 'pointer-events', 'none' #disable everything but guide
    element.show() for element in [@rightPanelSummary, @summaryContainer, @nextSubjectButton]

  objectIsEmpty: (obj) ->
    for key of obj
      if obj.hasOwnProperty(key)
        return false
    return true

  populateSummary: ->
    asteroidCount = (@setOfSightings.filter (s) -> s.type is 'asteroid').length
    starbleedCount = (@setOfSightings.filter (s) -> s.subType is 'starbleed').length
    hotpixelCount = (@setOfSightings.filter (s) -> s.subType is 'hotpixel').length
    @asteroidCount.html("<span class='big-num'>#{asteroidCount}</span>"+ "<br>" + "Asteroid#{if asteroidCount is 1 then '' else 's'}")
    @starbleedCount.html("<span class='big-num'>#{starbleedCount}</span>" + "<br>" + "Star Bleed#{if starbleedCount is 1 then '' else 's'}")
    @hotpixelCount.html("<span class='big-num'>#{hotpixelCount}</span>"+ "<br>" + "Hotpixel#{if hotpixelCount is 1 then '' else 's'} / Cosmic Ray#{if hotpixelCount is 1 then '' else 's'}")

  trainingRate: ->
    count = zooniverse.models.User.current?.project?.classification_count or 0
    count += zooniverse.models.Classification.sentThisSession

    if count < 10
      1 / 5
    else if count < 20
      1 / 10
    else if count < 50
      1 / 20
    else
      1 / 50

  shouldShowTraining: ->
    Math.random() < @trainingRate()

  onClickNextSubject: ->
    @removeElementsOfClass(".known-asteroid")
    element.hide() for element in [@summaryContainer, @nextSubjectButton, @rightPanelSummary]
    @summaryImageContainer.empty()
    @leftPanel.find(".answers:lt(5)").css 'pointer-events', 'auto'
    @stopPlayingFrames()
    element.show() for element in [@surfacesContainer, @finishButton, @rightPanel.find('.answers'), @cycleButton]
    @destroyFrames()

    if @shouldShowTraining()
      app.api.get('projects/asteroid/groups/532b37203ae740fc7a000001/subjects').then (subjects) ->
        subject = new zooniverse.models.Subject subjects[0]
        queued = zooniverse.models.Subject.instances.pop()
        zooniverse.models.Subject.instances.unshift queued
        subject.select()
    else
      Subject.next()

    document.getElementById('frame-slider').value = 0
    @finishButton.prop 'disabled', true
    @onClickFlicker()
    @setOfSightings = []

  onClickFavorite: ->
    @classification.favorite = !@classification.favorite
    @favoriteBtn.toggleClass 'favorited'
    if @classification.favorite
      @notify "<span style='color: #4cc500;'>Added to favorites</span>"
    else
      @notify "Removed from favorites"

  startLoading: ->
    @el.addClass 'loading'

  stopLoading: ->
    @el.removeClass 'loading'

  removeElementsOfClass: (class_name) ->
    element.parentNode.removeChild(element) for element in [@el.find(class_name)...]

  evaluateAnnotations: (P_ref) ->
    xs = []
    ys = []
    P = null
    d = null
    x_sum = null
    y_sum = null
    for sighting in [@setOfSightings...] when sighting.type is "asteroid"
      for annotation, i in sighting.annotations
        xs[i] = annotation.x
        ys[i] = annotation.y
        x_sum += xs[i]
        y_sum += ys[i]
      x_avg = Math.round(x_sum/sighting.annotations.length)
      y_avg = Math.round(y_sum/sighting.annotations.length)
      P = {x: x_sum, y: y_sum}
      d = @dist(P,P_ref)
      if d <= 20
        console.log 'Awesome job!'
      else
        console.log 'You disappoint me.'

  dist: (P1,P2) ->
    Math.sqrt ( Math.pow(P1.x-P2.x,2) + Math.pow(P1.y-P2.y,2) )

  sendClassification: ->
    @finishButton.prop 'disabled', true
    @classification.set 'setOfSightings', [@setOfSightings...]
    console?.log JSON.stringify @classification
    @classification.send()

module.exports = Classifier
