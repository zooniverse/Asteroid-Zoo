BaseController = require 'zooniverse/controllers/base-controller'

class Discuss extends BaseController
  className: 'discuss'
  template: require '../views/discuss'

module.exports = Discuss
