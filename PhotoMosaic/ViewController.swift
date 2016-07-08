//
//  ViewController.swift
//  PhotoMosaic
//
//  Created by Emad A. on 5/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var photoMosaicCollectionView: PMImageCollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        photoMosaicCollectionView?.setImage(UIImage(named: "v.jpg"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

