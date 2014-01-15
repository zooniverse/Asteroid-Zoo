{ToolControls} = require 'marking-surface'
BaseController = require 'zooniverse/controllers/base-controller'
FauxRangeInput = require 'faux-range-input'
#TODO broke include of external class
# ImageSet = require "../models/image-set"
# ImageFrame =  require "../models/image-frame"
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

  # state: ''

  # This construct  takes an element or element attribute from the DOM and construct an instance variable
  # elements:
  # TODO provisional handle to frames
  elements:
    'input[name="selected-artifact"]': 'selectedArtifactRadios'
  
  constructor: ->
    super

    #this populates 4 image frames 
    @imageSet = new ImageSet()
    
    #TODO dubious, broke, wrong way    
    @currentFrame  =  @imageSet.getFrameFromElement('frame-id-1')

    # provisional default case of artifact subtype
    artifactSubtype = "other"

    fauxRangeInputs = FauxRangeInput.find @el.get 0
    @on 'destroy', -> fauxRangeInputs.shift().destroy() until fauxRangeInputs.length is 0

    
    @tool.mark.on 'change', (property, value) =>
      @setMark
    # @setState 'whatKind'

  events:

    #TODO With this setup we don't where we are until the classifier is created.
    'keydown': (e) ->
      switch e.which
        when KEYS.return then @el.find('footer button.default:visible').first().click()
        when KEYS.esc then @el.find('footer button.cancel:visible').first().click()

  setMark: (frameIdx) =>
    console.log 'MarkingToolControlsController: setMark()' # STI

    # debugger

    # if @state is "asteroidTool" or @state is "whatKind" 
    #   detection =  @getAsteroidDetection()
    # else if @state is "artifactTool"
    #   detection =  @getArtifactDetection()
    # else
    #   console?.log("Error: marking tool not specified")

    detection = '' # temporary 'fix' while we figure out how to bring this back

    #TODO frameIdx not reliably being set anymore
    @tool.mark.frame = frameIdx

    #TODO make integral hack which doesn't even work , GH issue on integral values GH#2
   
    @tool.mark.x = Math.floor(@tool.mark.x) 
    @tool.mark.y = Math.floor(@tool.mark.y)
    # pass the what surface this mark came from back to the classifier.  
    if this.tool.surface.el.id  is "surface-master"
      @tool.mark.surface_master = true
    else
      @tool.mark.surface_master = false
    #TODO Sascha didn't like the sub-structure here
    @tool.mark.set 'detection', detection

  #TODO factor currentFrame determination up andor out, 
  # probably as paremter to this controller class
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
    # @el.appendChild @controller.el.get 0
    @on 'destroy', -> @controller.destroy()

  

#module.exports = ImageFrame
#module.exports = ImageSet
module.exports = MarkingToolControls
