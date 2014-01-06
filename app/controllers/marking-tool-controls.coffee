{ToolControls} = require 'marking-surface'
BaseController = require 'zooniverse/controllers/base-controller'
FauxRangeInput = require 'faux-range-input'
translate = require 't7e'
Subject = require 'zooniverse/models/subject'
_  = require 'underscore'

KEYS =
  return: 13
  esc:    27

class MarkingToolControlsController extends BaseController
  className: 'marking-tool-controls-controller'
  template: require '../views/marking-tool-controls' 

  tool: null
  
  imageSet:  null
  currentFrame: null

  state: ''

  # This construct  takes an element or element attribute from the DOM and construct an instance variable
  # elements:
  # TODO provisional handle to frames
  elements:
    'input[name="selected-artifact"]': 'selectedArtifactRadios'
  
  constructor: ->

    super
    #this populates 4 image frames 
    @imageSet = new ImageSet()
    
    @currentFrame  =  @imageSet.getFrameFromElement('frame-id-1')

    # provisional default case of artifact subtype
    artifactSubtype = "other"

    fauxRangeInputs = FauxRangeInput.find @el.get 0
    @on 'destroy', -> fauxRangeInputs.shift().destroy() until fauxRangeInputs.length is 0

    
    @tool.mark.on 'change', (property, value) =>
      console.log("Property#{ property}")
      console.log("Value#{value}") 
      # @trigger("create-mark" , this  )
      @setMark

   
    @setState 'whatKind'

  events:
    'click button[name="to-select"]': ->
      @setState 'whatKind'

    'change input[name="classifier-type"]': (e) ->

      if e.currentTarget.value == 'asteroid' 
        @setState 'asteroidTool'
      else if  e.currentTarget.value == 'artifact'
        @setState 'artifactTool'
      else
        console.log("Error: unknown classifier-type")

    'change input[name="selected-artifact"]': ->      
      @artifactSubtype = @selectedArtifactRadios.filter(':checked').val() 

    #'click button[name="done"]': ->
      

    'click button[name="delete"]': ->
      @tool.mark.destroy()

    'click button[name^="done"]': ->
      @tool.deselect()


    #TODO With this setup we don't where we are until the classifier is created.
    'keydown': (e) ->
      switch e.which
        when KEYS.return then @el.find('footer button.default:visible').first().click()
        when KEYS.esc then @el.find('footer button.cancel:visible').first().click()

  setMark: (frameIdx) =>
    console.log("setMark")
    if @state is "asteroidTool" or @state is "whatKind" 
      detection =  @getAsteroidDetection()
    else if @state is "artifactTool"
      detection =  @getArtifactDetection()
    else
      console?.log("Error: marking tool not specified")
    # hack which doesn't even work 
    @tool.mark.frame = frameIdx
    @tool.mark.x = Math.floor(@tool.mark.x) 
    @tool.mark.y = Math.floor(@tool.mark.y)
    @tool.mark.set 'detection', detection


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

  states:
    whatKind:
      enter: ->
        @el.find('button[name="to-select"]').addClass 'hidden' 
        @el.find('.what-kind').show()       

      exit: ->
        @el.find('button[name="to-select"]').removeClass 'hidden'
        @el.find('.what-kind').hide()

    asteroidTool:
      enter: ->
        @el.find('.asteroid-classifier').show()
       
      exit: ->
        @el.find('.asteroid-classifier').hide()  
      
    artifactTool:
      enter: ->
        @el.find('.artifact-classifier').show()
      exit: ->
        @el.find('.artifact-classifier').hide() 

  getAsteroidDetection: =>
    asteroid_detection= 
      type: "asteroid" 
      frame: @currentFrame.seqNumber
    asteroid_detection

  getArtifactDetection: =>
    art_detection = 
        type: "artifact" 
        frame:   @currentFrame.seqNumber
        subType: @artifactSubtype
    art_detection



  #ToDo move to model 
class ImageSet

  imageFrames: null

  constructor: ->
    @populateImageSet()

  populateImageSet: =>
    @imageFrames = new Array()
    for i in [1..4] by 1
      frame = new ImageFrame("frame-id-#{i}", i, "", "")
      @imageFrames[i] = frame
    @imageFrames

  getFrameFromElement: (elementId) => 
    frame = _.findWhere(@imageFrames, elementId: elementId)

  getFrameSeqNumberFromElement: (elementId) => 
     getFrameFromElement(elementId).seqNumber
        
#TODO move to model
class ImageFrame
  elementId: ''
  seqNumber: ''
  url: ''
  inversionUrl: ''

  constructor: (@elementId,@seqNumber,@url,@inversionUrl) ->

   
  

class MarkingToolControls extends ToolControls
  constructor: ->
    super

    @controller = new MarkingToolControlsController tool: @tool
    @el.appendChild @controller.el.get 0
    @on 'destroy', -> @controller.destroy()

  

#module.exports = ImageFrame
#module.exports = ImageSet
module.exports = MarkingToolControls
