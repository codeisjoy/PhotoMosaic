//
//  PMImageCollectionViewCell.swift
//  PhotoMosaic
//
//  Created by Emad A. on 6/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

class PMImageCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .TopLeft
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blueColor()
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
}
