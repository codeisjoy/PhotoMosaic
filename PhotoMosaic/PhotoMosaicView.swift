//
//  PhotoMosaicView.swift
//  PhotoMosaic
//
//  Created by Emad A. on 6/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit
import TakeHomeTask

struct TiledPhotoInfo {
    
    let rows: Int
    let cols: Int
    let tiles: [CGImage?]?
    
    init(_ rows: Int, _ cols: Int, _ tiles: [CGImage?]?) {
        self.cols = cols
        self.rows = rows
        self.tiles = tiles
    }
    
}

class PhotoMosaicView: UIView {
    
    let tileSize = CGSize(width: 32, height: 32)
    
    // MARK: - Private Properties
    
    private var resizedPhoto: UIImage?
    private var tiledPhotoInfo: TiledPhotoInfo?
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    private var collectionViewLayout: UICollectionViewFlowLayout! {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var server = MosaicTileServer()
    
    // MARK: - Public Methods
    
    func setPhoto(photo: UIImage?) {
        guard let photo = photo else { return }
        
        collectionView.alpha = 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] in
            self.resizedPhoto = self.resizePhoto(photo, to: self.bounds.size)
            self.tiledPhotoInfo = self.tilePhoto(self.resizedPhoto, tileSize: self.tileSize)
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
                self.setNeedsLayout()
                UIView.animateWithDuration(0.25, animations: { 
                    self.collectionView.alpha = 1
                })
            }
        }
    }
    
    // MARK: - Overriden Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let collectionViewSize = resizedPhoto?.size ?? CGSize.zero
        collectionView.frame = CGRect(
            origin: CGPoint(
                x: (bounds.width - collectionViewSize.width) / 2,
                y: (bounds.height - collectionViewSize.height) / 2),
            size: collectionViewSize)
    }
    
    // MARK: - Private Methods
    
    private func customInit() {
        collectionView.registerClass(PhotoMosaicViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
    }
    
    private func resizePhoto(source: UIImage, to size: CGSize) -> UIImage? {
        // Find the right ratio to scale
        let ratio = max(source.size.width / size.width, source.size.height / size.height)
        // Find the photo size after resize and applying the ratio
        let resizedPhotoSize = CGSize(
            width: floor(source.size.width / ratio),
            height: floor(source.size.height / ratio))
        // Create the bitmat context in which the resized photo will be drawn
        let context = CGBitmapContextCreate(
            nil,
            Int(resizedPhotoSize.width),
            Int(resizedPhotoSize.height),
            CGImageGetBitsPerComponent(source.CGImage),
            CGImageGetBytesPerRow(source.CGImage),
            CGImageGetColorSpace(source.CGImage),
            CGImageGetBitmapInfo(source.CGImage).rawValue)
        // Draw the image in the calculated size
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: resizedPhotoSize), source.CGImage!)
        // Create and return the resized image
        return CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0) }
    }
    
    private func tilePhoto(source: UIImage?, tileSize size: CGSize) -> TiledPhotoInfo {
        // Calculate the number of columns and rows the image could be sliced to
        let rows = Int(ceil((source?.size.height ?? 0) / size.height))
        let cols = Int(ceil((source?.size.width  ?? 0) / size.width ))
        // Iterate in rows and columns,
        // create an image for each tile and
        var tiles = [CGImage?]()
        for r in (0..<rows) {
            for c in (0..<cols) {
                let rect = CGRect(
                    origin: CGPoint(
                        x: CGFloat(c) * size.width,
                        y: CGFloat(r) * size.height),
                    size: size)
                let photo = CGImageCreateWithImageInRect(source?.CGImage, rect)
                tiles.append(photo)
            }
        }
        // Create the tiles photo info and return
        return TiledPhotoInfo(rows, cols, tiles)
    }
    
    private func getAverageColor(ofPhoto photo: CGImage?, inRect rect: CGRect) -> UIColor {
        guard let photo = photo else {
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

// MARK: - UICollectionViewDataSource Extension 

extension PhotoMosaicView: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiledPhotoInfo?.tiles?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        if let image = tiledPhotoInfo?.tiles?[indexPath.item] {
            (cell as? PhotoMosaicViewCell)?.imageView.image = UIImage(CGImage: image)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout Extension

extension PhotoMosaicView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let image = tiledPhotoInfo?.tiles?[indexPath.item] {
            return UIImage(CGImage: image).size
        }
        return CGSize.zero
    }
    
}

// MARK: - UICollectionViewDelegate Extension

extension PhotoMosaicView: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let tile = tiledPhotoInfo?.tiles?[indexPath.item] else { return }
        let avarageColor = getAverageColor(ofPhoto: tile, inRect: CGRect(origin: CGPoint.zero, size: tileSize))
        server.fetchTileForColor(
            avarageColor,
            size: tileSize,
            success: { image in
                guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoMosaicViewCell else { return }
                UIView.transitionWithView(
                    cell.imageView,
                    duration: 0.52,
                    options: UIViewAnimationOptions.TransitionFlipFromLeft,
                    animations: {
                        cell.imageView.image = image
                    },
                    completion: nil)
            },
            failure: { error in
                print(error)
            })
    }

}
