//
//  StorageManager.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/5/21.
//

import Foundation
import FirebaseStorage


/// Allows you to get, fetch  and upload files to tfirebases storage
final class StorageManager {
    static let shared = StorageManager()
    
    private init(){}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    ///Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                //failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
                
            })
        })
    }
    
    // MARK: KNOWN BUG
    // if you have 3 images and you try and delete one, it won't go away
    public func updateUserImages(with pictures: [UIImage], path: String, completion: @escaping UploadPictureCompletion) {
        print("Update user images called")
        
        var uploadCount = 0
        
        for image in pictures {
            var fileName = "\(path)" // path = "u6501111111/"
            if uploadCount == 0 {
                fileName = fileName + "profile_picture.png"
            } else {
                fileName = fileName + "img\(uploadCount-1).png"
            }
            
           
            
            guard let data = image.pngData() else {
                return
            }
            
            storage.child("\(fileName)").putData(data, metadata: nil, completion: { [weak self] metaData, error in
                guard error == nil else {
                    //failed
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                self?.storage.child("\(fileName)").downloadURL(completion: { url, error in
                    guard let url = url else {
                        print("Failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("download url returned: \(urlString)")
                    completion(.success(urlString))
                    
                })
            })
            uploadCount += 1
        }
        
    }
    
    /// upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                //failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
                
            })
        })
    }
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                //failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
                
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void ){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
            
        })
    }
    
    public func getAllImages(for path: String, completion: @escaping (Result<[URL], Error>) -> Void ) {
        storage.child(path).listAll(completion: { (result,error) in
            let urls = result.items
            guard !urls.isEmpty, error == nil else {
                      completion(.failure(StorageErrors.failedToGetDownloadUrl))
                      return
                  }
        
            
            completion(.success(urls.map({ URL(string: $0.description)! })))

        })
        
    }
    
}
