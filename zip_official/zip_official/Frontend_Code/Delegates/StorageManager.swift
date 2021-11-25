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
    //MARK: Additive Image Functions
    //MARK: replaces all images with pictures Array, usually useless but some edge cases will be useful later so kept it with slight adjustments
    //Finished Nov 25
    public func ResetUserImages(with pictures: [UIImage], path: String, completion: @escaping UploadPictureCompletion) {
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
        
        SetPicNum(size: pictures.count)
    }
    
    //Finished Nov 25
    public func appendPicture(with pictures: UIImage, path: String, completion: @escaping UploadPictureCompletion) {
        let size = GetNumberOfPictures()
        print("Append single image at index \(size)")
        var fileName = "\(path)" // path = "u6501111111/"
        
        if size == 0 {
            fileName = fileName + "profile_picture.png"
        } else {
            fileName = fileName + "img\(size).png"
        }
        
       
        
        guard let data = pictures.pngData() else {
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
        IncreasePicSize(increase: 1)
    }
    
    public func updateIndividualImage(with pictures: UIImage, path: String, index: Int, completion: @escaping UploadPictureCompletion){
        print("Update single image at index \(index)")
        var fileName = "\(path)" // path = "u6501111111/"
//        if index >= GetNumberOfPictures(){
        //MARK: Yianni Please Read Below
          /*
           If this is included we need to decide what happens when you try to add a picture to an index which does not exist
           yet. Meaning not in the size of the pictures contained in the user. I personally believe we should solve this by
           setting index to the getNumberOfPictures() so that it appends to the end of the list. This also means the if
           statement needs the line below included.
           
           IncreasePicSize(1)
           
           If we do what I said above the else needs to be removed, if you want to throw a specific type of error such as
           out of range than we need the else
           */
//        } else
        if index == 0 {
            fileName = fileName + "profile_picture.png"
        } else {
            fileName = fileName + "img\(index-1).png"
        }
        
       
        
        guard let data = pictures.pngData() else {
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
    }
    
    //MARK: Deletion Picture Functions
    public func DeleteAllPic(){
        SetPicNum(size: 0)
    }
    
    public func PopPicture(){
        IncreasePicSize(increase: -1)
    }
    
    //MARK: Yianni Please Look At This Function And The Comment Below
    public func RemovePicAtIndex(with pictures: [UIImage], path: String, index: Int, completion: @escaping UploadPictureCompletion){
        let size = GetNumberOfPictures() - index - 1
        if(size == 0){
            SetPicNum(size: 0)
        } else if (size < 0){
            //MARK: Yianni Read Below
            //if this occurs the index passed was larger than the amount of pictures in existance and thus the code needs to throw and error, I don't know how to do this in Swift and don't want to figure it out tonight so if you know how to do this please do
        } else {
            IncreasePicSize(increase: -size)
            for i in 0..<(size-1) {
                appendPicture(with: pictures[i+index+1], path: path, completion: {_ in
                    //MARK: Yianni Read Below
                    //I have no idea what to do in this closure as you said something special happens with the closures of pictures but I believe it should work with nothing in it as it is a change to the database without any above method running on top of it
                })
            }
        }

    }
    
    //MARK: Unaltered Functions
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
    
    
    //MARK: Yianni Please Read Below
    //I don't really understand this function to be honest and can't tell how it works, I would just run a for on the grab
    //instead of list all but don't know how to do properly so I didn't do it. To get the number of pictures used the line
    //var size = GetNumberOfPictures()
    //and it should work
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
    private func SetPicNum(size: Int){
        AppDelegate.userDefaults.set(size, forKey: "picNum")
    }
    
    private func IncreasePicSize(increase: Int){
        var size = GetNumberOfPictures()
        size += increase
        AppDelegate.userDefaults.set(size, forKey: "picNum")
    }
    
    public func GetNumberOfPictures() -> Int {
        return AppDelegate.userDefaults.value(forKey: "picNum") as! Int
    }
 
    
}
