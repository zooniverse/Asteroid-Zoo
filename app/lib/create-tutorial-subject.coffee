Subject = require 'zooniverse/models/subject'

createTutorialSubject = ->
  new Subject
    id: 'TODO'
    location:
      standard: [
        './dev-subjects-images/01_12DEC02_N04066_0001-50-scaled.png'
        './dev-subjects-images/01_12DEC02_N04066_0002-50-scaled.png'
        './dev-subjects-images/01_12DEC02_N04066_0003-50-scaled.png'
        './dev-subjects-images/01_12DEC02_N04066_0004-50-scaled.png'
      ]
    metadata: {}

module.exports = createTutorialSubject