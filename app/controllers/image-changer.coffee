BaseController = require 'zooniverse/controllers/base-controller'
loadImage = require '../lib/load-image'
MarkingSurface = require 'marking-surface'

class ImageChanger extends BaseController
  #@Controls: require './marking-tool-controls'

  constructor: ->
  	super

  addImage: ->
    #reset the marking surface and load classifcation
    @markingSurface.reset()
    @classification = new Classification {subject}
    framesCount =  subject.location.standard.length
    for i in [0..framesCount-1] by 1
      # # add image element to the marking surface
      frame_id = "frame-id-#{i}"
      frameImage = @markingSurface.addShape 'image',
        id:  frame_id
        class: 'frameImage'
        width: '100%'
        height: '100%'
        preserveAspectRatio: 'none'
     
      img_src = subject.location.standard[i]
      #load the image for this frame
      do (img_src, frameImage)  => 
        loadImage img_src, (img) =>
        frameImage.attr
          'xlink:href': img_src          # get images from api
          #'xlink:href': DEV_SUBJECTS[i]   # use hardcoded static images

    @stopLoading()
    @markingSurface.enable()

module.exports = ImageChanger
