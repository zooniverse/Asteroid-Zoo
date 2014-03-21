loadImage = (src, cb) ->
  window.app.transporter.load(src).then cb

module.exports = loadImage
