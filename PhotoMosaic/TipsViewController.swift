//
//  TipsViewController.swift
//  PhotoMosaic
//
//  Created by Emad A. on 10/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

class TipsViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView?
    
    var photo: UIImage? {
        didSet { imageView?.image = photo }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.imageView?.image = self.photo
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let nav = segue.destinationViewController as? UINavigationController,
            photoMosaicViewController = nav.topViewController as? PhotoMosaicViewController
        {
            photoMosaicViewController.photo = photo
        }
    }
    
}
