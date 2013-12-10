BaseController = require 'zooniverse/controllers/base-controller'
User = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'
modulus = require '../lib/modulus'

loadImage = require '../lib/load-image'
Classification = require 'zooniverse/models/classification'
MarkingSurface = require 'marking-surface'
MarkingTool = require './marking-tool'
ClassificationSummary = require './classification-summary'

# SubjectViewer = require './subject-viewer'

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
    # 'click button[name="no-tags"]'        : 'onClickNoTags'
    

  elements:
    '.subject'                      : 'subjectContainer'
    '.frame-image'                  : 'foo123'
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

    # @subjectViewer = new SubjectViewer

    @markingSurface.svgRoot.attr 'id', 'classifier-svg-root'

    @subjectContainer.append @markingSurface.el

    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

    #addEventListener 'resize', @rescale, false

  # activate: ->
  #   # setTimeout @rescale, 100

  onUserChange: (e, user) =>
    Subject.next() unless @classification?

  onSubjectFetch: =>
    @startLoading()

  onSubjectSelect: (e, subject) =>

    #reset the marking surface and load classifcation
    @markingSurface.reset()
    @classification = new Classification {subject}
    framesCount =  subject.location.standard.length
    for i in [0..framesCount-1] by 1
      # # add image element to the marking surface
      frame_id = "frame-id-#{i}"
      frameImage = @markingSurface.addShape 'image',
        id:  frame_id
        class: 'frame-image'
        width: '100%'
        height: '100%'
        preserveAspectRatio: 'none'
     
      img_src = subject.location.standard[i]
      #load the image for this frame
      do (img_src, frameImage)  => 
        loadImage img_src, (img) =>
        frameImage.attr
          #'xlink:href': img_src          # get images from api
          'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    @stopLoading()
    @markingSurface.enable()

  onClickPlay: ->
    @play() # still needs to be built!

  play: ->

    console.log "SUBJECTS:"
    for src, i in DEV_SUBJECTS
      console.log "  SUBJECT-" + i + ": " + src

    # Flip the images back and forth a couple times.
    last = @classification.subject.location.standard.length - 1
    iterator = [0...last].concat [last...0]
    iterator = iterator.concat [0...last].concat [last...0]

    # End half way through.
    iterator = iterator.concat [0...Math.floor(@classification.subject.location.standard.length / 2) + 1]

    @el.addClass 'playing'

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activateFrame index), i * 333

    @playTimeouts.push setTimeout @pause, i * 333

  pause: =>
    clearTimeout timeout for timeout in @playTimeouts
    @playTimeouts.splice 0
    @el.removeClass 'playing'

  # activate: somehow doesn't work. defined somewhere else?
  activateFrame: (@active) ->
    # console.log "Active = " + @active

    # there are no satellite images for AZ
    # @satelliteImage.add(@satelliteToggle).removeClass 'active'

    @active = modulus +@active, @classification.subject.location.standard.length

    console.log "@el " + @el.find('.frame-image').length
    for image, i in @el.find('.frame-image')
      console.log "(i, image): " + i + ", " + image
      @setActiveClasses image, i, @active

    # for button, i in @toggles
    #   @setActiveClasses button, i, @active

  setActiveClasses: (el, elIndex, activeIndex) ->
    # el = $(el)

    # console.log "+elIndex < +activeIndex " + +elIndex < +activeIndex
    el.toggleClass 'before', +elIndex < +activeIndex
    el.toggleClass 'active', +elIndex is +activeIndex
    el.toggleClass 'after', +elIndex > +activeIndex


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
      @el.removeClass 'showing-summary'
      Subject.next()

    setTimeout =>
      classificationSummary.show()

  sendClassification: ->
    @classification.set 'marks', [@markingSurface.marks...]
    console?.log JSON.stringify @classification
    # @classification.send()

module.exports = Classifier
