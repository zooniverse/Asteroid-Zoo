BaseController = require 'zooniverse/controllers/base-controller'

class SubjectViewer extends BaseController

	events:
	    'click button[name="play-frames"]' : 'onClickPlay'


	constructor: ->
		super
		@playTimeouts

  onClickPlay: ->
    @play()

  onClickPause: ->
    @pause()

  onClickToggle: ({currentTarget}) =>
    selectedIndex = $(currentTarget).val()
    @activate selectedIndex

  play: ->
  	console.log "Playing..."
    # # Flip the images back and forth a couple times.
    # last = @classification.subject.location.standard.length - 1
    # iterator = [0...last].concat [last...0]
    # iterator = iterator.concat [0...last].concat [last...0]

    # # End half way through.
    # iterator = iterator.concat [0...Math.floor(@classification.subject.location.standard.length / 2) + 1]

    # @el.addClass 'playing'

    # for index, i in iterator then do (index, i) =>
    #   @playTimeouts.push setTimeout (=> @activate index), i * 333

    # @playTimeouts.push setTimeout @pause, i * 333

  pause: =>
    clearTimeout timeout for timeout in @playTimeouts
    @playTimeouts.splice 0
    @el.removeClass 'playing'

  activate: (@active) ->
    @satelliteImage.add(@satelliteToggle).removeClass 'active'

    @active = modulus +@active, @classification.subject.location.standard.length

    for image, i in @figures
      @setActiveClasses image, i, @active

    for button, i in @toggles
      @setActiveClasses button, i, @active

  setActiveClasses: (el, elIndex, activeIndex) ->
    el = $(el)
    el.toggleClass 'before', +elIndex < +activeIndex
    el.toggleClass 'active', +elIndex is +activeIndex
    el.toggleClass 'after', +elIndex > +activeIndex

module.exports = SubjectViewer
