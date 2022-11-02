//
//  DataBaseManagerPictures.swift
//  zip_official
//
//  Created by user on 8/15/22.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift
import CodableFirebase
import MessageKit
import FirebaseAuth
import CoreLocation
import GeoFire
import CoreData
import UIKit
import CoreAudio
import simd

extension DatabaseManager{
    
    public enum ImageType: String {
        case picIndices = "picIndices"
        case profileIndex = "profileIndex"
        case eventCoverIndex = "eventCoverIndex"
        case eventPicIndices = "eventPicIndices"
        case groupCoverIndex = "coverIndex"
        case groupPicturesIndices = "pictures"
    }
//    public func updateImages(key: String,
//                             images: [PictureHolder],
//                             forKey: ImageType,
//                             completion: @escaping (Result<[PictureHolder], Error>) -> Void,
//                             completionProfileUrl: @escaping (Result<[PictureHolder],Error>) -> Void){
////        var save : (String,String,[Int],Int) = updateImagesSave { error in
////
////        }
//        switch forKey {
//        case .picIndices:
//            imagesLogic(key: key, images: images, forKey: forKey.rawValue, event: false, completion: { res in
//                switch res{
//                case .success(let im):
//                    completion(.success(im))
//                case .failure(let err):
//                    completion(.failure(err))
//                }
//            }, completionProfileUrl: { res in
//                switch res{
//                case .success(let im):
//                    completionProfileUrl(.success(im))
//                case .failure(let err):
//                    completionProfileUrl(.failure(err))
//                }
//            })
//        case .profileIndex:
//            imagesLogic(key: key, images: images, forKey: forKey.rawValue, event: false, completion: { res in
//                switch res{
//                case .success(let im):
//                    completion(.success(im))
//                case .failure(let err):
//                    completion(.failure(err))
//                }
//            }, completionProfileUrl: { res in
//                switch res{
//                case .success(let im):
//                    completionProfileUrl(.success(im))
//                case .failure(let err):
//                    completionProfileUrl(.failure(err))
//                }
//            })
//        case .eventCoverIndex:
//            imagesLogic(key: key, images: images, forKey: forKey.rawValue, event: true, completion: { res in
//                switch res{
//                case .success(let im):
//                    completion(.success(im))
//                case .failure(let err):
//                    completion(.failure(err))
//                }
//            }, completionProfileUrl: { res in
//                switch res{
//                case .success(let im):
//                    completionProfileUrl(.success(im))
//                case .failure(let err):
//                    completionProfileUrl(.failure(err))
//                }
//            })
//        case .eventPicIndices:
//            imagesLogic(key: key, images: images, forKey: forKey.rawValue, event: true, imagePath: completion: { res in
//                switch res{
//                case .success(let im):
//                    completion(.success(im))
//                case .failure(let err):
//                    completion(.failure(err))
//                }
//            }, completionProfileUrl: { res in
//                switch res{
//                case .success(let im):
//                    completionProfileUrl(.success(im))
//                case .failure(let err):
//                    completionProfileUrl(.failure(err))
//                }
//            })
//        }
//    }
    
