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
          @showFrame("frame-id-0")
        when KEYS.two
          @hideAllFrames()
          @showFrame("frame-id-1")
        when KEYS.three
          @hideAllFrames()
          @showFrame("frame-id-2")
        when KEYS.four
          @hideAllFrames()
          @showFrame("frame-id-3")
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
      frame_id = "frame-id-#{i}"
      frameImage = @markingSurface.addShape 'image',
        id:  frame_id
        class: 'frame-image'
        width: '100%'
        height: '100%'
        preserveAspectRatio: 'true'


      # radio_id = "radio-id-#{i}"
      # @markingSurface.addShape 'input', 
      #   id:  radio_id
      #   type: 'radio'
      #   value: "#{i}"

     
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
    console.log "Radio button pressed!"

  onClickPlay: ->
    @play()

  play: ->

    console.log "Number of radio buttons: " + @frameRadioButtons.length

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
    console.log "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    for image, i in @el.find('.frame-image')
      # console.log "SHOWING FRAME: " + @active
      @hideFrame(image.id)

    @showFrame("frame-id-"+@active)


  # A VERY DODGY WAY OF HIDING/SHOWING FRAMES:
  hideAllFrames: ->
    @hideFrame("frame-id-0")
    @hideFrame("frame-id-1")
    @hideFrame("frame-id-2")
    @hideFrame("frame-id-3")
    
  showFrame: (img_id) ->
    console.log "SHOW " + img_id
    document.getElementById(img_id).style.visibility="visible"

  hideFrame: (img_id) ->
    #console.log "HIDE " + img_id
    document.getElementById(img_id).style.visibility="hidden"

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
    # @classification.send()

module.exports = Classifier 