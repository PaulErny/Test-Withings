//
//  ImageFilterer.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageFilterer {
    static let shared = ImageFilterer()
    private var filters = [FilterName: (UIImage?) -> UIImage?]()
    
    enum FilterName: String {
        case sepia, crystallize, bloom, none,
             hexagonalPixellate = "hex pixels",
             twirlDistortion = "distortion"
    }
    
    private init() {
        filters.updateValue(applySepiaTone, forKey: .sepia)
        filters.updateValue(applyHexPixellateEffect, forKey: .hexagonalPixellate)
        filters.updateValue(applyCrystallizeEffect, forKey: .crystallize)
        filters.updateValue(applyTwirlDistortionEffect, forKey: .twirlDistortion)
        filters.updateValue(applyBloomEffect, forKey: .bloom)
        filters.updateValue(leaveUntouched, forKey: .none)
    }
    
    func applySepiaTone(to image: UIImage?) -> UIImage? {
        guard let image = image else { return image }
        let filter = CIFilter.sepiaTone()
        filter.inputImage = CIImage(image: image)
        filter.intensity = 1
        return bakeOutputImage(from: filter, base: image)
    }
    
    func applyHexPixellateEffect(to image: UIImage?) -> UIImage? {
        guard let image = image else { return image }
        let filter = CIFilter.hexagonalPixellate()
        filter.inputImage = CIImage(image: image)
        filter.scale = 20
        return bakeOutputImage(from: filter, base: image)
    }
    
    func applyCrystallizeEffect(to image: UIImage?) -> UIImage? {
        guard let image = image else { return image }
        let filter = CIFilter.crystallize()
        filter.inputImage = CIImage(image: image)
        filter.radius = 30
        return bakeOutputImage(from: filter, base: image)
    }
    
    func applyTwirlDistortionEffect(to image: UIImage?) -> UIImage? {
        guard let image = image else { return image }
        let input = CIImage(image: image)
        let filter = CIFilter.twirlDistortion()
        filter.inputImage = input
        filter.radius = 1000
        filter.center = CGPoint(x: input!.extent.width / 2, y: input!.extent.height / 2)
        return bakeOutputImage(from: filter, base: image)
    }
    
    func applyBloomEffect(to image: UIImage?) -> UIImage? {
        guard let image = image else { return image }
        let filter = CIFilter.bloom()
        filter.inputImage = CIImage(image: image)
        filter.radius = 100
        filter.intensity = 2
        return bakeOutputImage(from: filter, base: image)
    }
    
    private func bakeOutputImage(from filter: CIFilter, base image: UIImage) -> UIImage? {
        let context = CIContext()
        guard let output = filter.outputImage else { return image }
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }
    
    private func leaveUntouched(image: UIImage?) -> UIImage? {
        return image
    }
    
    private func drawTextOnImage(text: String, image: UIImage?) -> UIImage? {
        guard let image = image else { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            NSAttributedString.Key.foregroundColor: UIColor.red,
                ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size) )
        
        let rect = CGRect(
            origin: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
            size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        )
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func applyRandomFilter(on image: UIImage?, addingFilterName: Bool = false) -> UIImage? {
        let randomFilterIndex = Int.random(in: 0..<filters.count)
        let dictIndex = filters.index(filters.startIndex, offsetBy: randomFilterIndex)
        let chosenFilter = filters.keys[dictIndex]
        let filteredImage = filters[chosenFilter]!(image)
        if addingFilterName {
            return drawTextOnImage(text: chosenFilter.rawValue, image: filteredImage)
        }
        return filteredImage
    }
}
