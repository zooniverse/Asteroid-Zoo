{Tool} = require 'marking-surface'

FULL_SIZE = 512
HALF_SIZE = 256

class MarkingTool extends Tool
  @Controls: require './marking-tool-controls'

  visible: true
  markType: null
  size: if !!~navigator.userAgent.indexOf 'iO' then 40 else 20
  color: null

  @hr1: null
  @hr2: null
  @vr1: null
  @vr2: null
  circle: null

  cursors:
    circle: 'move'

  initialize: ->
    # generate shapes
    @hr1 = @addShape 'line', x1: 0, y1: -@size, x2: 0, y2: -4, stroke: "#{@color}", strokeWidth: 4
    @hr2 = @addShape 'line', x1: 0, y1: 4, x2: 0, y2: @size, stroke: "#{@color}", strokeWidth: 4
    @vr1 = @addShape 'line', x1: -@size, y1: 0, x2: -4, y2: 0, stroke: "#{@color}", strokeWidth: 4
    @vr2 = @addShape 'line', x1: 4, y1: 0, x2: @size, y2: 0, stroke: "#{@color}", strokeWidth: 4
    @circle = @addShape 'circle', cx: 0, cy: 0, r: @size, fill: 'rgba(255, 215, 0, 0)'

  onInitialClick: (e) ->
    @onInitialDrag e

  onInitialDrag: (e) ->
    @['on *drag circle'] e

  'on *drag circle': (e) =>
    surfaceSize = @surface.el.offsetWidth
    {x, y} = @pointerOffset e
    @mark.set
      x: Math.max 0, Math.min FULL_SIZE, Math.round((x / surfaceSize) * FULL_SIZE)
      y: Math.max 0, Math.min FULL_SIZE, Math.round((y / surfaceSize) * FULL_SIZE)
      x_actual: Math.round x/2
      y_actual: Math.round y/2
      frame: +e.target.id.slice(-1)

  onInitialRelease: (e) ->
    @trigger 'initial-release', [e]

  render: ->
    return if not @visible
    svgLines = [@hr1, @hr2, @vr1, @vr2]

    for line in svgLines
      if @markType is 'asteroid'
        line.attr stroke: 'rgba(255,215,0,0.75)'
      else
        line.attr stroke: 'rgba(200,0,20,0.75)', transform: 'rotate(45)'

    # @hr.attr strokeWidth: 1 / @surface.zoomBy
    # @vr.attr strokeWidth: 1 / @surface.zoomBy
    scale = @surface.el.offsetWidth
    x = (@mark.x / 512) * scale
    y = (@mark.y / 512) * scale
    @group.attr 'transform', "translate(#{x}, #{y})"
    @group.attr 'class', "from-frame-#{@mark.frame}"
    @group.attr 'class', 'mark'
    @controls.moveTo x, y

  setMarkType: (markType) ->
    @markType = markType

  getMarkType: ->
    @markType

module.exports = MarkingTool
