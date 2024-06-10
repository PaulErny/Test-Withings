//
//  ImageCollectionViewCell.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var checkmark: UIImageView!

    public func setImage(with image: UIImage?) {
        self.image.image = image
    }
}
