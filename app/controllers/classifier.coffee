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
    'click button[name="finish-marking"]' : 'onClickFinishMarking'
    'click input[name="current-frame"]'   : 'onClickRadioButton'
    # 'click button[name="no-tags"]'        : 'onClickNoTags'

    'keydown': (e) ->
      switch e.which
        when KEYS.one
          @hideAllFrames()
          @showFrame(0)
        when KEYS.two
          @hideAllFrames()
          @showFrame(1)
        when KEYS.three
          @hideAllFrames()
          @showFrame(2)
        when KEYS.four
          @hideAllFrames()
          @showFrame(3)
        when KEYS.space
          @play()

  elements:
    '.subject'                      : 'subjectContainer'
    '.frame-image'                  : 'imageFrames'   # not being used (yet?)
    '.current-frame input'          : 'frameRadioButtons'
    'input[name="current-frame"]'   : 'currentFrameRadioButton'
    'button[name="play-frames"]'    : 'playButton'
    'button[name="finish-marking"]' : 'finishButton'
    'button[name="no-tags"]'        : 'noTagsButton'

  constructor: ->
    super
    @playTimeouts = []                  # for image_changer
    @el.attr tabindex: 0                # ...
    #@setClassification @classification  # ...
    
    window.classifier = @
    @markingSurface = new MarkingSurface
      tool: MarkingTool
    @markingSurface.svgRoot.attr 'id', 'classifier-svg-root'
    @subjectContainer.append @markingSurface.el

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

    #reset the marking surface and load classifcation
    @markingSurface.reset()
    @classification = new Classification {subject}


    # create image elements  
    framesCount =  subject.location.standard.length
    for i in [framesCount-1..0] by -1
      # # add image element to the marking surface
      frame_idx = "frame-id-#{i}"
      frameImage = @markingSurface.addShape 'image',
        id:  frame_idx
        class: 'frame-image'
        width: '100%'
        height: '100%'
        preserveAspectRatio: 'true'

     
      img_src = subject.location.standard[i]
      #load the image for this frame
      do (img_src, frameImage)  => 
        loadImage img_src, (img) =>
        frameImage.attr
          #'xlink:href': img_src          # get images from api
          'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    @stopLoading()
    @markingSurface.enable()

  onClickRadioButton: ->
    for i in [0...@frameRadioButtons.length]
      if @frameRadioButtons[i].checked
        @showFrame(i)

  onClickPlay: ->
    @play()

  play: ->
    console.log "IMAGES:"
    for src, i in DEV_SUBJECTS
      console.log "  Frame-" + i + ": " + src

    # flip the images back and forth once
    last = @classification.subject.location.standard.length - 1
    iterator = [0...last].concat [last...-1]

    @el.addClass 'playing'

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 333

    @playTimeouts.push setTimeout @pause, i * 333

  pause: =>
    clearTimeout timeout for timeout in @playTimeouts
    @playTimeouts.splice 0
    @el.removeClass 'playing'

  activateFrame: (@active) ->
    @active = modulus +@active, @classification.subject.location.standard.length
    for image, i in @el.find('.frame-image')
      # console.log "SHOWING FRAME: " + @active
      @hideFrame(i)

    @showFrame(@active)

  hideAllFrames: ->
    for i in [0...@frameRadioButtons.length]
      console.log "hide frame: " + i
      @hideFrame(i)
    # NEW CHANGES --STI  
    # @hideFrame(0)
    # @hideFrame(1)
    # @hideFrame(2)
    # @hideFrame(3)
    
  showFrame: (frame_idx) ->
    console.log "show frame: " + frame_idx
    @hideAllFrames()
    document.getElementById("frame-id-#{frame_idx}").style.visibility="visible"
    console.log "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    @frameRadioButtons[frame_idx].checked = "true"

  hideFrame: (frame_idx) ->
    document.getElementById("frame-id-#{frame_idx}").style.visibility="hidden"
    @frameRadioButtons[frame_idx].checked = "true"

  destroyFrames: ->
    console.log "Derstroying frames..."
    for image, i in @el.find('.frame-image')
      image.remove()

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
    @sendClassification()
    classificationSummary = new ClassificationSummary {@classification}
    classificationSummary.el.appendTo @el
    @el.addClass 'showing-summary'
    classificationSummary.on 'destroying', =>
      @destroyFrames()
      @el.removeClass 'showing-summary'
      Subject.next()

    setTimeout =>
      classificationSummary.show()

  sendClassification: ->
    @classification.set 'marks', [@markingSurface.marks...]
    console?.log JSON.stringify @classification
    @classification.send()

module.exports = Classifier 
