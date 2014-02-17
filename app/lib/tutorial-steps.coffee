{Step} = require 'zootorial'
t = require 't7e'

tutorialSteps =
  welcome: new Step
    header: t 'span', 'tutorial.welcome.header'
    details: t 'span', 'tutorial.welcome.details'
    attachment: 'center center #surfaces-container center center'
    next: 'overview'  

  overview: new Step
    header: t 'span', 'tutorial.overview.header'
    details: t 'span', 'tutorial.overview.details'
    focus: '#left-panel'
    attachment: 'left center #left-panel right center'
    next: 'guide'

  guide: new Step
    header: t 'span', 'tutorial.guide.header'
    details: t 'span', 'tutorial.guide.details'
    className: "arrow-left"
    focus: '#guide-button'
    attachment: 'left center #guide-button right center'
    next: 'tools'

  tools: new Step
    header: t 'span', 'tutorial.tools.header'
    details: t 'span', 'tutorial.tools.details'
    className: "arrow-left"
    focus: '#invert-button'
    attachment: 'left center #invert-button right center'
    next: 'view'

  view: new Step
    header: t 'span', 'tutorial.view.header'
    details: t 'span', 'tutorial.view.details'
    className: "arrow-left"
    focus: '#view'
    attachment: 'left center #view right center'
    next: 'beginWorkflow'

  beginWorkflow: new Step
    header: t 'span', 'tutorial.beginWorkflow.header'
    details: t 'span', 'tutorial.beginWorkflow.details'
    attachment: 'center center #surfaces-container center center'
    next: 'play'

  play: new Step
    header: t 'span', 'tutorial.play.header'
    details: t 'span', 'tutorial.play.details'
    className: "arrow-bottom"
    focus: '#play-button'
    attachment: 'center bottom #play-button center top'
    next: 'selectAsteroid'

  selectAsteroid: new Step
    header: t 'span', 'tutorial.selectAsteroid.header'
    details: t 'span', 'tutorial.selectAsteroid.details'
    className: "arrow-right"
    attachment: 'right center #asteroid-button left center'
    next: 'markArtifacts'

  markArtifacts: new Step
    header: t 'span', 'tutorial.markArtifacts.header'
    details: t 'span', 'tutorial.markArtifacts.details'
    className: "arrow-right"
    attachment: 'right center #artifact-button left center'
    next: 'finished'

  finished: new Step
    header: t 'span', 'tutorial.finished.header'
    details: t 'span', 'tutorial.finished.details'
    className: "arrow-bottom"
    focus: '#finished'
    attachment: 'center bottom #finished center top'

# UNUSED
  
  explainMarking: new Step
    header: t 'span', 'tutorial.explainMarking.header'
    details: t 'span', 'tutorial.explainMarking.details'
    attachment: 'center center #surfaces-container center center'
    next: 'repeatSteps'
  repeatSteps: new Step
    header: t 'span', 'tutorial.repeatSteps.header'
    details: t 'span', 'tutorial.repeatSteps.details'
    attachment: 'center center #surfaces-container center center'
    next: 'summary'
  summary: new Step
    header: t 'span', 'tutorial.summary.header'
    details: t 'span', 'tutorial.summary.details'
    attachment: 'center center #surfaces-container center center'
    next: 'artifacts'
  artifacts: new Step
    header: t 'span', 'tutorial.artifacts.header'
    details: t 'span', 'tutorial.artifacts.details'
    attachment: 'center center #surfaces-container center center'
    next: 'sendOff'
  sendOff: new Step
    header: t 'span', 'tutorial.sendOff.header'
    details: t 'span', 'tutorial.sendOff.details'
    attachment: 'center center #surfaces-container center center'

module.exports = tutorialSteps
