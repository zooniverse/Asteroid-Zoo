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
       Help scientists identify objects that are flying out in space. Perhaps you will find the rock that will end all life on Earth!
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
    rightPanel:
      summaryHeader: "Nice Work!"
      summaryBody: "Check your progress in the subject summary. You can discuss this on Talk, share it, or add it to your favorites!"

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
      header: 'Welcome to Asteroid Hunt!'
      details: 'In this project, you are on the lookout for asteroids in a sequence of images from the Catalina Sky Survey. Your goal is to find the moving dots in the images. These are the asteroids! You may also find other objects we’d like you to identify along the way, we call these artifacts.'
    overview:
      header: 'First, an introduction to the features'
      details: 'There are different ways to view the images to help you find asteroids and artifacts. We have constructed a guide to help you determine whether an object is an asteroid or an artifact. You may want to take time to explore the guide before classifying.' 
    tools:
      header: 'Tools'
      details: 'Invert gives you a way to examine the images by reversing the black and white of the image. Play around with this tool, when you are done click Continue.'
    view: 
      header: 'Viewing the images'
      details: 'There are 2 ways to look at the sequence of images for each classification, either by the “Flicker” or “4-up” options. Flicker allows you to select each frame in the sequence or to play through. 4-up displays all 4 frames at once. Test out each option, and when you are ready click Continue.'
    beginWorkflow:
      header: 'Now on to Asteroid Hunting!'
      details: 'Now that you know how to view the frames, start looking for moving objects (don\'t see anything?). When you see something you believe may be an asteroid, click “Asteroid.” (show me)'
    selectAsteroid:
      header: 'You\'e spotted your first asteroid!'
      details: 'Click on "Asteroid" to begin marking the asteroid in each frame of the sequence.'
    markArtifacts:
      header: 'Marking Artifacts'
      details: 'You may see other objects in the images that are not asteroids, but are unique in the image, these may be artifacts. Artifacts typically appear in one frame of the sequence. \nSelecting artifacts is similar to marking asteroids, but there are 3 options for you to select: Star Bleed, Hot Pixel, and Other. \nSelect which artifacts you see and center it in your marker. Check out examples of each artifact in the (guide).'
    finished:
      header: 'Done Classifying?'
      details: 'Once you have completed classifying a sequence of images, select "Finished."'

    # UNUSED
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


