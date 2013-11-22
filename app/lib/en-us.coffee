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
      title: 'Asteroid Zoo'
      content: '''
       Asteroid Zoo Asteroid Zoo Asteroid Zoo Asteroid Zoo 
      '''
      start: 'Get started!'
    whatDo:
      title: 'What can you do?'
      content: '''
	 Asteroid Zoo Asteroid  Asteroid Zoo Asteroid Zoo 
      '''

  classifier:
    title: 'Classify'
    # TODO condors remanant
    #markTags: 'blurbs'
    #clicking: 'clicking'
    #tapping: 'tapping'
    #proximityNear: 'Near'
    #proximityFar: 'Far'
    ##cantTell: 'Can\'t tell'
    #finished: 'Finished'
    #noTags: 'No tags visible'
    done:  "Finished"
    reset: 'Reset'
    delete: 'Delete'
    next: 'Next'
    whatKind: 'Asteroid or Artifact'

    type:
      asteroid:
        label: 'Asteroid'
      artifact:
        label: 'Artifact'

  #TODO condors reminant
    # marker:
    #   identification: 'Identification'
    #   tagNo: 'Tag no.'
    #   tagHidden: 'Tag number hidden'
    #   proximity: 'Proximity'
    #   proximityExplanation: '<strong>How close</strong> is this zonder to the carcass or scale?'
    #   cancel: 'Cancel'
    #   next: 'Next'
    #   done: 'Done'

      spurious: 'Spurious'
  
  artifacts:
    heading: "Type of Image Artifact"
    starbleed:
      label: 'Star Bleed'
    hotpixel:
      label: 'Hot Pixel'
    other:
      label: 'Other' 
  asteroids:
    heading: "Mark Asteroid"

  #TODO condors reminant
  # presenceInspector:
  #   toggleOriginal: 'Original image'
  #   proximityChange: 'Proximity change'
  #   continue: 'Continue'
  #   finish: 'Finish'

  #TODO condors reminant
  classificationSummary:
    title: 'Summary'
    noTags: '(No tags visible)'
    relativeAge: 'Relative age'
    born: 'Born'
    died: 'Died'
    share: 'Share the story <br />of <small>No.</small> $tag'
    readyForNext: 'Image classified! Ready for the next one?'
    ready: 'Ready!'

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