    private func updateImagesSave(forKey: String, key: String, indices: [Int], picNum: Int, event: Bool, stash: Int = -2, completion: @escaping (Error?) -> Void){
        if (!event){
            let localRef = firestore.collection("UserProfiles").document("\(key)")
            if (AppDelegate.userDefaults.value(forKey: "picNum") as! Int == picNum) {
                localRef.updateData([forKey : indices]) { err in
                    AppDelegate.userDefaults.set(indices , forKey: forKey)
                    if let err = err {
                        completion(err)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                localRef.updateData([forKey : indices, "picNum" : picNum]) { err in
                    AppDelegate.userDefaults.set(indices , forKey: forKey)
                    AppDelegate.userDefaults.set(picNum , forKey: "picNum")
                    if let err = err {
                        completion(err)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            let localRef = firestore.collection("EventProfiles").document("\(key)")
            if(stash != picNum){
                localRef.updateData([forKey : indices, "picNum" : picNum]) { err in
                    if let err = err {
                        completion(err)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                localRef.updateData([forKey : indices]) { err in
                    if let err = err {
                        completion(err)
                    } else {
                        completion(nil)
                    }
                }
            }
            
        }
        
    }
    
    //MARK: forkey is either picIndices or profileIndex
    public func updateImages(key: String, images: [PictureHolder], imageType: ImageType, event: Bool = false, completion: @escaping (Result<[PictureHolder], Error>) -> Void, completionProfileUrl: @escaping (Result<[PictureHolder],Error>) -> Void){
        let forKey = imageType.rawValue
        let localRef = firestore.collection("UserProfiles").document("\(key)")
        let imageKey = "images/" + key
        var altered: [PictureHolder] = []
        var indices: [Int] = []
        var pres = AppDelegate.userDefaults.value(forKey: "picNum") as! Int
        if(images.count == 0){
            updateImagesSave(forKey: forKey, key: key, indices: [], picNum: pres, event: event) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success([]))
                }
            }
        } else {
            var indicesCopy : [Int] = []
            for i in 0..<images.count {
                if(images[i].isEdited){
                    guard let image = images[i].image else {
                        indices.append(images[i].idx)
                        continue
                    }
                    
                    if (!images[i].isUrl()){
                        images[i].idx = pres + 1
                        pres += 1
                        altered.append(images[i])
                        indices.append(images[i].idx)
                        indicesCopy.append(images[i].idx)
                    }
                } else {
                    indices.append(images[i].idx)
                }
            }
            
            if(altered.count > 0){
                for i in altered {
                    guard let imgtemp = i.image else {
                        continue
                    }
//                    UIImage
                    guard let dataholder = imgtemp.jpegData(compressionQuality: 0.8) else {
                        print("something is very wrong")
                        continue
                    }
                    StorageManager.shared.AddPicture(with: dataholder, key: imageKey, index: i.idx, completion: { [weak self] res in
                        guard let strongself = self else {
                            AppDelegate.userDefaults.set(pres, forKey: "picNum")
                            completion(.failure(StorageManager.StorageErrors.failedToUpload))
                           return
                        }
                        switch res{
                        case .success(let holder):
                            if (forKey == "profileIndex" && images.count == 1){
                                StorageManager.shared.addProfilePicture(with: dataholder, key: imageKey, index: images[0].idx, completion:{ res in
                                    switch res{
                                    case .success(let pics):
                                        var checkadded = false
                                        for j in 0..<images.count{
                                            if (images[j].idx == holder.idx) {
                                                images[j].url = holder.url
                                                checkadded = true
                                            }
                                        }
                                        if(checkadded){
                                            if (AppDelegate.userDefaults.value(forKey: "picNum") as! Int != pres){
                                                localRef.updateData([forKey : indices, "picNum" : pres]) { [weak self] err in
                                                    guard err == nil,
                                                          let strongself = self
                                                         else {
                                                        AppDelegate.userDefaults.set(pres, forKey: "picNum")
                                                        completion(.failure(err!))
                                                       return
                                                    }
                                                    AppDelegate.userDefaults.set(indices , forKey: forKey)
                                                    AppDelegate.userDefaults.set(pres, forKey: "picNum")
                                                    completion(.success(images))
                                                    completionProfileUrl(.success(images))
                                                }
                                            } else {
                                                DatabaseManager.shared.updateImagesSave(forKey: forKey, key: key, indices: indices, picNum: pres, event: event, completion: { err in
                                                    guard err == nil else {
                                                        completion(.failure(err!))
                                                        return
                                                    }
                                                    completion(.success(images))
                                                    completionProfileUrl(.success(images))
                                                })
                                            }
                                        }
                                    case .failure(let error):
                                        completion(.failure(error))
                                        completionProfileUrl(.failure(error))
                                    }
                                })
                                //MARK:
                            } else {
                                if let indexofItem = indicesCopy.firstIndex(of: holder.idx){
                                    indicesCopy.remove(at: indexofItem)
                                    var checkadded = false
                                    for j in 0..<images.count{
                                        if (images[j].idx == holder.idx) {
                                            images[j].url = holder.url
                                            checkadded = true
                                        }
                                    }
                                    if(checkadded && (indicesCopy.count == 0)){
//                                        if (AppDelegate.userDefaults.value(forKey: "picNum") as! Int != pres){
                                        strongself.updateImagesSave(forKey: forKey, key: key, indices: indices, picNum: pres, event: event, completion: { [weak self] err in
                                            guard err == nil,
                                                  let strongself = self
                                                 else {
                                                completion(.failure(err!))
                                               return
                                            }
                                            completion(.success(images))
                                        })
//                                        }
                                        
                                    }
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                }
            } else {
                updateImagesSave(forKey: forKey, key: key, indices: indices, picNum: pres, event: event,completion: { [weak self] err in
                    guard err == nil,
                          let strongself = self
                         else {
                        completion(.failure(err!))
                       return
                    }
                    completion(.success(images))
                })
            }
        }
    }
    //MARK: forKey is either eventCoverIndex or eventPicIndices
    public func updateEventImage(event: Event, images: [PictureHolder], picNumOverride: Int = -1, imageType: ImageType, completion: @escaping (Result<[PictureHolder], Error>) -> Void){
        let forKey = imageType.rawValue
        var picNum = 0
        let localRef = firestore.collection("EventProfiles").document("\(event.eventId)")
        if(picNumOverride != -1) {
            picNum = event.picNum
        } else {
            picNum = picNumOverride
        }
        let key = event.eventId
        let imageKey = "Event/" + key
        var altered: [PictureHolder] = []
        var indices: [Int] = []
        var pres = picNum
        if(images.count == 0){
            localRef.updateData([forKey : []]) { err in
                if let err = err {
                    if(forKey == "eventCoverIndex"){
                        event.eventCoverIndex = []
                    } else {
                        event.eventPicIndices = []
                    }
                    completion(.failure(err))
                } else {
                    completion(.success([]))
                }
            }
        } else {
            var indicesCopy : [Int] = []
            for i in 0..<images.count {
                
                guard let image = images[i].image else {
                    indices.append(images[i].idx)
                    continue
                }
                images[i].idx = pres + 1
                pres += 1
                altered.append(images[i])
                indices.append(images[i].idx)
                indicesCopy.append(images[i].idx)
            }
            
            if(altered.count > 0){
                for i in altered {
                    guard let imgtemp = i.image else {
                        continue
                    }
                    guard let dataholder = imgtemp.jpegData(compressionQuality: 0.8) else {
                        print("something is very wrong")
                        continue
                    }
                    StorageManager.shared.AddPicture(with: dataholder, key: imageKey, index: i.idx, completion: { [weak self] res in
                        guard let strongself = self else {
                            event.picNum = pres
                            completion(.failure(StorageManager.StorageErrors.failedToUpload))
                           return
                        }
                        switch res{
                        case .success(let holder):
                            if (forKey == "eventCoverIndex" && images.count == 1){
                                StorageManager.shared.addProfilePicture(with: dataholder, key: imageKey, index: images[0].idx, completion:{ res in
                                    switch res{
                                    case .success(let pics):
                                        var checkadded = false
                                        for j in 0..<images.count{
                                            if (images[j].idx == holder.idx) {
                                                images[j].url = holder.url
                                                checkadded = true
                                            }
                                        }
                                        if checkadded {
                                            if (picNum != pres){
                                                localRef.updateData([forKey : indices, "picNum" : pres]) { [weak self] err in
                                                    guard err == nil,
                                                          let strongself = self
                                                         else {
                                                             event.picNum = pres
                                                        completion(.failure(err!))
                                                       return
                                                    }
                                                    if(forKey == "eventCoverIndex"){
                                                        event.eventCoverIndex = indices
                                                    } else {
                                                        event.eventPicIndices = indices
                                                    }
                                                    event.picNum = pres
                                                    completion(.success(images))
//                                                    completionCoverUrl(.success(images))
                                                }
                                            } else {
                                                localRef.updateData([forKey : indices]) { [weak self] err in
                                                    guard err == nil,
                                                          let strongself = self
                                                         else {
                                                        completion(.failure(err!))
                                                       return
                                                    }
                                                    if(forKey == "eventCoverIndex"){
                                                        event.eventCoverIndex = indices
                                                    } else {
                                                        event.eventPicIndices = indices
                                                    }
                                                    completion(.success(images))
//                                                    completionCoverUrl(.success(images))
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        completion(.failure(error))
//                                        completionCoverUrl(.failure(error))
                                    }
                                })
                            } else {
                                if let indexofItem = indicesCopy.firstIndex(of: holder.idx){
                                    indicesCopy.remove(at: indexofItem)
                                    var checkadded = false
                                    for j in 0..<images.count{
                                        if (images[j].idx == holder.idx) {
                                            images[j].url = holder.url
                                            checkadded = true
                                        }
                                    }
                                    if(checkadded && (indicesCopy.count == 1)){
                                        if (picNum != pres){
                                            localRef.updateData([forKey : indices, "picNum" : pres]) { [weak self] err in
                                                guard err == nil,
                                                      let strongself = self
                                                     else {
                                                         event.picNum = pres
                                                    completion(.failure(err!))
                                                   return
                                                }
                                                if(forKey == "eventCoverIndex"){
                                                    event.eventCoverIndex = indices
                                                } else {
                                                    event.eventPicIndices = indices
                                                }
                                                event.picNum = pres
                                                completion(.success(images))
                                            }
                                        } else {
                                            localRef.updateData([forKey : indices]) { [weak self] err in
                                                guard err == nil,
                                                      let strongself = self
                                                     else {
                                                    completion(.failure(err!))
                                                   return
                                                }
                                                if(forKey == "eventCoverIndex"){
                                                    event.eventCoverIndex = indices
                                                } else {
                                                    event.eventPicIndices = indices
                                                }
                                                completion(.success(images))
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                }
            } else {
                localRef.updateData([forKey : indices]) { [weak self] err in
                    guard let strongself = self else {
                        completion(.failure(StorageManager.StorageErrors.failedToUpload))
                        return
                    }
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        if(picNum as! Int != pres){
                            event.picNum = pres
                        }
                        if(forKey == "eventCoverIndex"){
                            event.eventCoverIndex = indices
                        } else {
                            event.eventPicIndices = indices
                        }
                        completion(.success([]))
                    }
                }
            }
        }
    }
    
    public func getImages(Id: String, indices: [Int], type: ImageType, completion: @escaping (Result<[URL],Error>)-> Void){
        var indicesCopy = indices
        var key = Id
        var function = -1
        switch type{
        case .eventCoverIndex:
            function = 0
            key = "Event/" + key
        case .eventPicIndices:
            function = 1
            key = "Event/" + key
        case .profileIndex:
            function = 0
            key = "images/" + key
        case .picIndices:
            function = 1
            key = "images/" + key
        case .groupCoverIndex:
            function = 0
            key = "Group/" + key
        case .groupPicturesIndices:
            function = 1
            key = "Group/" + key
        }
        if(function == 0){
//            key = "Event/" + key
//            print("Entering hard coded get profilepicture")
            StorageManager.shared.getProfilePicture(path: key, completion:  { res in
                switch res{
                case .failure(let err):
                    completion(.failure(err))
                case .success(let url):
                    completion(.success([url]))
                }
            })
        } else if (function == 1) {        
            var urls: [Int : URL] = [:]
            var returnUrls: [URL] = []
            if (indices.count == 0){
                completion(.success([]))
            }
            for i in indices {
                StorageManager.shared.getPicture(key: key, index: i, completion: { [weak self] res in
                    guard let strongself = self else {
                        completion(.failure(StorageManager.StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    switch res{
                    case .success(let holder):
                        if let indexofItem = indicesCopy.firstIndex(of: holder.idx){
                            indicesCopy.remove(at: indexofItem)
                            guard let url = holder.url else {
                                completion(.failure(StorageManager.StorageErrors.failedToGetDownloadUrl))
                                return
                            }
                            urls[holder.idx] = url
                            if(indicesCopy.count == 0){
                                for i in indices {
                                    returnUrls.append(urls[i] as! URL)
                                }
                                if(returnUrls.count == indices.count){
                                    completion(.success(returnUrls))
                                } else {
                                    print(returnUrls)
                                    completion(.success(returnUrls))
                                }
                            }
                        } else {
                            completion(.failure(DatabaseError.failedWithIndices))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                })
            }
        }
    }
    
}
