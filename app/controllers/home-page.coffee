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
    $('.asteroid-bg').css 'height', window.innerHeight - $('.site-navigation .content-container').outerHeight(true)

  activate: ->
    setTimeout @showNavigationComponent, @headerSlideDelay

  deactivate: (params) ->
    if params?
      setTimeout @hideNavigationComponent, @headerSlideDelay
    else
      # This is the on-load deactivation
      @hideNavigationComponent 0

  showNavigationComponent: (duration = @animationDuration) =>
    @navigationComponent.slideDown duration
    @navigationComponent.animate {
      opacity: 1
    }, {
      duration: duration
      queue: false
    }

  hideNavigationComponent: (duration = @animationDuration) =>
    @navigationComponent.slideUp duration
    @navigationComponent.animate {
      opacity: 0
    }, {
      duration: duration * 0.5
      queue: false
    }

module.exports = HomePage
