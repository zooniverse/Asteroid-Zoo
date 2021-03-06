##################################################
# get a reference to jQuery
##################################################
$ = window.jQuery
$.noConflict()

##################################################
# load Lanaguage Manager
##################################################
t7e = require 't7e'
enUs = require './lib/en-us'

t7e.load enUs

LanguageManager = require 'zooniverse/lib/language-manager'
languageManager = new LanguageManager
  translations:
    en: label: 'English', strings: enUs
    pl: label: 'Polski'
    ru: label: 'русский'

languageManager.on 'change-language', (e, code, strings) ->
  t7e.load strings
  t7e.refresh()

##################################################
# load api
##################################################
Api = require 'zooniverse/lib/api'

api = if window.location.hostname is 'www.asteroidzoo.org'
  new Api project: 'asteroid', host: 'https://www.asteroidzoo.org', path: '/_ouroboros_api/proxy'
else
  new Api project: 'asteroid'

Transporter = require './lib/transporter'
transporter = new Transporter

##################################################
# load the site navigation
##################################################
SiteNavigation = require './controllers/site-navigation'
siteNavigation = new SiteNavigation
siteNavigation.el.appendTo document.body

##################################################
# load the stack of pages
##################################################
StackOfPages = require 'stack-of-pages'
stack = new StackOfPages
  '#/classify'  : require './controllers/classifier'
  '#/'          : require './controllers/home-page'
  '#/about'     : require './controllers/about-page'
  '#/science'   : require './controllers/science-page'
  '#/education' : require './controllers/education-page'
  '#/profile'   : require './controllers/profile'

  NOT_FOUND: '<div class="content-block"><div class="content-container"><h1>Page not found!</h1></div></div>'
  ERROR: '<div class="content-block"><div class="content-container"><h1>There was an error!</h1></div></div>'

document.body.appendChild stack.el

GoogleAnalytics = require 'zooniverse/lib/google-analytics'
analytics = new GoogleAnalytics
  account: 'UA-1224199-56'
  domain: 'www.asteroidzoo.org'

##################################################
#  load the Zooniverse top bar
##################################################
TopBar = require 'zooniverse/controllers/top-bar'
topBar = new TopBar

topBar.el.appendTo document.body

##################################################
# load the browser dialog
##################################################
browserDialog = require 'zooniverse/controllers/browser-dialog'
browserDialog.check msie: 9

##################################################
# get us a user
##################################################
User = require 'zooniverse/models/user'
u = User.fetch()

##################################################
# footer
##################################################

footerContainer = document.createElement 'div'
footerContainer.className = 'footer-container'
Footer = require 'zooniverse/controllers/footer'
footer = new Footer
document.body.appendChild footerContainer
footer.el.appendTo footerContainer

##################################################
# button management
##################################################
# Don't wait for a double-tap check on buttons.
PREVENTED_DEFAULT_ATTR = 'data-touchstart-default-prevented'
$(document).on 'touchstart', 'button', (e) ->
  e.preventDefault()
  button = $(@)
  button.attr PREVENTED_DEFAULT_ATTR, true
  $(document).one 'touchend', -> setTimeout -> button.attr PREVENTED_DEFAULT_ATTR, false

$(document).on 'touchend', 'button', (e) ->
  button = $(@)
  button.trigger 'click' if button.attr PREVENTED_DEFAULT_ATTR

##################################################
# bind the app to the window
##################################################
window.app = {api, siteNavigation, stack, topBar, transporter}
module.exports = window.app
