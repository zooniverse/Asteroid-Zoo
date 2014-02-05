{Step} = require 'zootorial'
t = require 't7e'

tutorialSteps =
  welcome: new Step
    header: t 'span', 'tutorial.welcome.header'
    details: t 'span', 'tutorial.welcome.details'
    attachment: 'center center #classify-box center center'
    next: 'overview'
  overview: new Step
    header: t 'span', 'tutorial.overview.header'
    details: t 'span', 'tutorial.overview.details'
    attachment: 'center center #classify-box center center'
    next: 'beginWorkflow'
  beginWorkflow: new Step
    header: t 'span', 'tutorial.beginWorkflow.header'
    details: t 'span', 'tutorial.beginWorkflow.details'
    attachment: 'center center #classify-box center center'
    next: 'selectAsteroid'
  selectAsteroid: new Step
    header: t 'span', 'tutorial.selectAsteroid.header'
    details: t 'span', 'tutorial.selectAsteroid.details'
    attachment: 'center center #classify-box center center'
    next: 'markAsteroid'
  markAsteroid: new Step
    header: t 'span', 'tutorial.markAsteroid.header'
    details: t 'span', 'tutorial.markAsteroid.details'
    attachment: 'center center #classify-box center center'
    next: 'explainMarking'
  explainMarking: new Step
    header: t 'span', 'tutorial.explainMarking.header'
    details: t 'span', 'tutorial.explainMarking.details'
    attachment: 'center center #classify-box center center'
    next: 'repeatSteps'
  repeatSteps: new Step
    header: t 'span', 'tutorial.repeatSteps.header'
    details: t 'span', 'tutorial.repeatSteps.details'
    attachment: 'center center #classify-box center center'
    next: 'summary'
  summary: new Step
    header: t 'span', 'tutorial.summary.header'
    details: t 'span', 'tutorial.summary.details'
    attachment: 'center center #classify-box center center'
    next: 'artifacts'
  artifacts: new Step
    header: t 'span', 'tutorial.artifacts.header'
    details: t 'span', 'tutorial.artifacts.details'
    attachment: 'center center #classify-box center center'
    next: 'sendOff'
  sendOff: new Step
    header: t 'span', 'tutorial.sendOff.header'
    details: t 'span', 'tutorial.sendOff.details'
    attachment: 'center center #classify-box center center'

module.exports = tutorialSteps
