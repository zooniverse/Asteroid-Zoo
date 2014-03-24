Subject = require 'zooniverse/models/subject'

createTutorialSubject = ->
  new Subject
    id: 'TODO'
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
        # filename: "01_12DEC02_N12022",
        # cutout: {
        #   x: [],
        #   y: []
        # },
        # known_objects: {
        #   "0001": [
        #     {
        #       object: "(tutorial image)",
        #       x: 40.79599999999982,
        #       y: 193.68000000000075,
        #       mag: 19.2,
        #       good_known: true
        #     }
        #   ],
        #   "0002": [
        #     {
        #       object: "(tutorial image)",
        #       x: 40.79599999999982,
        #       y: 193.68000000000075,
        #       mag: 19.2,
        #       good_known: true
        #     }
        #   ],
        #   "0003": [
        #     {
        #       object: "(tutorial image)",
        #       x: 40.79599999999982,
        #       y: 193.68000000000075,
        #       mag: 19.2,
        #       good_known: true
        #     }
        #   ],
        #   "0004": [
        #     {
        #       object: "(tutorial image)",
        #       x: 40.79599999999982,
        #       y: 193.68000000000075,
        #       mag: 19.2,
        #       good_known: true
        #     }
        #   ],

        # }
      }


module.exports = createTutorialSubject