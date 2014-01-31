{Tool} = require 'marking-surface'

FULL_SIZE = 512
HALF_SIZE = 256

class MarkingTool extends Tool
  @Controls: require './marking-tool-controls'

  visible: true
  markType: null

  lines = []
  circle: null

  size: if !!~navigator.userAgent.indexOf 'iO' then 40 else 20
  color: 'rgb(200, 0, 0)'

  cursors:
    circle: 'move'

  initialize: ->
    # generate shapes
    @hr1 = @addShape 'line', x1: 0, y1: -@size, x2: 0, y2: -4, stroke: "#{@color}", strokeWidth: 1
    @hr2 = @addShape 'line', x1: 0, y1: 4, x2: 0, y2: @size, stroke: "#{@color}", strokeWidth: 1
    @vr1 = @addShape 'line', x1: -@size, y1: 0, x2: -4, y2: 0, stroke: "#{@color}", strokeWidth: 1
    @vr2 = @addShape 'line', x1: 4, y1: 0, x2: @size, y2: 0, stroke: "#{@color}", strokeWidth: 1
    @circle = @addShape 'circle', cx: 0, cy: 0, r: @size, fill: 'rgba(255, 215, 0, 0)'

  onInitialClick: (e) ->
    @onInitialDrag e

  onInitialDrag: (e) ->
    @['on *drag circle'] e

  'on *drag circle': (e) =>
    surfaceSize = @surface.el.offsetWidth
    {x, y} = @pointerOffset e
    @mark.set
      x: (x / surfaceSize) * FULL_SIZE
      y: (y / surfaceSize) * FULL_SIZE

  render: ->
    return if not @visible

    # update colors
    if @markType is 'asteroid'
      @vr1.attr stroke: 'rgb(200,200,0)'
      @vr2.attr stroke: 'rgb(200,200,0)'
      @hr1.attr stroke: 'rgb(200,200,0)'
      @hr2.attr stroke: 'rgb(200,200,0)'
    else
      @vr1.attr stroke: 'rgb(200,0,0)', transform: 'rotate(45)'
      @vr2.attr stroke: 'rgb(200,0,0)', transform: 'rotate(45)'
      @hr1.attr stroke: 'rgb(200,0,0)', transform: 'rotate(45)'
      @hr2.attr stroke: 'rgb(200,0,0)', transform: 'rotate(45)'
      
    # @hr.attr strokeWidth: 1 / @surface.zoomBy
    # @vr.attr strokeWidth: 1 / @surface.zoomBy
    scale = @surface.el.offsetWidth
    x = (@mark.x / 512) * scale
    y = (@mark.y / 512) * scale
    @group.attr 'transform', "translate(#{x}, #{y})"
    @group.attr 'class', "from-frame-#{@mark.frame}"
    @controls.moveTo x, y

  setMarkType: (markType) ->
    @markType = markType

  getMarkType: ->
    @markType

module.exports = MarkingTool
