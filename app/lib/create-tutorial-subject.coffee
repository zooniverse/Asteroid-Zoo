Subject = require 'zooniverse/models/subject'

createTutorialSubject = ->
  new Subject
    id: 'TODO'
    location:
      standard: [
        'images/tutorial-subject/training01.png'
        'images/tutorial-subject/training02.png'
        'images/tutorial-subject/training03.png'
        'images/tutorial-subject/training04.png'
      ]
    metadata: {}

module.exports = createTutorialSubject