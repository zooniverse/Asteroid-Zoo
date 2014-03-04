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
      title: 'Hunt for Mineral-Rich Asteroids!'
      content: '''
Scientists are scanning our solar system for asteroids with the Catalina Sky Survey. They need your help to find asteroids for the exploration of their mineral properties!      '''
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
    delete: 'Delete Mark'
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
      knownAsteroid: "This subject contains at least one known asteroid (circled in green)."
      summaryBody: "Check your progress in the subject summary. You can discuss this on Talk, share it, or add it to your favorites!"
      asteroidDoneScreen: "You must mark an asteroid or declare not visible in all 4 frames to click done"
      artifactDoneScreen: "Please click on the artifact in the image and select what type to click done"
    finished:
      finishedButtonScreen: "Please mark any visible asteroids or artifacts, or select 'Nothing' to move on to the next set of images"

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
    title: 'Motivation for Asteroid Zoo'
    summary: '''
      What do we expect to find?  CSS currently finds about 90% of the asteroids that can be found in every image.  They've discovered over 100,000 objects so far.  We estimate that around 10,000 new objects and as many as 1,000 near-Earth objects still remain to be discovered in the data.  We can find them with your help, so start classifying to discover asteroids!
    '''


    special: '''
     The Catalina Sky Survey (CSS) is the most productive group for finding and cataloging asteroids, having contributed to 46.7% of all the near Earth objects (NEO) discoveries to date.   However, since the CSS examines vast amounts of the sky very quickly and automatically, and therefore computer programs automatically reduce the data to find the asteroids in the images.  These programs are very good at finding bright objects, but are not quite smart enough by themselves to detect the faint ones. Although, humans can look at the detections and validate the program's work. This is where you come in!  With many people participating in AsteroidZoo, we are able to examine all the images in hopes of finding everything that can be found.  Humans have excellent pattern recognition capabilities and are able to ignore noise that resembles patterns, and this will allow us to improve the existing data over and above anything computers can do.
    '''
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

  ######################
  # TUTORIAL
  ######################
  tutorial:
    
    welcome:
      header: 'Welcome to Asteroid Hunt!'
      details: 'In this project, you are on the lookout for asteroids in a sequence of images from the Catalina Sky Survey. Your goal is to find the moving dots in the images. These could be asteroids no one has ever seen before! You may also find other objects we’d like you to identify along the way, we call these artifacts.'
    
    overview:
      header: 'First, an introduction to the features'
      details: 'There are different ways to view the images to help you find asteroids and artifacts.' 
    
    guide:
      header: 'The guide'
      details: 'We have constructed a guide to help you determine whether an object is an asteroid or an artifact. You may want to take time to explore the guide before classifying.'
    
    tools:
      header: 'Tools'
      details: 'Invert gives you a way to examine the images by reversing the black and white of the image. Play around with this tool, when you are done click Continue.'
    
    view: 
      header: 'Viewing the images'
      details: 'There are 2 ways to look at the sequence of images for each classification, either by the “Flicker” or “4-up” options. Flicker allows you to select each frame in the sequence or to play through. 4-up displays all 4 frames at once. Test out each option, and when you are ready click Continue.'
    
    beginWorkflow:
      header: 'Now on to Asteroid Hunting!'
      details: 'Now that you know how to view the frames, let\'s start looking for moving objects. We\'ll begin using the default Flicker view.'
      
    play:
      header: 'Play frames'
      details: 'The Flicker view is a great way to find moving objects because it lets you play the frames.'
      instruction: 'Click play to get started.'

    observe:
      header: 'Observe'
      details: 'If you look carefully, you\'ll find moving objects in the image.'
      instruction: 'See if you can spot the asteroid in this picture.'
    
    firstAsteroid:
      header: 'You\'ve spotted your first asteroid!'
      details: 'We\'ll now begin marking it across each frame.'
    
    selectAsteroid:
      header: 'Tracking Asteroids'
      instruction: 'Click on Asteroid to begin marking the asteroid.'

    asteroid_1:
      header: 'Mark Asteroid'
      instruction: 'Carefully click on the asteroid in the image to mark it.'

    nextFrame:
      header: 'Next, please!'
      instruction: 'Click on "Next Frame" to advance to the next frame. Alternatively, you may use the frame selection slider below.'

    continueMarkingAsteroids:
      header: 'Continue Marking'
      details: 'The blue mark shows the location of your previous mark. In addition, it let\'s you know you\'ve yet to mark an asteroid in this frame.'
      instruction: 'Continue marking the asteroids on each frame.'

    asteroidDone:
      header: 'Finished marking the asteroid?'
      instruction: 'Once you have completed marking a sequence of asteroids click "Done."'

    markArtifacts:
      header: 'Marking Artifacts'
      details: 'You may see other objects in the images that are not asteroids, but are unique in the image, these may be artifacts. Artifacts typically appear in one frame of the sequence. Unlike asteroids, you don\'t have to track artifacts across the frames. Check out examples of each artifact in the guide.'

    finished:
      header: 'Happy Hunting!'
      details: 'When you are finished with the set of images, click on "Finished" to submit your work and load the next set of images. This concludes the Tutorial.'
