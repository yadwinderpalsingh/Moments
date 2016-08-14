//
//  MomentViewController.swift
//  Moments
//
//  Created by Yadwinder Singh on 2016-08-13.
//  Copyright © 2016 Yadwinder. All rights reserved.
//

import UIKit
import Photos

class MomentViewController: UIViewController {
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0
    
    @IBAction func btnExport(sender: AnyObject) {
        print("Export")
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Delete Photo", style: .Default,
            handler: {(alertAction)in
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    //Delete Photo
                    if let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection){
                        request.removeAssets([self.photosAsset[self.index]])                    }
                    },
                    completionHandler: {(success, error)in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        
                        if(success){
                            // Move to the main thread to execute
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                                if(self.photosAsset.count == 0){
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }else{
                                    if(self.index >= self.photosAsset.count){
                                        self.index = self.photosAsset.count - 1
                                    }
                                    self.displayMoment()
                                }
                            })
                        }
                    }
                )
            })
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {(alertAction)in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var moment: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MomentViewController.swiped(_:))) // put : at the end of method name
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(MomentViewController.swiped(_:))) // put : at the end of method name
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        
        self.displayMoment()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        // Select a type of animation (.Fade, .Slide or .None)
        return UIStatusBarAnimation.Slide
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMoment() {
        let imageManager = PHImageManager.defaultManager()
        imageManager.requestImageForAsset(self.photosAsset[index] as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit , options: PHImageRequestOptions(), resultHandler: {(result:UIImage?, info: [NSObject: AnyObject]?) -> Void in
           
            UIView.transitionWithView(self.moment,
                duration:0.5,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: { self.moment.image = result },
                completion: nil)
            }
        )
        
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Right :
                index -= 1
                
                if index < 0 {
                    index = self.photosAsset.count - 1
                }
                
                self.moment.image = nil
                self.displayMoment()
                
            case UISwipeGestureRecognizerDirection.Left:
                index += 1
                
                if index > self.photosAsset.count - 1 {
                    index = 0
                }
                
                self.moment.image = nil
                self.displayMoment()
                
            default:
                break
            }
        }
    }
}
