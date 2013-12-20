{Tool} = require 'marking-surface'

class MarkingTool extends Tool
  @Controls: require './marking-tool-controls'

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
    @onInitialDrag e

  onInitialDrag: (e) ->
    @['on *drag circle'] e

  'on *drag circle': (e) =>
    offset = @pointerOffset e
    @mark.set offset

  render: ->
    #debugger
    @circle.attr
      r: @size / 2 / @surface.zoomBy
      strokeWidth: 1 / @surface.zoomBy

    @hr.attr strokeWidth: 1 / @surface.zoomBy
    @vr.attr strokeWidth: 1 / @surface.zoomBy

    @group.attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    @controls.moveTo @mark.x, @mark.y

    @group.attr 'class', "from-frame-#{@mark.frame}"

module.exports = MarkingTool
