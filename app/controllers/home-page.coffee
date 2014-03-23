BaseController = require 'zooniverse/controllers/base-controller'
# Footer = require 'zooniverse/controllers/footer'
$ = window.jQuery


KEYS =
  return: 13
  esc:    27
  one:    49
  two:    50
  three:  51
  four:   52

class HomePage extends BaseController
  className: 'home-page'
  template: require '../views/home-page'

  headerSlideDelay: 150
  animationDuration: 333

  constructor: ->
    super
    @navigationComponent = $('.site-navigation .for-home-page')
    @siteHeader = $(".asteroid-bg .content-block")
    @positionMainBanner()
    window.onresize = => @positionMainBanner()

  activate: (duration = @animationDuration) ->
    @siteHeader.fadeIn(duration)
    @navigationComponent.show()

  deactivate: (duration = @animationDuration) ->
    @siteHeader.fadeOut(duration)
    @navigationComponent.hide(500) # or just hide() for no transition

  positionMainBanner: ->
    bgHeight = window.innerHeight - $('.site-navigation .content-container').outerHeight(true)
    $('.asteroid-bg').css 'height', bgHeight


module.exports = HomePage
