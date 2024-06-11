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
import CoreGraphics

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
    
    private func getAverageImageColor(from image: UIImage) -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }
        let filter = CIFilter.areaAverage()
        filter.inputImage = inputImage
        filter.extent = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    private func generateTextOnImage(text: String, baseImage: UIImage?) -> UIImage? {
        guard let baseImage = baseImage else { return baseImage }
        let averageImageColor = getAverageImageColor(from: baseImage) ?? UIColor.lightGray
        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        let image = renderer.image { context in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 64),
                NSAttributedString.Key.foregroundColor: averageImageColor
            ]

            let myText = text.capitalized
            let attributedString = NSAttributedString(string: myText, attributes: attributes)

            let imageBounds = CGRect(x: 0,
                                    y: 0,
                                    width: baseImage.size.width,
                                    height: baseImage.size.height)
            baseImage.draw(in: imageBounds, blendMode: .normal, alpha: 1)
            attributedString.draw(at: CGPoint(x: imageBounds.width / 2 - attributedString.size().width / 2,
                                              y: imageBounds.height / 1.15))
        }
        return image
    }
    
    func applyRandomFilter(on image: UIImage?, addingFilterName: Bool = false) -> UIImage? {
        let randomFilterIndex = Int.random(in: 0..<filters.count)
        let dictIndex = filters.index(filters.startIndex, offsetBy: randomFilterIndex)
        let chosenFilter = filters.keys[dictIndex]
        let filteredImage = filters[chosenFilter]!(image)
        if addingFilterName {
            return generateTextOnImage(text: chosenFilter.rawValue, baseImage: filteredImage)
        }
        return filteredImage
    }
}
