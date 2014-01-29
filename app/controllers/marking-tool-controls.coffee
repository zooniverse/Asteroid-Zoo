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
    @imageSet = new ImageSet()

  events:
    'keydown': (e) ->
      switch e.which
        when KEYS.return then @el.find('footer button.default:visible').first().click()
        when KEYS.esc then @el.find('footer button.cancel:visible').first().click()

  setMark: (frameIdx, asteroid_id) =>
    @tool.mark.frame = frameIdx
    @tool.mark.asteroid_id = asteroid_id
    @tool.mark.x = Math.floor(@tool.mark.x) 
    @tool.mark.y = Math.floor(@tool.mark.y)

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
