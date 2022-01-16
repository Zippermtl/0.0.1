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
    
    func isUrl() -> Bool {
        if self.url != nil {
            return true
        }
        return false
    }
    
    init(url: URL, edited: Bool = false){
        self.url = url
        self.isEdited = edited
    }
    
    init(image: UIImage, edited: Bool = false){
        self.image = image
        self.isEdited = edited
    }
    
    public func upload(path: String, completion: @escaping (Result<String, Error>) -> Void){
        if isEdited {
            guard let pngData = image?.pngData() else {
                return
            }
            
            StorageManager.shared.uploadProfilePicture(with: pngData, fileName: path, completion: { result in
                switch result {
                case .success(let downloadUrl):
                    completion(.success(downloadUrl))
                case .failure(let error):
                    print("Storage Manager Error: \(error)")
                    completion(.failure(StorageManager.StorageErrors.failedToGetDownloadUrl))
                }
            })
        }
    }
    
    
}
