module.exports =
  siteNavigation:
    projectName: 'AsteroidZoo'
    home: 'Home'
    classify: 'Classify'
    science: 'Science'
    about: 'About'
    profile: 'Profile'
    education: 'Education'
    talk: 'Discuss'
    blog: 'Blog'

  home:
    header:
      title: 'Identify Near-Earth Objects in Asteroid Zoo'
      content: '''
       Help scientists identify objects that are flying out in space. Perhaps you will find the rock that will end all lide on Earth! 
      '''
      start: 'Start Classifying'
      getClassifying: 'Get Classifying!'
      learnMore: 'Learn More'
    whatDo:
      title: 'What can you do?'
      content: '''
	 Asteroid Zoo Asteroid  Asteroid Zoo Asteroid Zoo 
      '''

  classifier:
    title: 'Classify'
    done:  'Done'
    reset: 'Reset'
    delete: 'Delete'
    next: 'Next'
    whatKind: 'What do you see here?'

    type:
      asteroid:
        label: 'Asteroid'
      artifact:
        label: 'Artifact'
      nothing: 
        label: 'Nothing'

  artifacts:
    heading: 'What type of artifact is this?'
    starbleed:
      label: 'Star Bleed'
    hotpixel:
      label: 'Hot Pixel'
    other:
      label: 'Other' 
  asteroids:
    heading: "Asteroid Tracking"


  science:
    title: 'Science!'
    summary: 'This page will explain the science end of the project.'
    content: '''
      <p>Teach the computers to leanr about asteroids..</p>
      <p>Mine asteroids!.</p>
      <p>Etc.</p>
    '''

    figures:
      something:
        image: '//placehold.it/640x480.png'
        description: 'This is a feature of asteroid zoo'

  about:
    title: 'About the project'
    summary: 'Technical details of the project'
    content: '''
      <p>Who's doing the science? Who's doing the development? What groups are involved? And links to all these things.</p>
    '''

  profile:
    title: 'Your profile'

  education:
    title: 'For educators'
    summary: 'This is where educational info will go.'
    content: '''
      <p>Includes links to other resources, links to ZooTeach, etc.</p>
    '''

  tutorial:
    welcome:
      header: 'Welcome to PROJECT NAME'
      details: 'Welcome to Asteroid Hunt! In this project, you are on the lookout for asteroids in a sequence of images from the Catalina Sky Survey. There are also images artifacts we’d like you to call out along the way.'
    overview:
      header: 'Playback basics'
      details: 'Each sequence is composed of up to four images. You can view the different images by clicking the numbers below, or by clicking “Play” to have them played out automatically. Your goal is to find the moving dots in the images. These are the asteroids!<br><br>Try playing around with the playback. When you are done, click Next'
    beginWorkflow:
      header: 'begin workflow'
      details: 'Hey look, an asteroid!'
    selectAsteroid:
      header: 'sa'
      details: 'We are asking you to mark where the asteroid is in each frame. To start the process, click “Asteroid”'
    markAsteroid:
      header: 'ma'
      details: 'Now click the asteroid in the frame.'
    explainMarking:
      header: 'em'
      details: 'Feel free to adjust where you put the mark. If you are happy with the location of your mark, click “Next Frame”'
    repeatSteps:
      header: 'rs'
      details: 'Repeat the process until you have marked the asteroid in all four frames.'
    summary:
      header: 's'
      details: 'When you have marked all available frames, you are shown a summary of your marks for that asteroid. You can make any final adjustments at this time. When you are done, click “Done” below'
    artifacts:
      header: 'artifacts'
      details: 'You will occasionally spot different “artifacts”, or anomalies within each sequence. Refer to the guide for help on what each of them look like.'
    sendOff:
      header: 'Happy Hunting'
      details: 'That\'s it! Join the discussion on Talk for additional information and guidance. Happy Hunting!'


