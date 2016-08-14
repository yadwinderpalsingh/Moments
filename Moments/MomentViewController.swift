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

    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnExport(sender: AnyObject) {
        print("Export")
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        print("Trash")
    }
    
    @IBOutlet weak var moment: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        
        self.displayMoment()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMoment() {
        let imageManager = PHImageManager.defaultManager()
        imageManager.requestImageForAsset(self.photosAsset[index] as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit , options: nil, resultHandler: {(result:UIImage?, info: [NSObject: AnyObject]?) -> Void in
                self.moment.image = result
        })
    }

}
