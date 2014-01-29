{Tool} = require 'marking-surface'

FULL_SIZE = 512
HALF_SIZE = 256

class MarkingTool extends Tool
  @Controls: require './marking-tool-controls'

  visible: true

  hr: null
  vr: null
  circle: null

  size: if !!~navigator.userAgent.indexOf 'iO' then 40 else 20
  color: [255, 215, 0]

  cursors:
    circle: 'move'

  initialize: ->
    @hr = @addShape 'line', x1: 0, y1: -@size, x2: 0, y2: @size, stroke: "rgb(#{@color})", strokeWidth: 1
    @vr = @addShape 'line', x1: -@size, y1: 0, x2: @size, y2: 0, stroke: "rgb(#{@color})", strokeWidth: 1
    @circle = @addShape 'circle', cx: 0, cy: 0, r: @size, fill: 'rgba(255, 215, 0, 0)'

  onInitialClick: (e) ->
    # console.log 'MarkingTool: onInitialClick()' # STI
    @onInitialDrag e

  onInitialDrag: (e) ->
    # console.log 'MarkingTool: onInitialDrag()' # STI
    @['on *drag circle'] e

  'on *drag circle': (e) =>
    surfaceSize = @surface.el.offsetWidth
    {x, y} = @pointerOffset e
    @mark.set
      x: (x / surfaceSize) * FULL_SIZE
      y: (y / surfaceSize) * FULL_SIZE

  render: ->
    return if not @visible

    @hr.attr strokeWidth: 1 / @surface.zoomBy
    @vr.attr strokeWidth: 1 / @surface.zoomBy

    scale = @surface.el.offsetWidth

    x = (@mark.x / 512) * scale
    y = (@mark.y / 512) * scale

    @group.attr 'transform', "translate(#{x}, #{y})"
    @group.attr 'class', "from-frame-#{@mark.frame}"
    @controls.moveTo x, y

module.exports = MarkingTool
