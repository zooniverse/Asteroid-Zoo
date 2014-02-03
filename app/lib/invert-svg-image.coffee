XLINK_NS = 'http://www.w3.org/1999/xlink'

invertSvgImage = (image, callback) ->
  imageHref = image.getAttributeNS XLINK_NS, 'href'

  canvas = document.createElement 'canvas'
  context = canvas.getContext '2d'

  img = new Image
  img.onload = ->
    console.log 'LOADED'
    canvas.width = img.width
    canvas.height = img.height
    context.drawImage img, 0, 0
    console.log 'DRAWN'

    imageData = context.getImageData 0, 0, img.width, img.height
    data = imageData.data
    for _, i in data by 4
      data[i] = 255 - data[i]
      data[i + 1] = 255 - data[i + 1]
      data[i + 2] = 255 - data[i + 2]
    context.putImageData imageData, 0, 0
    console.log 'INVERTED'

    image.setAttributeNS XLINK_NS, 'href', canvas.toDataURL()
    console.log 'RESET'

    callback? canvas.toDataURL()

  img.src = imageHref

module.exports = invertSvgImage
