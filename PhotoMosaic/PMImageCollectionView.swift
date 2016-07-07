//
//  PMImageCollectionView.swift
//  PhotoMosaic
//
//  Created by Emad A. on 6/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit
import ImageIO
import CoreImage

struct PMTiledImageInfo {
    
    let rows: Int
    let cols: Int
    let tiles: [CGImage?]?
    
    init(_ rows: Int, _ cols: Int, _ tiles: [CGImage?]?) {
        self.cols = cols
        self.rows = rows
        self.tiles = tiles
    }
    
}

class PMImageCollectionView: UIView {
    
    let imageTileSize = CGSize(width: 32, height: 32)
    
    // MARK: - Private Properties
    
    private var resizedImage: UIImage?
    private var tiledImageInfo: PMTiledImageInfo?
    
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
    
    let imageView = UIImageView()
    
    // MARK: - Public Methods
    
    func setImage(image: UIImage?) {
        guard let image = image else { return }
        
        resizedImage = resizeImage(image, to: bounds.size)
        tiledImageInfo = cropImage(resizedImage, tileSize: imageTileSize)
        
        collectionView.reloadData()
        setNeedsLayout()
    }
    
    // MARK: - Overriden Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.registerClass(PMImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
        
        imageView.contentMode = .Top
        imageView.backgroundColor = UIColor.redColor()
//        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let collectionViewSize = resizedImage?.size ?? CGSize.zero
        collectionView.frame = CGRect(
            origin: CGPoint(
                x: (bounds.width - collectionViewSize.width) / 2,
                y: CGRectGetMinY(bounds)),
            size: collectionViewSize)
        
        imageView.frame = bounds
    }
    
    // MARK: - Private Methods
    
    private func resizeImage(source: UIImage, to size: CGSize) -> UIImage? {
        // Find the right ratio to scale
        let ratio = max(source.size.width / size.width, source.size.height / size.height)
        // Find the image size after resize and applying the ratio
        let resizedImageSize = CGSize(
            width: floor(source.size.width / ratio),
            height: floor(source.size.height / ratio))
        // Create the bitmat context in which the resized image will be drawn
        let context = CGBitmapContextCreate(
            nil,
            Int(resizedImageSize.width),
            Int(resizedImageSize.height),
            CGImageGetBitsPerComponent(source.CGImage),
            CGImageGetBytesPerRow(source.CGImage),
            CGImageGetColorSpace(source.CGImage),
            CGImageGetBitmapInfo(source.CGImage).rawValue)
        // Draw the image in the calculated size
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: resizedImageSize), source.CGImage!)
        // Create and return the resized image
        return CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0) }
    }
    
    private func cropImage(source: UIImage?, tileSize size: CGSize) -> PMTiledImageInfo {
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
                let image = CGImageCreateWithImageInRect(source?.CGImage, rect)
                print(getAverageColor(ofImage: image))
                tiles.append(image)
            }
        }
        // Create the tiles image info and return
        return PMTiledImageInfo(rows, cols, tiles)
    }
    
    private func getAverageColor(ofImage image: CGImage?) -> UIColor {
        guard let image = image else {
            return UIColor.blackColor().colorWithAlphaComponent(0)
        }
        // Define he size of the rect is needed to draw the avarange color
        let dotSize = CGSize(width: 1, height: 1)
        // Define the bitmap context in which the image will be drawn
        let bytesPerRow = 4
        let bitsPerComponent = 8
        let rgba = UnsafeMutablePointer<UInt8>.alloc(bytesPerRow)
        let context = CGBitmapContextCreate(
            rgba,
            Int(dotSize.width),
            Int(dotSize.height),
            bitsPerComponent,
            bytesPerRow,
            CGColorSpaceCreateDeviceRGB(),
            CGImageAlphaInfo.PremultipliedLast.rawValue)
        // Draw the image
        CGContextDrawImage(context, CGRect(origin: CGPoint.zero, size: dotSize), image)
        // Calculate and retuen the color stored in the pointer
        return UIColor(
            red:   CGFloat(rgba[0]) / 255,
            green: CGFloat(rgba[1]) / 255,
            blue:  CGFloat(rgba[2]) / 255,
            alpha: CGFloat(rgba[3]) / 255)
    }
    
}

// MARK: - UICollectionViewDataSource Extension 

extension PMImageCollectionView: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiledImageInfo?.tiles?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        if let image = tiledImageInfo?.tiles?[indexPath.item] {
            (cell as? PMImageCollectionViewCell)?.imageView.image = UIImage(CGImage: image)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout Extension

extension PMImageCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let image = tiledImageInfo?.tiles?[indexPath.item] {
            return UIImage(CGImage: image).size
        }
        return CGSize.zero
    }
    
}