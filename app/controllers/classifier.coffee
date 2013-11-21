BaseController = require 'zooniverse/controllers/base-controller'
User = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'

loadImage = require '../lib/load-image'
Classification = require 'zooniverse/models/classification'
MarkingSurface = require 'marking-surface'
MarkingTool = require './marking-tool'
ClassificationSummary = require './classification-summary'

DEV_SUBJECTS = [
  '../dev-subjects-images/asteroid.png'
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
    'click button[name="no-tags"]': 'onClickNoTags'

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

    # @subjectImages @markingSurface.addShape 'image',
    #   width: '100%'
    #   height: '100%'
    #   preserveAspectRatio: 'none'

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
    frameImages = new Array
    framesCount =  subject.location.standard.length
    console.log "Frame Count" + framesCount
    for i in [0..framesCount-1] by 1
      # # add image element to the marking surface
      frame_id = "frame-id-#{i}"
      frameImage = @markingSurface.addShape 'image',
        id:  frame_id
        width: '100%'
        height: '100%'
        preserveAspectRatio: 'none'
      #frameImages.push frameImage
      #load the image from the retrieved subject
      img_src = subject.location.standard[i]
      console.log "frameImage id #{frameImage.id}"
      do (img_src, frameImage)  => 
        loadImage img_src, (img) =>
        frameImage.attr
         'xlink:href': img_src


       #load the image from the retrieved subject
    # frameImages.length  
    # # for i in [0..framesCount-1] by 1
    # #   img_src = subject.location.standard[i]
    # #   console.log "frameImage id #{frameImage.id}"
    # #   loadImage img_src, (img) =>
    # #     frameImages[i].attr
    # #      'xlink:href': img_src


    @stopLoading()

    @markingSurface.enable()

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
