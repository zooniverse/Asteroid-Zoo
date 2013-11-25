BaseController = require 'zooniverse/controllers/base-controller'
User = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'

loadImage = require '../lib/load-image'
Classification = require 'zooniverse/models/classification'
MarkingSurface = require 'marking-surface'
MarkingTool = require './marking-tool'
ClassificationSummary = require './classification-summary'

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
    'click button[name="finish-marking"]': 'onClickFinishMarking'
    'click button[name="no-tags"]'       : 'onClickNoTags'
    'click button[name="play-frames"]'   : 'onClickPlayFrames'

  elements:
    '.subject': 'subjectContainer'
    'button[name="finish-marking"]': 'finishButton'
    'button[name="no-tags"]': 'noTagsButton'

  constructor: ->
    super
    window.classifier = @

    @markingSurface = new MarkingSurface
      tool: MarkingTool

    @markingSurface.svgRoot.attr 'id', 'classifier-svg-root'

    @subjectContainer.append @markingSurface.el

    User.on 'change', @onUserChange
    Subject.on 'fetch', @onSubjectFetch
    Subject.on 'select', @onSubjectSelect

    #addEventListener 'resize', @rescale, false

  activate: ->
    # setTimeout @rescale, 100

  onUserChange: (e, user) =>
    console.log "user change"
    Subject.next() unless @classification?

  onSubjectFetch: =>
    console.log "in onSubjectFetch() "
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
        class: 'frameImage'
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

  onClickPlayFrames: ->
    console.log "Play frames!"
    #@playFrames() # still needs to be built!

  onClickFinishMarking: ->
    @showSummary()

  rescale: =>
    setTimeout =>
      over = innerHeight - document.body.clientHeight
      @subjectContainer.height parseFloat(@subjectContainer.height()) + over

  startLoading: ->
    console.log "In startLoading()"

    #@el.addClass 'loading'

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
