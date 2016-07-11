//
//  ViewController.swift
//  PhotoMosaic
//
//  Created by Emad A. on 5/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var hairlineViewConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hairlineViewConstraint?.constant = 1 / UIScreen.mainScreen().scale
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destination = segue.destinationViewController as? TipsViewController
            where segue.identifier == "PresentTips"
        {
            destination.photo = sender as? UIImage
        }
    }
    
    // MARK: - Actions
    
    @IBAction func presentImagePickerControllerWithCamera() {
        presentImagePickerController(.Camera)
    }
    
    @IBAction func presentImagePickerControllerWithLibrary() {
        presentImagePickerController(.PhotoLibrary)
    }
    
    // MARK: - Private Methods
    
    private func presentImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Selected UIImagePickerControllerSourceType is not available.")
            return
        }
        
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        if controller.sourceType == .Camera {
            controller.cameraCaptureMode = .Photo
        }
        controller.delegate = self
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true) { [unowned self] in
            self.performSegueWithIdentifier("PresentTips", sender: image)
        }
    }
    
}

// MARK: - VerticalButton Class
// MARK: -

final class VerticalButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel?.textAlignment = .Center
        imageView?.contentMode = .Center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Find the image frame that put the image at top of the button
        let imageHeight = imageView?.sizeThatFits(bounds.size).height ?? 0
        var tmp = UIEdgeInsetsInsetRect(bounds, imageEdgeInsets).divide(imageHeight, fromEdge: CGRectEdge.MinYEdge)
        var imageFrame = tmp.slice
        // Remainder is where the title label should place in
        tmp.remainder.origin.y += imageEdgeInsets.bottom
        tmp.remainder.size.height -= imageEdgeInsets.bottom
        // Find the title label frame that put it under the image
        let titleHeight = titleLabel?.sizeThatFits(tmp.remainder.size).height ?? 0
        tmp = UIEdgeInsetsInsetRect(tmp.remainder, titleEdgeInsets).divide(titleHeight, fromEdge: CGRectEdge.MinYEdge)
        var titleFrame = tmp.slice
        // Remainder is where should be devided in two to bring the content center
        tmp.remainder.origin.y += titleEdgeInsets.bottom
        tmp.remainder.size.height -= titleEdgeInsets.bottom
        let offset = (CGRectGetMaxY(tmp.remainder) - CGRectGetMinY(tmp.remainder)) / 2
        imageFrame.origin.y += offset
        titleFrame.origin.y += offset
        // Set the final element's frame
        imageView?.frame = imageFrame
        titleLabel?.frame = titleFrame
    }
    
}