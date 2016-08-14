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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    
    // Actions & Outlets
    
    
    @IBAction func btnCamera(sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPhotoLibrary(sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var momentCollection: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.hidesBarsOnTap = false
        
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
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder: PHObjectPlaceholder!
            
            // create the folder
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                    albumPlaceholder = request.placeholderForCreatedAssetCollection
                },
                completionHandler: {(success:Bool, error:NSError?)in
                    if(success){
                        print("Successfully created folder")
                        self.albumFound = true
                        let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collection.firstObject as! PHAssetCollection
                    }
                    else{
                        print("Error creating folder")
                        self.albumFound = false
                    }
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
            if let controller:MomentViewController = segue.destinationViewController as? MomentViewController{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: NSIndexPath = self.momentCollection.indexPathForCell(cell){
                        controller.index = indexPath.item
                        controller.photosAsset = self.photosAsset
                        controller.assetCollection = self.assetCollection
                    }
                }
            }
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
    
    // UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image: UIImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            //Implement if allowing user to edit the selected image
            //let editedImage = info.objectForKey("UIImagePickerControllerEditedImage") as UIImage
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0), {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                    let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photosAsset) {
                        albumChangeRequest.addAssets([assetPlaceholder!])
                    }
                    }, completionHandler: {(success, error)in
                        dispatch_async(dispatch_get_main_queue(), {
                            NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                            picker.dismissViewControllerAnimated(true, completion: nil)
                        })
                })
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}

