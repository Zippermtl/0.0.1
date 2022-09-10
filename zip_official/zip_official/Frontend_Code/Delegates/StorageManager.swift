//
//  StorageManager.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/5/21.
//

import Foundation
import FirebaseStorage

//MARK: GABE TO DO IN PHOTOS TODO LIST
/*
 //MARK: Finished
 - fix upload to not overwrite everytime -- way to many write to cold storage
 - Upload 3 --> Delete 2 --> 3 images left
 - upload 3 --> delete 1 --> 3 images left

 
 - because load all images loads all imgs overwritten
 - uploading images overwrites but no deletes

 
 - write this function somewhere
 - func getNumberOfPictures()
 
 
 */

/// Allows you to get, fetch  and upload files to tfirebases storage
final class StorageManager {
    static let shared = StorageManager()
    
    private init(){}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    
    public func getPicture(key: String, index: Int, completion: @escaping (Result<PictureHolder,Error>) -> Void) {
        let filename = key + "/" + "img\(index).jpeg"
        self.downloadURL(for: filename, completion: { result in
//            print("got here in getPicture")
            switch result {
            case .success(let url):
                print("url sample")
                print(key)
                print(url)
                completion(.success(PictureHolder(url: url, index: index)))
            case .failure(let error):
                print("failed to get image URL: \(error)")
                completion(.failure(error))
            }
        })
    }
    
    //adds pictures
    //MARK: DO NOT USE UNLESS YOU UNDERSTAND THAT IT DOES NOT AUTO INCREMENT FOR YOU
    public func AddPicture(with data: Data, key: String, index: Int, completion: @escaping (Result<PictureHolder,Error>) -> Void) {
        let filename =  key + "/" + "img\(index).jpeg"
        storage.child(filename).putData(data, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                //failed
                print("failed")
                print(error)
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            print("succeeded")
            self?.storage.child(filename).downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(PictureHolder(url: url, index: index)))
                
            })
        })
    }
    
    //MARK: Unaltered Functions
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void ){
        print(path)
//        let test = "images/u6503333333/profile_picture.png"
//        print(test)
        let reference = storage.child(path)
//        print("got past ref")
        reference.downloadURL(completion: { url, error in
//            print("pre-guard \(path)")
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
            
        })
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
    
    //MARK: Helper Functions For Readability
//    public func SetPicNum(size: Int){
//        AppDelegate.userDefaults.set(size, forKey: "picNum")
//    }
    
//    private func IncreasePicSize(increase: Int){
//        var size = GetNumberOfPictures()
//        size += increase
//        AppDelegate.userDefaults.set(size, forKey: "picNum")
//    }
    
    public func GetNumberOfPictures() -> Int {
        let temp =  AppDelegate.userDefaults.value(forKey: "picIndices") as! [Int]
        return temp.count
    }
    
    public func getProfilePicture(path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let tempPath = path + "/profile_picture.jpeg"
        self.downloadURL(for: tempPath, completion: { result in
            print("got here in getProfilePicture")
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                print("failed to get image URL: \(error)")
            }
        })
    
    }
    
    public func addProfilePicture(with data: Data, key: String, index: Int, completion: @escaping (Result<PictureHolder, Error>) -> Void){
        let filename = key + "/profile_picture.jpeg"
        storage.child(filename).putData(data, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                //failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child(filename).downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(PictureHolder(url: url, index: index)))
                
            })
        })
    }
    
}



