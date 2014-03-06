BaseController = require 'zooniverse/controllers/base-controller'
Dialog         = require 'zooniverse/controllers/dialog'

class SciencePage extends BaseController
  className: 'science-page'
  template: require '../views/science-page'

module.exports = SciencePage
