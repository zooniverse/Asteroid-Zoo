#require = window.require

describe 'Classifier', ->
  #path = document.location.pathname
  #console.log path
  Classifier = require('../../../app/controllers/classifier')
  
  it 'can noop', ->

  it 'can fail', ->
  	expect(@imaginary is aFrog)
    