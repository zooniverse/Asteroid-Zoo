{ToolControls} = require 'marking-surface'
BaseController = require 'zooniverse/controllers/base-controller'
FauxRangeInput = require 'faux-range-input'
translate = require 't7e'
Subject = require 'zooniverse/models/subject'
_  = require 'underscore'

KEYS =
  return: 13
  esc:    27
  one:    49
  two:    50
  three:  51
  four:   52

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
    'img.frame-id-1': 'firstFrame'
    'img.frame-id-2': 'secondFrame'
    'img.frame-id-3': 'thirdFrame'
    'img.frame-id-4': 'fourthFrame'
  
  constructor: ->

    super
   
    #this populates 4 image frames 
    @imageSet = new ImageSet()
    #TODO 
    @currentFrame  =  @imageSet.getFrameFromElement('frame-id-1')

    
    console.log  "Current frame #{@currentFrame .val}"

    # provisional default case of artifact subtype
    artifactSubtype = "other"

    fauxRangeInputs = FauxRangeInput.find @el.get 0
    @on 'destroy', -> fauxRangeInputs.shift().destroy() until fauxRangeInputs.length is 0

    @tool.mark.on 'change', (property, value) =>
        # switch property
        #   #when 'asteroid'

        #   when 'artifact'
        #     #@tool.mark.artifact.set "subtype", @selectedArtifactRadios.value

    console.log("mark changed")
    @setState 'whatKind'

  events:
    'click button[name="to-select"]': ->
      @setState 'whatKind'

    'change input[name="classifier-type"]': (e) ->

      if e.currentTarget.value == 'asteroid' 
        asteroid_detection= 
          type: "asteroid" 
          frame: @currentFrame.seqNumber
          
        @setState 'asteroidTool change'
        @tool.mark.set 'detection', asteroid_detection
        
      else if  e.currentTarget.value == 'artifact'
        art_detection = 
          type: "artifact" 
          frame:   @currentFrame.seqNumber
          subType: @artifactSubtype
        @setState 'artifactTool'
        @tool.mark.set 'detection', art_detection
        
      else
        console.log("Error: unknown classifier-type")

    'change input[name="selected-artifact"]': =>
     
      #TODO why do I need to place locate  selectedArtifactRadios in elements. 
      # it shoudl be added go  the object scope
      # @artifactSubtype = selectedArtifactRadios.filter(':checked').val() 

    'click button[name="delete"]': ->
      @tool.mark.destroy()

    'click button[name="reset"]': ->
      @setState 'whatKind'

    'click button[name="next"]':   ->
      console.log "buttonnext clicked"

    'click button[name^="done"]': ->
      @tool.deselect()

    'keydown': (e) ->
      switch e.which
        when KEYS.return then @el.find('footer button.default:visible').first().click()
        when KEYS.esc then @el.find('footer button.cancel:visible').first().click()
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

  hideAllFrames: ->
    @hideFrame("frame-id-0")
    @hideFrame("frame-id-1")
    @hideFrame("frame-id-2")
    @hideFrame("frame-id-3")
    
  showFrame: (img_id) ->
    @currentFrame  =  @imageSet.getFrameFromElement(img_id)
    document.getElementById(img_id).style.visibility="visible"
   
  hideFrame: (img_id) ->
    document.getElementById(img_id).style.visibility="hidden"

  destroyImage: (img_id) ->


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
       #@el.find('button[name="next"]').show()  

      exit: ->
        @el.find('button[name="to-select"]').removeClass 'hidden'
        @el.find('.what-kind').hide()
        @el.find('button[name="next"]').hide()

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

  #ToDo move to model 
class ImageSet

  imageFrames: null

  constructor: ->
    @populateImageSet()

  populateImageSet: =>
    @imageFrames = new Array()
    #firstFrame = new ImageFrame('frame-id-1', '1' , "", "")
    for i in [0..3] by 1
      frame = new ImageFrame("frame-id-#{i}", i, "", "")
      @imageFrames[i] = frame
    @imageFrames

  getFrameFromElement: (elementId) => 
    frame = _.findWhere(@imageFrames, elementId: elementId)

  # getFrameSeqNumberFromElement: (elementId) => 
  #   getFrameFromElement(elementId).seqNumber
        
#TODO move to model
class ImageFrame
  require ("underscore")
  elementId: ''
  seqNumber: ''
  url: ''
  inversionUrl: ''

  constructor: (@elementId,@seqNumber,@url,@inversionUrl) ->

   
  

class MarkingToolControls extends ToolControls
  constructor: ->
    super

    controller = new MarkingToolControlsController tool: @tool
    @el.appendChild controller.el.get 0
    @on 'destroy', -> controller.destroy()

    @tool.mark.on 'change', (property, value) =>
      if property is 'proximity'
        proximity = @tool.mark.proximity
        proximity ?= 0.5
        @tool.radius = (@tool.constructor::radius / 2) * (2 - proximity)
        @tool.redraw()

module.exports = MarkingToolControls
