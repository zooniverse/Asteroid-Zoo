{Step} = require 'zootorial'
t = require 't7e'

tutorialSteps =
  welcome: new Step
    onEnter: -> # why doesn't this work?
      alert "BLAH!"
      window.classifier.onClickCancel()

    header: t 'span', 'tutorial.welcome.header'
    details: t 'span', 'tutorial.welcome.details'
    attachment: 'center center #surfaces-container center center'
    next: 'overview'  

  overview: new Step
    header: t 'span', 'tutorial.overview.header'
    details: t 'span', 'tutorial.overview.details'
    focus: '#left-panel'
    attachment: 'left center #left-panel right center'
    next: 'tools'

  # TODO: allow multiple focus (add surfaces-container to focus)
  tools: new Step
    header: t 'span', 'tutorial.tools.header'
    details: t 'span', 'tutorial.tools.details'
    className: "arrow-left"
    focus: '#tools'
    attachment: 'left center #tools right center'
    next: 'view'

  # TODO: allow multiple focus (add surfaces-container to focus)
  view: new Step
    header: t 'span', 'tutorial.view.header'
    details: t 'span', 'tutorial.view.details'
    className: "arrow-left"
    focus: '#views'
    attachment: 'left center #views right center'
    next: 'guide'

  guide: new Step
    header: t 'span', 'tutorial.guide.header'
    details: t 'span', 'tutorial.guide.details'
    className: "arrow-left"
    focus: '#guide-button'
    attachment: 'left center #guide-button right center'
    next: 'beginWorkflow'

  # TODO: add a hint to show asteroid, (on click "show me") move fake cursor to asteroid button
  beginWorkflow: new Step
    header: t 'span', 'tutorial.beginWorkflow.header'
    details: t 'span', 'tutorial.beginWorkflow.details'
    attachment: 'center center #surfaces-container center center'
    className: "arrow-left"
    next: 'play'

  play: new Step
    header: t 'span', 'tutorial.play.header'
    details: t 'span', 'tutorial.play.details'
    instruction: t 'span', 'tutorial.play.instruction'
    className: "arrow-bottom"
    attachment: 'center bottom #play-button center top'
    next: 'click [name="play-frames"]': 'observe'

  observe: new Step
    header: t 'span', 'tutorial.observe.header'
    details: t 'span', 'tutorial.observe.details'
    instruction: t 'span', 'tutorial.observe.instruction'
    attachment: 'center center #right-panel center center'
    next: 'firstAsteroid'

    demo: ->
      for surface in [window.classifier.markingSurfaceList...]
        console.log surface
        surface.addShape 'circle',
        class: 'tutorial-demo-mark'
        r: 20
        fill: 'none'
        stroke: 'green'
        'stroke-width': 4
        transform: 'translate(430,40)'

    onExit: ->
      window.classifier.removeElementsOfClass('.tutorial-demo-mark')

  firstAsteroid: new Step
    header: t 'span', 'tutorial.firstAsteroid.header'
    details: t 'span', 'tutorial.firstAsteroid.details'
    attachment: 'center center #surfaces-container center center'
    next: 'selectAsteroid'

  # add intermediate step: play frames, move textbox to right panel, add "Don't see an asteroid? Hint."
  selectAsteroid: new Step
    header: t 'span', 'tutorial.selectAsteroid.header'
    instruction: t 'span', 'tutorial.selectAsteroid.instruction'
    className: "arrow-right"
    attachment: 'right center #asteroid-button left center'
    next: 'click [id="asteroid-button"]': 'asteroid_1'

  asteroid_1: new Step
    header: t 'span', 'tutorial.asteroid_1.header'
    instruction: t 'span', 'tutorial.asteroid_1.instruction'
    next: 'click [id="surfaces-container"]': 'nextFrame'
    attachment: 'center center #surfaces-container center center'

  nextFrame: new Step
    header: t 'span', 'tutorial.nextFrame.header'
    instruction: t 'span', 'tutorial.nextFrame.instruction'
    next: 'click [name="next-frame"]': 'continueMarkingAsteroids'
    className: "arrow-right"
    attachment: 'right center [name="next-frame"] left center'

  continueMarkingAsteroids: new Step
    header: t 'span', 'tutorial.continueMarkingAsteroids.header'
    instruction: t 'span', 'tutorial.continueMarkingAsteroids.instruction'
    attachment: 'center center #surfaces-container center center'
    next: 'asteroidDone'

  asteroidDone: new Step
    header: t 'span', 'tutorial.asteroidDone.header'
    instruction: t 'span', 'tutorial.asteroidDone.instruction'
    className: "arrow-bottom"
    attachment: 'center bottom #finished center top'
    next: 'click [id="finished"]': ''

module.exports = tutorialSteps
