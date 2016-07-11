//
//  PhotoMosaicViewCell.swift
//  PhotoMosaic
//
//  Created by Emad A. on 6/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit
import TakeHomeTask

class PhotoMosaicViewCell: UICollectionViewCell {
    
    var photo: UIImage? {
        didSet { imageView.image = photo }
    }
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .TopLeft
        return view
    }()
    
    private var server = MosaicTileServer()
    private var progress: NSProgress?
    
    // MARM: - Overriden Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    // MARK: - Public Methods
    
    func toggleImage() {
        guard let photo = photo else { return }
        progress?.cancel() // Cancel the progress if it is still loading.
        // Fetch the replacement tile from server, if image view is showing the original photo tile.
        if imageView.image == photo {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] in
                let averageColor = photo.getAverageColor(inRect: self.imageView.bounds)
                self.getReplacementImage(forColor: averageColor, completion: { [weak self] image in self?.changeImage(image) })
            }
        }
        // Display original photo tile, if image view is showing the replacement time from server.
        else {
            changeImage(photo)
        }
    }
    
    // MARK: - Private Methods
    
    private func getReplacementImage(forColor color: UIColor, completion: (UIImage -> ())) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.progress = self.server.fetchTileForColor(
                color,
                size: self.imageView.bounds.size,
                success: completion,
                failure: { error in print("Network Error: \(error)") }
            )
        }
    }
    
    private func changeImage(image: UIImage) {
        UIView.transitionWithView(
            self.imageView,
            duration: 0.52,
            options: UIViewAnimationOptions.TransitionFlipFromLeft,
            animations: { [unowned self] in self.imageView.image = image },
            completion: nil)
    }
    
}

// MARK: - UIImage Extension
// MARK: -

extension UIImage {
    
    func getAverageColor(inRect rect: CGRect) -> UIColor {
        guard let photo = CGImage else {
            return UIColor.blackColor().colorWithAlphaComponent(0)
        }
        // Define the bitmap context in which the image will be drawn
        let bitsPerComponent = 8
        let bytesPerRow = Int(4 * rect.size.width)
        let pixels = UnsafeMutablePointer<UInt8>.alloc(bytesPerRow * Int(rect.size.height))
        let context = CGBitmapContextCreate(
            pixels,
            Int(rect.size.width),
            Int(rect.size.height),
            bitsPerComponent,
            bytesPerRow,
            CGImageGetColorSpace(photo),
            CGImageAlphaInfo.PremultipliedLast.rawValue)
        // Draw the photo to be able to get the pixels info
        CGContextDrawImage(context, rect, photo)
        // Calculate the avarage color
        var rgb: (r: CGFloat, g: CGFloat, b: CGFloat) = (0, 0, 0)
        let numberOfPixels = Int(rect.size.width * rect.size.height / 4)
        for i in (0..<numberOfPixels) {
            rgb.r += CGFloat(pixels[i * 4 + 0])
            rgb.g += CGFloat(pixels[i * 4 + 1])
            rgb.b += CGFloat(pixels[i * 4 + 2])
        }
        // Return ...
        return UIColor(
            red:   rgb.r / CGFloat(numberOfPixels) / 255,
            green: rgb.g / CGFloat(numberOfPixels) / 255,
            blue:  rgb.b / CGFloat(numberOfPixels) / 255,
            alpha: 1)
    }
    
}