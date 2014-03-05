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
      title: 'Hunt for Resource-Rich Asteroids!'
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
     The Catalina Sky Survey (CSS) is the most productive group for finding and cataloging asteroids, having contributed to 46.7% of all the near Earth objects (NEO) discoveries to date.   However, since the CSS examines vast amounts of the sky very quickly and automatically, and therefore computer programs automatically reduce the data to find the asteroids in the images.  These programs are very good at finding bright objects, but are not quite smart enough by themselves to detect the faint ones. Although, humans can look at the detections and validate the program's work. This is where you come in!  With many people participating in Asteroid Zoo, we are able to examine all the images in hopes of finding everything that can be found.  Humans have excellent pattern recognition capabilities and are able to ignore noise that resembles patterns, and this will allow us to improve the existing data over and above anything computers can do.
    '''
    intro_title: 'Introduction'

    intro_content: '''
      <p>Asteroids are small bodies that are leftovers from the formation of the solar system.  They can be as small as a few meters across (equivalent to about a yard), or as large as an asteroid like Ceres, almost 1000 km in diameter (or about 1/12 of Earth). They vary in color from darker than charcoal to the color of freshly broken rock.  Asteroids are found everywhere in our Solar System and have even been found orbiting other stars.  Asteroids (the name means “starlike bodies”) differ from planets in their orbits and general behavior.Typically, asteroid orbits are more inclined (tipped) and more eccentric than any of the planets.</p><br>

      <p>Currently, we believe these small bodies were formed at the dawn of our Solar System but managed to escape being incorporated into a planet or ejected out of the Solar System.  Since they are the remnants of the Solar System’s formation, they represent the conditions in many places within the early Solar System. The Solar System is a big place and conditions were not identical everywhere. Some of the asteroids were formed close to the Sun and are composed of materials that were extensively heated prior to coalescing into a single body. Others formed further out and are composed of materials that never saw temperatures higher than the freezing point of water.  The most extreme cold bodies begin to evaporate as they get close to the Sun; these are called comets.  The line separating comets from asteroids is a thin one.  An unambiguous asteroid from near the orbit of Jupiter could become a comet if it approached the sun too closely.</p>
    '''

    where_title: 'Where we find asteroids'
    where_content: '''
      <img src="./images/science-content/asteroids_where.png">
      <p>There are 632,567 known asteroids as of today.  Most of the known asteroids orbit in the Main Belt, which is between Mars and Jupiter. The objects that get the most attention, however, are the Near Earth Objects (NEOs).  These asteroids have orbits that take them into the vicinity of Earth.  10,687 NEO asteroids have been identified as of today.  Because asteroids slowly change their orbits over time throughout the Solar System, we can find asteroids from all over the Solar System in NEO orbits.   Once an asteroid enters the inner Solar System, it will only remain for a few million years before the orbit evolves into the sun, strikes an inner planet, or is swept up by Jupiter. Three terms in common used describe asteroid orbits:</p>
      <ul>
        <li><p>Amor asteroids approach Earth's orbit from the outside, but do not cross it.  They do not present a current risk to the Earth.</p>
        </li>
        <li><p>Apollo asteroids have orbital periods longer than a year, but cross the Earth's orbit. The February 15, 2013 Chelyabinsk meteor was an Apollo asteroid.</p>
        </li>
        <li><p>Aten asteroids are partially inside the Earth's orbit and have orbital periods shorter than a year, but their orbits are eccentric enough that they cross the Earth's orbit.</p>
        </li>
      </ul>
      <p>Notice, when we say the asteroid crosses the Earth's orbit, the chance of an impact is extremely low because the asteroids' orbits are tilted relative to the Earth's. This asteroid, 2062 Aten, is mostly interior to the Earth's orbit, but at the greatest distance from the Sun, it's outside the Earth's orbit.  If you look at the image from the side, it becomes clear that it's not orbiting in the same place as the Earth and poses no risk.  The colors of the orbit show whether it is North of the Earth's orbit (light blue) or South (medium blue).  Where the colors change is where the asteroid's orbit crosses the plane of the Earth's orbit and would be the only place an impact could occur.</p><br>

      <img src="./images/science-content/2062Aten-1.png">
      <img src="./images/science-content/2062Aten-2.png">
      <p class="caption">Images courtesy of <a href="http://ssd.jpl.nasa.gov">http://ssd.jpl.nasa.gov</a></p><br>
    '''
    composition_title: 'Asteroid Composition'
    composition_content: '''
      <p>Most asteroids we observe fall into three broad categories in terms of their material composition.</p><br>
      <img src="./images/science-content/s-type-1.jpg">
      <p class="caption">Credit: Laurence Garvie, Center for Meteorite Studies, ASU</p><br>

      <img src="./images/science-content/s-type-2.jpg">
      <p class="caption">Credit: Laurence Garvie, Center for Meteorite Studies, ASU</p><br>

      <p>S-type asteroids are composed of rocky material, although the minerals are distinct from terrestrial rocks.  These rocky asteroids dominate the inner portion of the Main Belt and are often found as near earth objects.  Scientists believe they are the source of the ordinary chondrite meteorites, the most commonly found meteorite.  These are composed of material that was heated to melting but not differentiated, that is, the metals never separated from the rock as happened on Earth and so the S-type asteroids are a mixture of rock and metal mixed together.</p><br>

      <img src="./images/science-content/c-type.jpg">
      <p class="caption">Credit: Laurence Garvie, Center for Meteorite Studies, ASU</p><br>

      <p>C-type asteroids are very dark, darker than asphalt, and overall are the most common type that we've observed. They have not been altered by significant heating and closely follow the elemental composition of the sun. Which leads scientists to conclude that C-type asteroids are very primitive objects – they are almost unchanged from their formation at the dawn of the solar system.  When we discuss finding water on asteroids, C-type are the type of asteroid that we refer to.</p><br>

      <img src="./images/science-content/x-type-1.jpg">
      <p class="caption">Credit: Laurence Garvie, Center for Meteorite Studies, ASU</p><br>
      <img src="./images/science-content/x-type-2.jpg">
      <p class="caption">Credit: Laurence Garvie, Center for Meteorite Studies, ASU</p><br>

      <p>X-type asteroids look like their surface are dominated by metal.  They appear to be the remnants of large (> 100 km) asteroids that fully separated into a core and mantle.  Some of the these large asteroids were pulverized in massive collisions early in the Solar System's history leaving only the tough metallic cores today.  Some of these bodies are probably nearly solid lumps of nickel iron with more metal than has been mined on Earth in humanity's history.</p>
    '''
    care_title: 'Why do we care?'
    care_content: '''
      <h3>Science</h3>
      <p>Study of the asteroids helps us understand how planets and the basis for life form and evolve. Since no significant geological processes have taken place on these small bodies, the asteroids preserve a history of the Solar System in a way that the planets do not.  These minor bodies contain relics of the conditions of the early Solar System. </p>
      <h3>Hazards</h3>
      <p>In 1994, Comet Shoemaker-Levy 9 slammed into Jupiter, leaving scars larger than the earth on the giant planet.  We have evidence of other impacts on our planet, even within the last 100 years.  As the events of February 15th, 2013 show in videos and photos from Chelyabinsk, Russia, occasionally one of the asteroids will impact our planet.  Improving the detection efficiency of existing surveys is an excellent way to increase the number of asteroid detections.</p>
      <h3>Resources</h3>
      <p>Asteroids may represent a resource that will bring the Solar System within humanity’s economic sphere of influence.  These resources may be the key to unlocking human expansion from Earth into the Solar System, providing propellant for transportation, oxygen for breathing, water for hydration, shielding from solar radiation, and supporting other aspects of life and industry.  In addition to these lifelines, asteroids provide the raw material for manufacturing in space, from iron, nickel and cobalt present in staggering quantities, to an abundant supply of the extremely useful and valuable platinum group metals.  Just as resources have opened up the frontiers of Earth, they will again do so for the frontiers of space.</p>
    '''

    find_title: 'How do we find asteroids?'
    find_content: '''
      <p>The data in use by the Asteroid Zoo is the product of the Catalina Sky Survey.  After the event on Jupiter in 1994, the United States decided that it would be a national priority to find all potentially dangerous asteroids.  The Catalina Sky Survey (CSS) is funded by NASA to find asteroids, specifically to find all the Near Earth Objects with a radius larger than 100 meters.  They have been gracious enough to share all of their data with the public in order to further the mission of finding as many asteroids as they can.  The facilities consist of three telescopes, two in Arizona and one near Coonabarabran, NSW Australia.  These three telescopes image the sky looking for asteroids.  They take an image of the sky with a roughly 10 second exposure, then move to an adjacent position, take another picture, move and so on for about 10 minutes.  Then the telescope returns to the first pointing and repeats.  This way, the asteroids have time to move and the telescope stays actively looking for new targets.</p> 
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
    title: 'Can I use Asteroid Zoo in the classroom?'
    summary: '''
      <p>Yes! Asteroid Zoo, just like all the Zooniverse projects, offers students a unique opportunity to explore real scientific data, while making a contribution to cutting edge research. We would like to stress that as each image is marked by multiple volunteers, it really does not matter if your students don\'t mark all the features correctly. That being said, the task itself is simple enough that we believe most people can take part and make a worthwhile contribution regardless of age.</p><br>
    '''
    resources_title: 'What resources are there to support use in the classroom?
