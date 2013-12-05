{ToolControls} = require 'marking-surface'
BaseController = require 'zooniverse/controllers/base-controller'
FauxRangeInput = require 'faux-range-input'
translate = require 't7e'
Subject = require 'zooniverse/models/subject'

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

  state: ''

  # This construct would take an element or element attribute from the DOM and construct an instance variable
  # elements:
  #   # 'img.selected-animal-example': 'selectedAnimalImage'
  

  constructor: ->
    super

    fauxRangeInputs = FauxRangeInput.find @el.get 0
    @on 'destroy', -> fauxRangeInputs.shift().destroy() until fauxRangeInputs.length is 0

    @tool.mark.on 'change', (property, value) =>
        # switch property
        #   when 'asteroid'

        #   when 'artifact'
    console.log("mark changed")
    @setState 'whatKind'

  events:
    'click button[name="to-select"]': ->
      console.log("click button to select")
      @setState 'whatKind'

    'change input[name="classifier-type"]': (e) ->
      if e.currentTarget.value == 'asteroid'  
        #console.log "asteroid tool"
        @setState 'asteroidTool'
        @tool.mark.set 'asteroid', true
        
      else if  e.currentTarget.value == 'artifact'
        #console.log "asteroid tool"
        @setState 'artifactTool'
        @tool.mark.set 'artifact', true
        
      else
        console.log("Error: unknown classifier-type")

    'click button[name="delete"]': ->
       @tool.mark.destroy()

    'click button[name="reset"]': ->
      console.log "reset"
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
    document.getElementById(img_id).style.visibility="visible"

  hideFrame: (img_id) ->
    document.getElementById(img_id).style.visibility="hidden"

  destroyImage: (img_id) ->


  setState: (newState) ->
    console.log("enter setState")
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
        console.log("enter state whatKind")
        @el.find('button[name="to-select"]').addClass 'hidden' 
        @el.find('.what-kind').show()       
       #@el.find('button[name="next"]').show()  

      exit: ->
        console.log("ext state what kind")
        @el.find('button[name="to-select"]').removeClass 'hidden'
        @el.find('.what-kind').hide()
        @el.find('button[name="next"]').hide()

    asteroidTool:
      enter: ->
        console.log("enter state asteroidTool")
        @el.find('.asteroid-classifier').show()
       
      exit: ->
        console.log("exit state asteroidTool")
        @el.find('.asteroid-classifier').hide()  
      
        
    artifactTool:
      enter: ->
        console.log("enter state artifactTool")
        @el.find('.artifact-classifier').show()
      exit: ->
        console.log("exit state artifactTool")
        @el.find('.artifact-classifier').hide() 


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
