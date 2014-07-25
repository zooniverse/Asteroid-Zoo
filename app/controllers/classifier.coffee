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
$ = window.jQuery

KEYS =
  space:  32
  return: 13
  esc:    27
  one:    49
  two:    50
  three:  51
  four:   52

DEV_MODE = !!~location.search.indexOf 'dev=1'
MAIN_SUBJECT_GROUP = if DEV_MODE then "532b37203ae740fc7a000002" else "53a84ea22333ae04f6000003"
TRAINING_SUBJECT_GROUP = if DEV_MODE then "532b37203ae740fc7a000001" else "53a84ea22333ae04f6000001"

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
    'click button[name="guide"]'            : 'onClickGuide'
    'click .asteroid-classifier form'       : 'onClickAsteroidClassifierForm'
    'click #favorite'                       : 'onClickFavorite'
    'change input[name="frame-slider"]'     : 'onChangeFrameSlider'
    'change .asteroid-not-visible'          : 'onClickAsteroidNotVisible'

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
      @notify translate('span', 'classifier.rightPanel.asteroidDoneScreen', class: 'red-text') if @state is 'asteroidTool' and @doneButton.prop('disabled')

    'click .artifact-done-screen': ->
      @notify translate('span', 'classifier.rightPanel.artifactDoneScreen', class: 'red-text') if @state is 'artifactTool' and @doneButton.prop('disabled')

    'click .marking-surface': ->
      @notify translate('span', 'classifier.rightPanel.whatKindScreen', class: 'red-text') if @state is 'whatKind' and !@inSummaryView()

    'click .channel-cycler': ->
      if @cycling and !@tutorial.el.hasClass "open"
        @setState 'asteroidTool'
        @onClickCycleChannels()

    'click .finished-screen': ->
      if @state is 'whatKind' and @finishButton.prop("disabled") and !@inSummaryView()
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
    'input[name="classifier-type"]'  : 'classifierTypeRadios'
    '.asteroid-not-visible'          : 'asteroidVisibilityCheckboxes'
    '.asteroid-checkbox'             : 'asteroidCompleteCheckboxes'
    '.current-frame'                 : 'frameSlider'
    '.right-panel'                   : 'rightPanel'
    '.right-panel-summary'           : 'rightPanelSummary'
    '.left-panel'                    : 'leftPanel'
    "#asteroid-count"                : 'asteroidCount'
    '#artifact-count'               : 'artifactCount'
    "#notification"                  : 'notification'
    "#favorite"                      : 'favoriteBtn'
    "#favorite-message"              : 'favoriteMessage'
    "#spotters-guide"                : 'spottersGuide'
    '.summary-image-container'       : 'summaryImageContainer'
    '.known-asteroid-message'        : 'knownAsteroidMessage'
    '.asteroid-loader'               : 'loader'

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
        if @inFlickerView()
          @activateFrame 0
        else
          @showAllTrackingIcons()
          @nextFrame.hide()
        @enableMarkingSurfaces()
        @currSighting = new Sighting({
          type:"asteroid",
          inverted: @invert
        })
        @el.find('.asteroid-classifier').show()
        @doneButton.show()
        @doneButton.prop 'disabled', true
        @finishButton.prop 'disabled', true

      exit: ->
        @disableMarkingSurfaces()
        @el.find('.asteroid-classifier').hide()
        @doneButton.hide()
        @onClickFlicker() unless @inFlickerView()

    artifactTool:
      enter: ->
        @enableMarkingSurfaces()
        @currSighting = new Sighting({type:"artifact", inverted: @invert})
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

  constructor: ->
    super
    @asteroidMarkedInFrame = [ null, null, null, null ]
    @playTimeouts = []
    @el.attr tabindex: 0
    @el.attr 'flicker', "true"
    @invert = false
    @cycling = false
    @guideShowing = false
    window.classifier = @
    @recordedClickEvents = []
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
      parent: @el

    @tutorial.el.on 'start-tutorial enter-tutorial-step', =>
      translate.refresh @tutorial.el.get 0

    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onSubjectNoMore
    Subject.on 'get-next', @onSubjectGettingNext
    @Subject = Subject
    @Subject.group = MAIN_SUBJECT_GROUP
    @loader.fadeIn()
    $("html").on "keydown", @onKeyDown

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

  addGhostMark: (mark) ->
    svgElement = null
    for surface, i in @markingSurfaceList when i isnt +mark.frame
      if @inFlickerView()
        [xVal, yVal] = [mark.x, mark.y]
      else
        [xVal, yVal] = [mark.x / 2, mark.y / 2]
      svgElement = surface.addShape 'circle', class: "ghost-mark", opacity: 1, cx: xVal, cy: yVal, r: 16, fill: "none", stroke: "#25b4c5", strokewidth: 1
      svgElement.el.setAttribute 'from-frame', mark.frame
      svgElement.el.setAttribute 'from-asteroid', @currSighting.id

  onCreateMark: (mark) =>
    mark.inverted = @invert
    @currSighting.pushSighting mark

  onDestroyMark: (mark) =>
    @destroyMarksInFrame mark.frame
    @updateIconsForDestroyMark mark.frame
    @currSighting.clearSightingsInFrame mark.frame
    @removeElementsOfClass(".ghost-mark")
    if @state is 'asteroidTool' and @currSighting.labels.length < @numFrames
      @doneButton.prop 'disabled', true
    else if @state is 'artifactTool' and !@currSighting.labels.length
      @doneButton.prop 'disabled', true
    @deleteButton.prop 'disabled', true

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
        @doneButton.prop 'disabled', false if @currSighting.labels.length is @numFrames
        @deleteButton.prop 'disabled', false
      when 'artifactTool'
        tool.setMarkType 'artifact'
        otherFrames = [0...@numFrames].filter (num) -> num isnt surfaceIndex
        @destroyMarksInFrame(frame) for frame in otherFrames
        @doneButton.prop 'disabled', false if @currSighting.labels

    @updateIconsForCreateMark(surfaceIndex)

  onChangeFrameSlider: =>
    frame = +document.getElementById('frame-slider').value
    @activateFrame(frame)

  onKeyDown: (e) =>
    return if @framesShouldNotBePlayed()
    switch e.which
      when KEYS.one   then @activateFrame(0)
      when KEYS.two   then @activateFrame(1)
      when KEYS.three then @activateFrame(2)
      when KEYS.four  then @activateFrame(3)
      when KEYS.space
        e.preventDefault()
        @onClickPlay()

  framesShouldNotBePlayed: ->
    !@active() or @notInFlickerView() or @inSummaryView()

  inFlickerView: -> @el.attr('flicker') is 'true'

  notInFlickerView: -> @el.attr('flicker') is 'false'

  inSummaryView: -> @summaryImageContainer.is(':visible')

  active: -> @el.hasClass 'active'

  handleFirstVisit: ->
    if @usersFirstVisit() and @active()
      User.current?.setPreference("first_visit", "false") if User.current
      @tutorial.start()

  usersFirstVisit: ->
    User.current?.preferences?.asteroid?.first_visit isnt "false"

  onUserChange: (e, user) =>
    Subject.next() unless @classification?
    @handleFirstVisit()

  onSubjectFetch: =>
    @startLoading()

  onSubjectSelect: (e, subject) =>
    # Subject.current.classification_count = 0 # DEBUG CODE: fake brand new subject
    if DEV_MODE and subject
      console.log  subject.zooniverse_id
    if @subjectUnseen()
      @notification.html translate('span', 'classifier.subjectUnseenMessage', class: 'bold-text green-text')
      @notification.fadeIn()
    else
      @notification.html('') # show nothing

    @resetMarkingSurfaces()
    @classification = new Classification {subject}
    @loadFrames()
    @loader.hide()
    @el.find('#talk-link').attr 'href', subject.talkHref()

  onSubjectNoMore: =>
    @el.prepend translate 'classifier.noMoreSubjects'
    @loader.hide()

  onSubjectGettingNext: =>
    @loader.fadeIn()

  onStartTutorial: =>
    clickEvent = { event: 'tutorialClicked', timestamp: (new Date).toUTCString() }
    @recordedClickEvents.push clickEvent
    @onClickReset()
    @onClickFlicker()
    # TODO: designate tutorial subject
    tutorialSubject = createTutorialSubject()
    tutorialSubject.select()
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
    numberOfFrames = Math.min subject_info.standard.length, 4
    for i in [0...numberOfFrames]
      frame_id = "frame-id-#{i}"
      frameImage =
        @markingSurfaceList[i].addShape 'image',
        id:  frame_id
        class:  'frame-image'
        width:  '100%'
        height: '100%'

      img_src = if @invert then subject_info.inverted[i] else subject_info.standard[i]

      @loadFrame frameImage, img_src

    @stopLoading()
    @activateFrame 0  # default to first frame after loading

  loadFrame: (image, src, attempts = 1) ->
    loadImage(src).then (img) =>
      if attempts < 10 and !!~img.src.indexOf (new Array 100).join 'A'
        setTimeout =>
          @loadFrame image, src, attempts + 1
      else if attempts >= 10
        console.log("Gave up on #{src}")
        Subject.next()
      else
        image.attr 'xlink:href', img.src

  onClickFourUp: ->
    @el.find("#frame-id-#{i}").closest("div").show() for i in [0...@numFrames]
    element.hide() for element in [@nextFrame, @playButton, @frameSlider, @deleteButton]
    @fourUpButton.attr 'disabled', true
    @flickerButton.attr 'disabled', false
    @el.attr 'flicker', "false"
    @rerenderMarks()
    @showAllTrackingIcons()
    ghostMark.setAttribute 'visibility', 'hidden' for ghostMark in [ @el.find('.ghost-mark')... ]

  onClickFlicker: ->
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
      @cycleButton.removeClass 'active'
    else
      promisedImgs = (loadImage src for src in @classification.subject.location.standard)
      $.when(promisedImgs...).then (imgs...) =>
        if @cycling
          sources = imgs.map (img) -> img.src
          @cc = new ChannelCycler(sources)
          @subjectContainer.append(@cc.canvas)
          @cc.start()
          @cycleButton.addClass 'active'
          @cc.period = 600
          @playButton.attr 'disabled', true
          @frameSlider.attr 'disabled', true
    clickEvent = { event: 'cycleActivated', timestamp: (new Date).toUTCString() }
    @recordedClickEvents.push clickEvent
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
    if @state is 'asteroidTool' and @currSighting.labels.length is @numFrames
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
    # @currSighting.displaySummary()
    if @currSighting.labels.length is 0
      @currSighting = null
    else
      @finishButton.prop 'disabled', false
      @setOfSightings.push @currSighting
    @resetAsteroidCheckboxes()
    @setState 'whatKind'

  notify: (message, time_displayed = 3000) =>
    return if new Date().getTime() - @lastNotifyTime < 3000
    @notification.html(message).fadeIn(300).delay(time_displayed).fadeOut(300, =>
      if @subjectUnseen()
        @notification.html translate('span', 'classifier.subjectUnseenMessage', class: 'bold-text green-text')
        @notification.fadeIn()
    )
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
    startingFrame %= @surfacesContainer.find(".marking-surface:has(.frame-image)").length

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
    return if @notInFlickerView()
    @showFrame(frame)
    @el.attr 'data-on-frame', frame
    @nextFrame.prop 'disabled', if frame is (@numFrames-1) then true else false
    setTimeout =>
      if @currSighting?.labels
        @deleteButton.prop 'disabled', (frame not in (mark.frame for mark in @currSighting?.labels when mark.x? and mark.y?))

  showFrame: (frame_idx) ->
    @el.find("#frame-id-#{i}").closest("div").hide() for i in [0...@numFrames]
    @el.find("#frame-id-#{frame_idx}").closest("div").show()

  destroyFrames: ->
    image.remove?() for image in @el.find('.frame-image')

  onClickInvert: ->
    @invert = !@invert
    @invertButton.toggleClass 'colorme'
    @loadFrames()

    for surface in @markingSurfaceList
      markElements = surface.el.getElementsByClassName('marking-tool-root')
      for i in [0...markElements.length]
        markElements[0].parentElement.appendChild markElements[0]

  onClickFinishMarking: ->
    radio.checked = false for radio in @classifierTypeRadios
    @onClickCycleChannels() if @cycling
    @showSummary()
    @favoriteBtn.hide()
    @sendClassification()
    # hide all marks
    mark.setAttribute 'visibility', 'hidden' for mark in [@el.find(".mark")...]

  onClickAsteroidClassifierForm: (e) =>
    frameIndex = @integersInString($(e.target).closest("div").attr("class"))
    @activateFrame(frameIndex)

  integersInString: (str) ->
    +str.replace(/[^\d.]/g, '')

  subjectUnseen: ->
    if Subject?.current.classification_count is 0
      return true
    return false

  showSummary: ->
    @knownAsteroidMessage.hide()

    # reset summary text
    @el.find("#known-asteroid-message").html translate 'classifier.containsKnownAsteroidMessage'
    @el.find("#summary-header").html translate 'classifier.thankYouMessage'

    @summarizeKnownObjects()

    @el.attr 'flicker', 'true'
    @surfacesContainer.find(".marking-surface:has(.frame-image)").clone().appendTo(@summaryImageContainer)
    element.hide() for element in [@surfacesContainer, @playButton, @frameSlider, @finishButton, @rightPanel.find('.answers'), @cycleButton]
    @startPlayingFrames(0)
    @populateSummary()
    @leftPanel.find(".answers:lt(5)").css 'pointer-events', 'none' #disable everything but guide
    element.show() for element in [@rightPanelSummary, @summaryContainer, @nextSubjectButton]

  #helper method to showSummary
  summarizeKnownObjects: ->
    objectsData = @Subject.current?.metadata?.known_objects
    processedKnowns = new Object
    #known object names will be concatentated here
    allKnownsLabel = ""

    for frame, objects of objectsData
      for knownObject in objects  when knownObject.good_known
        objectName = knownObject.object

        #update if seen already
        if processedKnowns[objectName]
          @updateSeenObject(processedKnowns[objectName], knownObject)
        else # or save off the first time seen
          processedKnowns[objectName] = @firstSeen(knownObject)
           #append the object name to the label
          allKnownsLabel += objectName
      #if we found known object show message

    #display the known objects message message only if
    @knownAsteroidMessage.show() if Object.keys(processedKnowns).length > 0

    #write out the object names of good knowns
    @el.find("#metadata-knowns").html allKnownsLabel

    #for each known object
    for objectName, processedKnown of processedKnowns
      processedKnown = @averageKnownPoints(processedKnown)
      radius = 10
      #process marking surface
      for surface in [@markingSurfaceList...]
        surface.addShape 'ellipse', class: "known-asteroid", opacity: 0.75, cx: processedKnown.x, cy: processedKnown.y, rx: radius, ry: radius, fill: "none", stroke: "rgb(20,200,20)", 'stroke-width': 2
      #and evaluate annotations for users marking known objects
      @evaluateAnnotations(processedKnown.P_ref)

  #helper method to summarizeKnownObjects
  firstSeen:(knownObject) ->
    x = Math.round(knownObject.x)
    y = Math.round(knownObject.y)
    {counter: 1, x_accum: x, y_accum: y}

  #helper method to summarizeKnownObjects
  updateSeenObject:(processedKnown, knownObject) ->
    #accumulate x and y values when seen
    processedKnown.x_accum = processedKnown.x_accum + Math.round(knownObject.x)
    processedKnown.y_accum = processedKnown.y_accum + Math.round(knownObject.y)
    #increment seen counter
    processedKnown.counter = processedKnown.counter  + 1

  #helper method to summarizeKnownObjects
  averageKnownPoints: (processedKnown) ->
    HALF_WINDOW_HEIGHT = 256
    SCALING_FACTOR =  190  #aribtirary value less than HALF_WINDOW_HEIGHT
    #average the values of x and y
    processedKnown.x = processedKnown.x_accum /processedKnown.counter
    processedKnown.y = processedKnown.y_accum /processedKnown.counter
    # now the P_ref object can be set
    # grab the point reference before scale
    processedKnown.P_ref = x:  processedKnown.x, y:  processedKnown.y
    #apply scaling
    processedKnown.x =  processedKnown.x * (SCALING_FACTOR / HALF_WINDOW_HEIGHT )
    processedKnown.y =  processedKnown.y * (SCALING_FACTOR / HALF_WINDOW_HEIGHT )
    processedKnown

  evaluateAnnotations: (P_ref) ->
    # console.log 'GROUND TRUTH: (',P_ref.x,',',P_ref.y,')'
    xs = []
    ys = []
    P = null
    d = null
    x_sum = null
    y_sum = null
    for sighting in [@setOfSightings...] when sighting.type is "asteroid"
      for label, i in sighting.labels
        xs[i] = Math.round(label.x_actual)
        ys[i] = Math.round(label.y_actual)
        x_sum += xs[i]
        y_sum += ys[i]
      x_avg = Math.round(x_sum/sighting.labels.length)
      y_avg = Math.round(y_sum/sighting.labels.length)
      P = {x: x_avg, y: y_avg}
      d = @dist(P,P_ref)
      # console.log 'REPORTED ASTEROID: (',x_avg,',',y_avg,'), distance: ',d,''

      if d <= 20 # GREAT JOB!
        @foundAsteroid = true
        @el.find("#known-asteroid-message").html translate 'classifier.foundKnownAsteroidMessage'
        @el.find("#summary-header").html translate 'classifier.goodJob'

  dist: (P1,P2) ->
    Math.sqrt ( Math.pow(P1.x-P2.x,2) + Math.pow(P1.y-P2.y,2) )

  populateSummary: ->
    asteroidCount = (@setOfSightings.filter (s) -> s.type is 'asteroid').length
    artifactCount = (@setOfSightings.filter (s) -> s.type is 'artifact').length
    @asteroidCount.html("<span class='big-num'>#{asteroidCount}</span>"+ "<br>" + "Asteroid#{if asteroidCount is 1 then '' else 's'}")
    @artifactCount.html("<span class='big-num'>#{artifactCount}</span>" + "<br>" + "Artifact#{if artifactCount is 1 then '' else 's'}")

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

  onClickGuide: ->
    if @guideShowing
      @spottersGuide.slideUp()
    else
      @spottersGuide.show()
      $("html, body").animate scrollTop: @spottersGuide.offset().top - 20, 500
      clickEvent = { event: 'guideActivated', timestamp: (new Date).toUTCString() }
      @recordedClickEvents.push clickEvent
    @guideShowing = !@guideShowing

  onClickNextSubject: ->
    @removeElementsOfClass(".known-asteroid")
    element.hide() for element in [@summaryContainer, @nextSubjectButton, @rightPanelSummary]
    @summaryImageContainer.empty()
    @leftPanel.find(".answers:lt(5)").css 'pointer-events', 'auto'
    @favoriteBtn.show().removeClass 'favorited'
    @favoriteMessage.html translate "classifier.favorite.add"
    @stopPlayingFrames()
    element.show() for element in [@surfacesContainer, @finishButton, @rightPanel.find('.answers'), @cycleButton]

    if @shouldShowTraining()
      Subject.group = TRAINING_SUBJECT_GROUP
      Subject.fetch limit: 1, (subject) ->
        Subject.current?.destroy()
        subject[0].select()
        Subject.group = MAIN_SUBJECT_GROUP
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
      @notify translate 'span', 'classifier.favorite.addMessage', class: 'green-text'
      @favoriteMessage.html translate "classifier.favorite.remove"
    else
      @notify translate 'span', 'classifier.favorite.removeMessage', class: 'red-text'
      @favoriteMessage.html translate "classifier.favorite.add"

  startLoading: ->
    @el.addClass 'loading'

  stopLoading: ->
    @el.removeClass 'loading'

  removeElementsOfClass: (class_name) ->
    element.parentNode.removeChild(element) for element in [@el.find(class_name)...]

  sendClassification: ->
    @finishButton.prop 'disabled', true
    @classification.set 'recordedClickEvents', [@recordedClickEvents...]
    @classification.set 'setOfSightings', [@setOfSightings...]
    @classification.set 'classification_count', Subject.current.classification_count
    # console.log JSON.stringify( @classification ) # DEBUG CODE
    @classification.send()
    @recordedClickEvents = []

module.exports = Classifier
