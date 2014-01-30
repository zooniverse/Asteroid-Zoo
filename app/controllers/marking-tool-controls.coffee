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

  constructor: ->
    super
    @imageSet = new ImageSet()

  setMark: (frameIdx, id) =>
    @tool.mark.frame = frameIdx
    @tool.mark.id = id
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
    @on 'destroy', -> @controller.destroy()

module.exports = MarkingToolControls
