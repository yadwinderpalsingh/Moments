 //
//  MomentThumbnail.swift
//  Moments
//
//  Created by Yadwinder Singh on 2016-08-14.
//  Copyright © 2016 Yadwinder. All rights reserved.
//

import UIKit

class MomentThumbnail: UICollectionViewCell {
    
    
    @IBOutlet weak var momentView: UIImageView!
    
    func setThumbnailMoment(thumbnailMoment: UIImage) {
        self.momentView.image = thumbnailMoment
    }
}
