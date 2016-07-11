//
//  PhotoMosaicViewController.swift
//  PhotoMosaic
//
//  Created by Emad A. on 11/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

class PhotoMosaicViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var photoView: PhotoMosaicView?
    
    var photo: UIImage? {
        didSet {
            imageView?.image = photo
            photoView?.setPhoto(photo)
        }
    }
    
    // MARK: - Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.image = photo
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        photoView?.setPhoto(photo)
        // To remove the 'Tips & Tricks' view from the hierarchy ...
        let parent = presentingViewController as? UINavigationController
        if let firstVC = parent?.viewControllers.first {
            parent?.viewControllers = [firstVC]
        }
    }
    
    // MARK: - Actions
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
