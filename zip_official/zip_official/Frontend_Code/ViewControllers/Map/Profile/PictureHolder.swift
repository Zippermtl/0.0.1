//
//  PictureHolder.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/13/22.
//

import Foundation
import UIKit

class PictureHolder {
    var isEdited: Bool = false
    var url: URL?
    var image: UIImage?
    var idx: Int
    
    func isUrl() -> Bool {
        if self.url != nil {
            return true
        }
        return false
    }
    
    init(url: URL, edited: Bool = false, index: Int = 0){
        self.url = url
        self.isEdited = edited
        self.idx = index
    }
    
    init(image: UIImage, edited: Bool = false, index: Int = 0){
        self.image = image
        self.isEdited = edited
        self.idx = index
    }
    
   
    
    
    
}
