Subject = require 'zooniverse/models/subject'

createTutorialSubject = ->
  new Subject
    id: 'TRAINING_SUBJECT'
    location:
      standard: [
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0001-202-scaled.png'
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0002-202-scaled.png'
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0003-202-scaled.png'
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0004-202-scaled.png'
      ]

      inverted: [
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0001-202-negative.png'
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0002-202-negative.png'
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0003-202-negative.png'
        'http://asteroidzoo.s3.amazonaws.com/CSS%20Data/Catalina_Sky_Survey_Sample/703/2012/12Dec02/azoo/01_12DEC02_N12022_0004-202-negative.png'

      ]
    metadata: {
      filename: "01_12DEC02_N12022"
      known_objects: {
        "0001": [
          {
            object: "(tutorial image)"
            x: 43
            y: 86
            mag: 19.2
            good_known: true
          },
          {
            object: "(tutorial image)"
            x: 231
            y: 23
            mag: 19.2
            good_known: true
          },          
          {
            object: "(tutorial image)"
            x: 66
            y: 114
            mag: 19.2
            good_known: true
          }
        ]
        "0002": [
          {
            object: "(tutorial image)"
            x: 46
            y: 87
            mag: 19.2
            good_known: true
          },
          {
            object: "(tutorial image)"
            x: 234
            y: 23
            mag: 19.2
            good_known: true
          },          
          {
            object: "(tutorial image)"
            x: 68
            y: 114
            mag: 19.2
            good_known: true
          }
        ]
        "0003": [
          {
            object: "(tutorial image)"
            x: 47
            y: 87
            mag: 19.2
            good_known: true
          },
          {
            object: "(tutorial image)"
            x: 235
            y: 23
            mag: 19.2
            good_known: true
          },          
          {
            object: "(tutorial image)"
            x: 70
            y: 114
            mag: 19.2
            good_known: true
          }
        ]
        "0004": [
          {
            object: "(tutorial image)"
            x: 49
            y: 87
            mag: 19.2
            good_known: true
          },
          {
            object: "(tutorial image)"
            x: 237
            y: 22
            mag: 19.2
            good_known: true
          },          
          {
            object: "(tutorial image)"
            x: 72
            y: 112
            mag: 19.2
            good_known: true
          }
        ]
      }
    }


module.exports = createTutorialSubject