//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")

// Process the image!
var myRGBA = RGBAImage(image: image!)!

/// Driver funtion for the image processing.
func applyFilters(){
    // Default image.
    image

    // Color amplifier made in class, abstracted into a single function.
    ImageFilters.amplifyColorFilter(image: myRGBA, change: ImageFilters.COLOR.red, by: 200, reverse: false)

    // Brightness amplifier.
    ImageFilters.amplifyBrightnessFilter(image: myRGBA, by: 128)

    // Contrast amplifier.
    ImageFilters.amplifyContrastFilter(image: myRGBA, by: 255)

    // Grey filter.
    ImageFilters.greyFilter(image: myRGBA, intensityFactor: 0.2)

    // Sepia filter.
    ImageFilters.sepiaFilter(image: myRGBA, intensityFactor: 0.2)

    // Sketch-like filter.
    ImageFilters.sketchFilter(image: myRGBA, intensityFactor: 0.3)
}

applyFilters()

