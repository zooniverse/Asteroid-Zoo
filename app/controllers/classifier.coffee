BaseController = require 'zooniverse/controllers/base-controller'
User = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'
modulus = require '../lib/modulus'

loadImage = require '../lib/load-image'
Classification = require 'zooniverse/models/classification'
MarkingSurface = require 'marking-surface'
MarkingTool = require './marking-tool'
ClassificationSummary = require './classification-summary'

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
  console.log "In NEXT_DEV_SUBJECT()"
  DEV_SUBJECTS.push DEV_SUBJECTS.shift()
  DEV_SUBJECTS[0]

class Classifier extends BaseController
  className: 'classifier'
  template: require '../views/classifier'
  
  events:
    'click button[name="play-frames"]'    : 'onClickPlay'
    'click button[name="invert"]'         : 'onClickInvert'
    'click button[name="finish-marking"]' : 'onClickFinishMarking'
    'click button[name="four-up"]'        : 'onClickFourUp'
    'click button[name="flicker"]'        : 'onClickFlicker'
    'click input[name="current-frame"]'   : 'onClickRadioButton'

  elements:
    '.subject'                      : 'subjectContainer'
    '.flicker'                      : 'flickerContainer'
    '.four-up'                      : 'fourUpContainer'
    '.frame-image'                  : 'imageFrames'   # not being used (yet?)
    '.current-frame input'          : 'frameRadioButtons'
    'input[name="current-frame"]'   : 'currentFrameRadioButton'
    'button[name="play-frames"]'    : 'playButton'
    'button[name="invert"]'         : 'invertButton'
    'button[name="flicker"]'        : 'flickerButton'
    'button[name="four-up"]'        : 'fourUpButton'
    'button[name="finish-marking"]' : 'finishButton'

    'keydown': (e) ->
      return if @el.hasClass 'playing'  # disable while playing
      switch e.which
        when KEYS.one
          @showFrame(0)
        when KEYS.two
          @showFrame(1)
        when KEYS.three
          @showFrame(2)
        when KEYS.four
          @showFrame(3)
        when KEYS.space
          @onClickPlay()

  constructor: ->
    super
    @playTimeouts = []                   # for image_changer
    @el.attr tabindex: 0                 # ...
    # @setClassification @classification  # ...

    @invert = false
    @setCurrentFrameIdx 0
    
    window.classifier = @
  
    # default to flicker mode on initialization
    @el.find('.four-up').hide()
    @flickerButton.attr 'disabled', true

    @numFrames = 4
    @markingSurface = new Array

    # create marking surfaces for frames
    # note: 0 index is "master"
    for i in [0..@numFrames]
      console.log "Creating frame " + i 
      @markingSurface[i] = new MarkingSurface
        tool: MarkingTool
      @markingSurface[i].svgRoot.attr 'id', "classifier-svg-root-#{i}"

      if i is 0 # master
        @flickerContainer.append @markingSurface[i].el
      else   
        @fourUpContainer.append @markingSurface[i].el

      @markingSurface[i].on 'create-tool', (tool) =>
        tool.controls.controller.setMark(@currentFrameIdx)

    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

  # activate: ->
  #   # setTimeout @rescale, 100

  renderTemplate: =>
    super

  onUserChange: (e, user) =>
    Subject.next() unless @classification?

  onSubjectFetch: =>
    @startLoading()

  onSubjectSelect: (e, subject) =>
    console.log "insides onSubjectSelect()"

    #reset the marking surface and load classifcation
    # @markingSurface.reset()
    
    @resetMarkingSurfaces()

    @classification = new Classification {subject}
    @loadFrames()

  resetMarkingSurfaces: =>
    for i in [0..@numFrames]
      @markingSurface[i].reset()

  disableMarkingSurfaces: =>
    for i in [0..@numFrames]
      @markingSurface[i].disable()

  enableMarkingSurfaces: =>
    for i in [0..@numFrames]
      @markingSurface[i].enable()

  loadFrames: =>

    # this code could probably be cleaned up


    @destroyFrames()
    subject_info = @classification.subject.location
    frameImages = new Array()

    # create image elements for "master" view
    #todo @frames doesn't get referenced, what is it doing?
    @frames = for i in [subject_info.standard.length-1..0]
      frame_id = "frame-id-#{i}"
      frameImage = @markingSurface[0].addShape 'image',
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
    for i in [1..subject_info.standard.length]
      frameImage = @markingSurface[i].addShape 'image',
        id:  frame_id
        class:  'frame-image'
        width:  '100%'
        height: '100%'
        preserveAspectRatio: 'true'

      if @invert is true
        img_src = subject_info.inverted[i-1]
      else
        img_src = subject_info.standard[i-1]

      do (img_src, frameImage)  => 
        loadImage img_src, (img) =>
        frameImage.attr
          'xlink:href': img_src          # get images from api
          # 'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

      # need to edit .marking-surface CSS and create separate flicker vs. 4-up styles
      # frameImage.attr 'transform', 'scale(0.75)'  
      

    @stopLoading()

    #@markingSurface.enable() # why is this here again?
    # console.log "Showing frame: " + @currentFrameIdx
    # @showFrame(@currentFrameIdx) unless @currentFrameIdx is null

  onClickFourUp: ->
    console.log "4-up"
    @el.find(".four-up").show()
    @el.find(".flicker").hide()

    @fourUpButton.attr 'disabled', true
    @flickerButton.attr 'disabled', false

  onClickFlicker: ->
    console.log "Flicker"
    @el.find(".flicker").show()
    @el.find(".four-up").hide()

    @flickerButton.attr 'disabled', true
    @fourUpButton.attr 'disabled', false
    

  onClickRadioButton: ->
    for i in [0...@frameRadioButtons.length]
      if @frameRadioButtons[i].checked
        @showFrame(i)

  onClickPlay: ->
    return if @el.hasClass 'playing'  # play only once at a time  
    
    @playButton.attr 'disabled', true
    @el.addClass 'playing'
    @disableMarkingSurfaces()
    # @markingSurface.disable()   # no marking while playing

    # flip the images back and forth once
    last = @classification.subject.location.standard.length - 1
    iterator = [0...last].concat [last...-1]

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 333

    @playTimeouts.push setTimeout @pause, i * 333

  pause: =>
    clearTimeout timeout for timeout in @playTimeouts
    @playTimeouts.splice 0
    @playButton.attr 'disabled', false
    @el.removeClass 'playing'
    @enableMarkingSurfaces()
    # @markingSurface.enable()

  activateFrame: (@active) ->
    @active = modulus +@active, @classification.subject.location.standard.length
    @showFrame(@active)

  setCurrentFrameIdx: (frame_idx) ->
    @currentFrameIdx = frame_idx
    # find way to communicate current frame with marking tool
    @el.attr 'data-on-frame', @currentFrameIdx

  hideAllFrames: ->
    for i in [0...@frameRadioButtons.length]
      @hideFrame(i)
    
  showFrame: (frame_idx) ->
    @hideAllFrames()


    # this is a dodgy way of getting it done!
    # @el.find("frame-id-#{frame_idx}").show()
    document.getElementById("frame-id-#{frame_idx}").style.visibility="visible"
  
    @frameRadioButtons[frame_idx].checked = "true"
    @setCurrentFrameIdx(frame_idx)

    # console.log "show frame: " + frame_idx
    
  hideFrame: (frame_idx) ->
    # id="frame-id-#{frame_idx}"
    # @el.find(id).hide()
    document.getElementById("frame-id-#{frame_idx}").style.visibility="hidden"
    @frameRadioButtons[frame_idx].checked = "true"

  destroyFrames: ->
    # console.log "Destroying frames..."
    for image, i in @el.find('.frame-image')
      image.remove()

  onClickInvert: ->
    if @invert is true
      @invert = false
      # console.log "invert: false"
    else
      @invert = true
      # console.log "invert: true"

    @loadFrames()
    @showFrame(@currentFrameIdx) # unless @currentFrameIdx is undefined

    # bring tools back to front
    @el.find('.svg-root').append @el.find('.marking-tool-root')

  onClickFinishMarking: ->
    @showSummary()

  rescale: =>
    setTimeout =>
      over = innerHeight - document.body.clientHeight
      @subjectContainer.height parseFloat(@subjectContainer.height()) + over

  startLoading: ->

    @el.addClass 'loading'

  stopLoading: ->
    @el.removeClass 'loading'

  showSummary: ->
    console.log JSON.stringify @classification    
    
    # ALL THIS IS BROKEN FOR NOW
    # @sendClassification()
    # classificationSummary = new ClassificationSummary {@classification}
    # classificationSummary.el.appendTo @el
    # @el.addClass 'showing-summary'
    # classificationSummary.on 'destroying', =>
    #   @destroyFrames()
    #   @el.removeClass 'showing-summary'
    #   Subject.next()

    # setTimeout =>
    #   classificationSummary.show()

  sendClassification: ->
    @classification.set 'marks', [@markingSurface.marks...]
    console?.log JSON.stringify @classification
    @classification.send()

module.exports = Classifier 
