//
//  EiaImage.swift
//  Eia
//
//  Created by Cleofas Pereira on 13/04/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

extension UIImage {
    var tumbnail: UIImage {
        get {
            if let imageData = self.pngData() {
                let tumbnailOptions = [
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: 120] as CFDictionary
                if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) {
                    if let cgTumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, tumbnailOptions) {
                        return UIImage(cgImage: cgTumbnail)
                    }
                }
            }
            return self
        }
    }
}