'
    resources_content: '''
    <p>Videos are a great tool to introduce students to Asteroid Zoo.  Here are a couple of our favorites:</p>

    <ul>
    <li>
      <p>The University of Arizona has created <a href="http://www.youtube.com/watch?v=Mo-FhiIgNws">this video</a> to address people’s questions behind the asteroid strike in Russia</p>
    </li>
    <li>
    <p>The University of Arizona in partnership with NASA and Lockheed Martin developed <a href="http://osiris-rex.lpl.arizona.edu/?q=multimedia">this video</a> for educational purposes.</p>
    </li>
    </ul>
    <p>The Zooniverse has launched ZooTeach where educators can find and share educational resources relating to Asteroid Zoo and the other Zooniverse citizen science projects. Check out resources created for Asteroid Zoo. Have any ideas for how to use the project in the classroom? Please share your lesson ideas or resources on ZooTeach!</p><br>
    
    <h3>Additional Resources</h3>
    <ul>
      <li>
      <p><a href="http://www.minorplanetcenter.net/iau/info/HowNamed.html">How Minor Planets are named</a></p>
      </li>
      <li>
        <p><a href="http://www.iau.org/public/themes/naming/">the official body</a> (but a little less clear)</p>
      </li>
      <li>
        <p><a href="https://www.youtube.com/watch?v=tOKCeW66ncM&list=PL-sncRQpy4-sN0ROwD3a1oR4VivhBBm_X&feature=c4-overview-vl">ORISIS-REX 321 Science link</a></p>
      </li>
    </ul>
    '''

    more_title: 'How can I keep up to date with education and Asteroid Zoo?'
    more_content: '''
      <p>The Asteroid Zoo blog is great place to keep up to date with the latests science results, but there is also a Zooniverse Education Blog as well as a @ZooTeach Twitter feed.
    '''
  ######################
  # TUTORIAL
  ######################
  tutorial:
    
    welcome:
      header: 'Welcome to Asteroid Zoo!'
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
