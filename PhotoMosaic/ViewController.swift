//
//  ViewController.swift
//  PhotoMosaic
//
//  Created by Emad A. on 5/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit
import ImageIO

class ViewController: UIViewController {
    
    private var photoMosaicCollectionView: PMImageCollectionView?
    
    override func loadView() {
        super.loadView()
        
        let pmcv = PMImageCollectionView()
        photoMosaicCollectionView = pmcv
        view.addSubview(pmcv)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        photoMosaicCollectionView?.setImage(UIImage(named: "h.jpg"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoMosaicCollectionView?.frame = view.bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

