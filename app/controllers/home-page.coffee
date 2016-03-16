BaseController = require 'zooniverse/controllers/base-controller'
# Footer = require 'zooniverse/controllers/footer'
$ = window.jQuery
User = require 'zooniverse/models/user'


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
    User.on 'change', @updateMinorAsteroidCount

  updateMinorAsteroidCount: (e, user) =>
    # live update minor planet count across site, or fallback to last seen
    $.getJSON "https://mpc-count.herokuapp.com/count", (data) =>
      asteroidNum = data?.count || false
      @setTotalAsteroidCountText(asteroidNum)
      @updateUserLastSeenAsteroidCount(asteroidNum, user)

  commaSeparatedNum: (num) ->
    num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

  setTotalAsteroidCountText: (count) ->
    $(".mpc-count").text @commaSeparatedNum(count or @userLastSeenTotalAsteroidCount() or "644632")

  userLastSeenTotalAsteroidCount: ->
    User?.current?.preferences?.asteroid.minor_asteroid_count

  updateUserLastSeenAsteroidCount: (newCount, user) ->
    user.setPreference("minor_asteroid_count", newCount) if newCount and user

  activate: (duration = @animationDuration) ->
    @siteHeader.fadeIn(duration)
    @navigationComponent.show()

  deactivate: (duration = @animationDuration) ->
    @siteHeader.fadeOut(duration)
    @navigationComponent.hide().animate({ scrollTop: 0 }, duration)

  positionMainBanner: ->
    bgHeight = window.innerHeight - $('.site-navigation .content-container').outerHeight(true)
    $('.asteroid-bg').css 'height', bgHeight


module.exports = HomePage
