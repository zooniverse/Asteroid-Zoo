class GhostMark

	constructor: (mark, asteroid_id) ->
		@x           = mark.x
		@y           = mark.y
		@frame       = mark.frame
		@asteroid_id = asteroid_id
		
	# # updateGhostMark: ->

modules.export = GhostMark