//
//  ViewController.swift
//  Moments
//
//  Created by Yadwinder Singh on 2016-08-13.
//  Copyright © 2016 Yadwinder. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "My Moments"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    
    // Actions & Outlets
    
    
    @IBAction func btnCamera(sender: AnyObject) {
        
    }
    
    @IBAction func btnPhotoLibrary(sender: AnyObject) {
        
    }
    
    @IBOutlet weak var momentCollection: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the folder exists, if not, create it
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if collection.firstObject != nil {
            // folder exists
            self.albumFound = true
            self.assetCollection = collection.firstObject as! PHAssetCollection
            self.getAssetCollection()
        }
        else{
            // create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                },
                completionHandler: {(success:Bool, error:NSError?)in
                    NSLog("Creation of folder -> %@", (success ? "Success":"Error!"))
                    self.albumFound = (success ? true:false)
                    self.getAssetCollection()
                })
        }
    }
    
    // fetch the photos from collection
    
    func getAssetCollection() {
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        self.momentCollection.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! as String == "viewMomentThumbnail" {
            let controller: MomentViewController = segue.destinationViewController as! MomentViewController
            let indexPath: NSIndexPath = self.momentCollection.indexPathForCell(sender as! UICollectionViewCell)!
            controller.index = indexPath.item
            controller.photosAsset = self.photosAsset
            controller.assetCollection = self.assetCollection
        }
    }

    
    // UICollectionViewDataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if self.photosAsset != nil {
            count = self.photosAsset.count
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: MomentThumbnail = momentCollection.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MomentThumbnail
        
        // Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item] as! PHAsset
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill , options: nil, resultHandler: {(result:UIImage?, info: [NSObject: AnyObject]?) -> Void in
            cell.setThumbnailMoment(result!)
        })
        
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }

}

