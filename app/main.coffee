document.write "First Dynamic Content"

#############
# jQUery init
$ = window.jQuery
$.noConflict()


#############
#TopBar init
TopBar = require 'zooniverse/controllers/top-bar'
topBar = new TopBar

topBar.el.appendTo document.body
console.log topBar.el
window.app = {  topBar}
module.exports = window.app
