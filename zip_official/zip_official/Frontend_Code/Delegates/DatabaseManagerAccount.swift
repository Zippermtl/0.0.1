//
//  DatabaseManagerAccount.swift
//  zip_official
//
//  Created by user on 7/27/22.
//

import Foundation
import FirebaseDatabase
import MessageKit
import FirebaseAuth
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

//MARK: - Account Management
extension DatabaseManager {
    /// checks if user exists for given email
    /// parameters
    ///  - `completion`: async clusire to return with result
    public func userExists(with userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        firestore.collection("AllUserIds").document(userId).getDocument { (document, error) in
            guard error == nil  else {
                completion(.failure(error!))
                return
            }
            
            if let document = document {
                if document.exists {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            } else {
                completion(.success(false))
            }
           
        }
    }
    
    public func createDatabaseUser(user: User, completion: @escaping (Error?) -> Void){
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let userData : [String:Any] = [
            "id": user.userId,
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "birthday": Timestamp(date: user.birthday),
            "gender": user.gender,
            "notifications": EncodePreferences(user.notificationPreferences),
            "picNum": user.picNum,
            "school": "",
            "joinDate": Timestamp(date: Date()),
            "deviceId": [deviceId],
            "bio" : "",
            "interests" : [],
            "picIndices" : user.picIndices,
            "profileIndex" : user.profilePicIndex
        ]
        firestore.collection("UserProfiles").document("\(user.userId)").setData(userData)  { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                print("failure to create user with id: \(user.userId) to FireStore")
                completion(error)
                return
            }
            
            strongSelf.firestore.collection("AllUserIds").document("\(user.userId)").setData([user.userId:user.fullName])
            
            if user.pictures.count != 0 {
                let image = PictureHolder(image: user.pictures[0])
//                guard let data = image.pngData() else {
//                    return
//                }
                DatabaseManager.shared.updateImages(key: user.userId, images: [image], forKey: "profileIndex", completion: { res in
                    switch res{
                    case .success(let urls):
//                        guard let urls = url else {
//                            completion(nil)
//                            return
//                        }
                        AppDelegate.userDefaults.set(urls[0].url?.absoluteString, forKey: "profilePictureUrl")
                        completion(nil)
                    case .failure(let error):
                        print("storage manager error \(error)")
                        completion(error)
                    }
                    
                }, completionProfileUrl: {_ in})
//                StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName, completion: {results in
//                    switch results {
//                    case .success(let downloadUrl):
//                        AppDelegate.userDefaults.set(downloadUrl.description, forKey: "profilePictureUrl")
//                        completion(nil)
//                    case .failure(let error):
//                        print("Storage Manager Error: \(error)")
//                        completion(error)
//                    }
//                })
            }
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: User, completion: @escaping (Error?) -> Void) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString

        let userData : [String:Any] = [
            "id": user.userId,
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "birthday": Timestamp(date: user.birthday),
            "gender": user.gender,
            "notifications": EncodePreferences(user.notificationPreferences),
            "notificationToken": [String](),
            "picNum": user.picNum,
            "school": "",
            "joinDate": Timestamp(date: Date()),
            "deviceId": [deviceId],
            "bio" : "",
            "interests" : [],
            "picIndices" : user.picIndices,
            "profileIndex" : user.profilePicIndex
        ]
        
        
        firestore.collection("UserProfiles").document("\(user.userId)").setData(userData)  { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                print("failure to create user with id: \(user.userId) to FireStore")
                completion(error)
                return
            }
            
            strongSelf.firestore.collection("AllUserIds").document("\(user.userId)").setData([user.userId:user.fullName])
            
            AppDelegate.userDefaults.set(user.userId, forKey: "userId")
            AppDelegate.userDefaults.set(user.username, forKey: "username")
            AppDelegate.userDefaults.set(user.fullName, forKey: "name")
            AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
            AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
            AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
            AppDelegate.userDefaults.set(user.gender, forKey: "gender")
            AppDelegate.userDefaults.set(0, forKey: "picNum")
            AppDelegate.userDefaults.set(user.profilePicIndex, forKey: "profileIndex")
            AppDelegate.userDefaults.set(user.picIndices, forKey: "picIndices")
            
            let emptyFriendships: [String: [String:String]]  = [:]
            AppDelegate.userDefaults.set(emptyFriendships, forKey:  "friendships")
            let emptyEvents: [String : Int] = [:]
            AppDelegate.userDefaults.set(emptyEvents, forKey:  "savedEvents")

            AppDelegate.userDefaults.set(EncodePreferences(user.notificationPreferences), forKey: "encodedNotificationSettings")

            AppDelegate.userDefaults.setValue(2, forKey: "maxRangeFilter")

            if user.pictures.count == 0 {
                //TODO: add default image
                AppDelegate.userDefaults.set("", forKey: "profilePictureUrl")
                completion(nil)
            } else {
                let image = PictureHolder(image: user.pictures[0])
                DatabaseManager.shared.updateImages(key: user.userId, images: [image], forKey: "profileIndex", completion: { res in
                    switch res{
                    case .success(let urls):
//                        guard let urls = url else {
//                            completion(nil)
//                            return
//                        }
                        AppDelegate.userDefaults.set(urls[0].url?.absoluteString, forKey: "profilePictureUrl")
                        completion(nil)
                    case .failure(let error):
                        print("storage manager error \(error)")
                        completion(error)
                    }
                    
                }, completionProfileUrl: {_ in})
//                StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName, completion: {results in
//                    switch results {
//                    case .success(let downloadUrl):
//                        AppDelegate.userDefaults.set(downloadUrl.description, forKey: "profilePictureUrl")
//                        completion(nil)
//                    case .failure(let error):
//                        print("Storage Manager Error: \(error)")
//                        completion(error)
//                    }
//                })
            }
        }
    }
    
    public func createUserLookUp(location: CLLocation, completion: @escaping (Error?) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
              let name = AppDelegate.userDefaults.value(forKey: "firstName") as? String,
              let last = AppDelegate.userDefaults.value(forKey: "lastName") as? String else {
                  return
              }
        
        firestore.collection("UserFastInfo").document("\(userId)").setData([
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude,
            "name": name + " " + last
        ]) { error in
            guard error == nil  else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    public func updateLocationUserLookUp(location: CLLocation, completion: @escaping (Error?) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        firestore.collection("UserFastInfo").document("\(userId)").setData([
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude
        ]) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    /// Updates the full user profile
    public func updateUser(with user: User, completion: @escaping (Error?) -> Void) {
        
        let userData: [String:Any] = [
            "id": user.userId,
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "bio": user.bio,
            "school": user.school ?? "",
            "picNum": user.picNum,
            "interests": user.interests.map{ $0.rawValue },
            "notifications": EncodePreferences(user.notificationPreferences),
            "picIndices" : user.picIndices,
            "profileIndex" : user.profilePicIndex
        ]
        
        firestore.collection("UserProfiles").document(user.userId).updateData(userData) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    public func updateDeviceId(devId: String, completion: @escaping (Error?) -> Void) {
        let userData: [String:[String]] = [
            "deviceId": [devId]
        ]
        
        firestore.collection("UserProfiles").document(AppDelegate.userDefaults.value(forKey: "userId") as! String).updateData(userData) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    public func updateNotificationPreferences(prefs: NotificationPreference, completion: @escaping (Error?) -> Void) {
        let userData: [String:Int] = [
            "notifications": EncodePreferences(prefs),
        ]
        firestore.collection("UserProfiles").document(AppDelegate.userDefaults.value(forKey: "userId") as! String).updateData(userData) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    public func updateNotificationToken(token: String, completion: @escaping (Error?) -> Void) {
        let userData: [String:[String]] = [
            "notificationToken": [token],
        ]
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
        firestore.collection("UserProfiles").document(userId).updateData(userData) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
                                                                           
    /// Gets all users from Firebase
    ///  Parameters
    ///   `completion`: async closure to deal with return result
    public func getAllUserIds(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        firestore.collection("AllUserIds").getDocuments() { (querySnapshot,error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            var out : [String:Any] = [:]
            for document in querySnapshot!.documents {
                document.data().forEach { (key, value) in out[key] = value }
            }
            
            completion(.success(out))
        }
    }
    
   
    
}

//MARK: - User Data Retreival
extension DatabaseManager {
    public func loadUserProfileNoPic (given user: User, completion: @escaping (Result<User, Error>) -> Void) {
        firestore.collection("UserProfiles").document(user.userId).getDocument(as: UserCoder.self)  { result in
            switch result {
            case .success(let userCoder):
                if user.userId == AppDelegate.userDefaults.value(forKey: "userId") as? String ?? ""{
                    user.friendshipStatus = .ACCEPTED
                } else {
                    if let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]],
                        let friendshipString = raw_friendships[user.userId]?["status"],
                        let friendshipInt = Int(friendshipString) {
                        user.friendshipStatus = FriendshipStatus(rawValue: friendshipInt)
                    } else {
                        user.friendshipStatus = nil
                    }
                }
                userCoder.updateUser(user)
                completion(.success(user))
            case .failure(let error):
                print("failed to load user \(user.userId): \(error)")
            }
        }
    }
    
    public func loadUserProfile(given user: User, completion: @escaping (Result<User, Error>) -> Void) {
        loadUserProfileNoPic(given: user, completion: { result in
//            let imagesPath = "images/" + user.userId
            //MARK: GABE TODO --> finished needs test function
            let id = user.userId
            let index = user.picIndices
            let proindex = user.profilePicIndex
            DatabaseManager.shared.getImages(key: id, indices: proindex, completion: { res in
                switch res {
                case .success(let url):
                    user.profilePicUrl = url[0]
                    DatabaseManager.shared.getImages(key: id, indices: index, completion: { res in
                        switch res {
                        case.success(let urls):
                            user.pictureURLs = urls
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                            print("failed to get non profile pictures with getImages")
                        }
                    })
                case .failure(let error):
                    completion(.failure(error))
                    print("failed getImages for Profile picture")
                }
            })
        })
    }
    //MARK: Gabe todo --> test function needed
    
    /// loads uer profile
    /// - `user`: user to load
    /// - `dataCompletion`: completion fired after all firestore user data is loaded
    /// - `pictureCompletion`: completion fired after storage manager data is loaded
    public func loadUserProfile(given user: User,
                                dataCompletion: @escaping (Result<User, Error>) -> Void,
                                pictureCompletion: @escaping (Result<[URL], Error>) -> Void) {
        
        loadUserProfileNoPic(given: user, completion: { result in
            switch result {
            case .success(let user):
//                let imagesPath = "images/" + user.userId
                dataCompletion(.success(user))
                DatabaseManager.shared.getImages(key: user.userId, indices: user.profilePicIndex, completion: { res in
                    switch res {
                    case .success(let url):
                        user.profilePicUrl = url[0]
                        if( user.picIndices.count > 0){
                            DatabaseManager.shared.getImages(key: user.userId, indices: user.picIndices, completion: { res in
                                switch res {
                                case.success(let urls):
                                    user.pictureURLs = urls
                                    pictureCompletion(.success(urls))
                                case .failure(let error):
                                    pictureCompletion(.failure(error))
                                    print("failed to get non profile pictures with getImages")
                                }
                            })
                        } else {
                            pictureCompletion(.success(url))
                        }
                       
                    case .failure(let error):
                        pictureCompletion(.failure(error))
                        print("failed getImages for Profile picture")
                    }
                })
//                StorageManager.shared.getAllImagesManually(path: imagesPath, picNum: user.picNum, completion: { result in
//                    print("GETTING ALL IMAGES")
//                    switch result {
//                    case .success(let url):
//                        user.pictureURLs.append(url)
//                        user.pictureURLs = user.pictureURLs.sorted(by: { $0.description.imgNumber < $1.description.imgNumber})
//
//                        print("Successful pull of user image URLS for \(user.fullName) with \(user.pictureURLs.count) URLS ")
//                        print(user.pictureURLs)
//                        if user.pictureURLs.count == user.picNum {
//                            pictureCompletion(.success(user.pictureURLs))
//                        }
//
//                    case .failure(let error):
//                        pictureCompletion(.failure(error))
//                        print("error load in LoadUser image URLS -> LoadUserProfile -> LoadImagesManually \(error)")
//                    }
//                })
            case .failure(let error):
                print("FAILURE TO LOAD BOTH USER AND PHOTOS")
                dataCompletion(.failure(error))
                pictureCompletion(.failure(error))
            }
        })
    }
    
    public func loadUserProfileSubView(given id: String, completion: @escaping (Result<User, Error>) -> Void) {
        firestore.collection("UserFastInfo").document(id).getDocument() { (document,error) in
//            print("document = ", document)
//            print("document.data() = ", document?.data())

            guard let document = document,
                  let docData = document.data() as? [String:[String:Any]],
                  let data = docData["id"] else {
//                completion(.failure(error!))
                return
            }
            
            let user = User(userId: id)
            let names = (data["name"] as! String).components(separatedBy: " ")
            user.firstName = names[0]
            user.lastName = names[1]
            user.location = CLLocation(latitude: data["lat"] as! Double, longitude: data["long"] as! Double)
            
            let imagesPath = "images/" + id
            DatabaseManager.shared.getImages(key: user.userId, indices: user.profilePicIndex, completion: { res in
                switch res {
                case .success(let url):
                    user.profilePicUrl = url[0]
                    completion(.success(user))

                case .failure(let error):
                    print("error load in LoadUser image URLS -> LoadUserProfile -> getImages \(error)")
                }
            })
        }
    }
    
    public func updateGender(gender: String, completion: @escaping (Error?) -> Void) {
        let id = AppDelegate.userDefaults.value(forKey: "userId") as! String
        firestore.collection("UserProfiles").document(id).updateData(["gender" : gender]) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    //MARK: Gabe todo --> finished needs testing
    public func userLoadTableView(user: User, completion: @escaping (Result<User, Error>) -> Void){
        loadUserProfileNoPic(given: user, completion: { result in
            switch result {
            case .success(let user):
                completion(.success(user))
                
                if user.tableViewCell != nil {
                    user.tableViewCell?.configure(user)
                }
                var key = user.userId
                var index = user.profilePicIndex
                DatabaseManager.shared.getImages(key: key, indices: index, completion: { res in
                    switch res{
                    case .success(let url):
                        user.profilePicUrl = url[0]
                    case .failure(let error):
                        print("error loading event in tableview: \(error)")
                    }
                    guard let cell = user.tableViewCell else {
                        return
                    }
                    cell.configureImage(user)
//                StorageManager.shared.getProfilePicture(path: "images/\(user.userId)", completion: { result in
//                    switch result {
//                    case .success(let url):
//                        if user.pictureURLs.count > 0 {
//                            user.pictureURLs[0] = url
//                        } else {
//                            user.pictureURLs.append(url)
//                        }
//
//                        guard let cell = user.tableViewCell else {
//                            return
//                        }
//                        cell.configureImage(user)
//                    case .failure(let error):
//                        print("error loading event in tableview: \(error)")
//                    }
                    
                    
                })
            case .failure(let error):
                print("error loading user in tableview: \(error)")
                completion(.failure(error))
            }
        })
        
    }
    
//    public func batchPull(idList: [User], completion: @escaping (Error?) -> Void){
//        let sfRef = firestore.collection("UserProfiles")
//
//        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
//            let sfDocument: DocumentSnapshot
//            for i in idList.indices {
//                let sfReference = sfRef.document(idList[i].userId)
//                do {
//                    try sfDocument = transaction.getDocument(sfReference)
//                } catch let fetchError as NSError {
//                    errorPointer?.pointee = fetchError
//                    return nil
//                }
//                guard let oldPopulation = sfDocument.data()?["firstName"] as? String else {
//                    let error = NSError(
//                        domain: "AppErrorDomain",
//                        code: -1,
//                        userInfo: [
//                            NSLocalizedDescriptionKey: "Unable to retrieve firstName from snapshot \(sfDocument)"
//                        ]
//                    )
//                    errorPointer?.pointee = error
//                    return nil
//                }
//                guard let oldPopulation = sfDocument.data()?["lastName"] as? String else {
//                    let error = NSError(
//                        domain: "AppErrorDomain",
//                        code: -1,
//                        userInfo: [
//                            NSLocalizedDescriptionKey: "Unable to retrieve lastName from snapshot \(sfDocument)"
//                        ]
//                    )
//                    errorPointer?.pointee = error
//                    return nil
//                }
//                guard let oldPopulation = sfDocument.data()?["userName"] as? String else {
//                    let error = NSError(
//                        domain: "AppErrorDomain",
//                        code: -1,
//                        userInfo: [
//                            NSLocalizedDescriptionKey: "Unable to retrieve userName from snapshot \(sfDocument)"
//                        ]
//                    )
//                    errorPointer?.pointee = error
//                    return nil
//                }
//            }
//
//
//
//
//            // Note: this could be done without a transaction
//            //       by updating the population using FieldValue.increment()
//            let newPopulation = oldPopulation + 1
//            guard newPopulation <= 1000000 else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -2,
//                    userInfo: [NSLocalizedDescriptionKey: "Population \(newPopulation) too big"]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//
//            transaction.updateData(["population": newPopulation], forDocument: sfReference)
//            return newPopulation
//        }) { (object, error) in
//            if let error = error {
//                print("Error updating population: \(error)")
//            } else {
//                print("Population increased to \(object!)")
//            }
//        }
//    }
    
}





extension DatabaseManager {
    public func BBBinsertUser(with user: User, completion: @escaping (Error?) -> Void) {
            let deviceId = UIDevice.current.identifierForVendor!.uuidString

            let userData : [String:Any] = [
                "id": user.userId,
                "username": user.username,
                "firstName": user.firstName,
                "lastName": user.lastName,
                "birthday": Timestamp(date: user.birthday),
                "gender": user.gender,
                "notifications": EncodePreferences(user.notificationPreferences),
                "notificationToken": [String](),
                "picNum": user.picNum,
                "school": "",
                "joinDate": Timestamp(date: Date()),
                "deviceId": [deviceId],
                "bio" : "",
                "interests" : [],
                "picIndices" : [],
                "profileIndex" : []
            ]
            
            
            firestore.collection("UserProfiles").document("\(user.userId)").setData(userData)  { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    print("failure to create user with id: \(user.userId) to FireStore")
                    completion(error)
                    return
                }
                
                strongSelf.firestore.collection("AllUserIds").document("\(user.userId)").setData([user.userId:user.fullName])
                
                AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                AppDelegate.userDefaults.set(user.username, forKey: "username")
                AppDelegate.userDefaults.set(user.fullName, forKey: "name")
                AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
                AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
                AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
                AppDelegate.userDefaults.set(user.gender, forKey: "gender")
                AppDelegate.userDefaults.set(0, forKey: "picNum")
                AppDelegate.userDefaults.set([], forKey: "profileIndex")
                AppDelegate.userDefaults.set([], forKey: "picIndices")
                
                let emptyFriendships: [String: Int]  = [:]
                AppDelegate.userDefaults.set(emptyFriendships, forKey:  "friendships")
                let emptyEvents: [String : Int] = [:]
                AppDelegate.userDefaults.set(emptyEvents, forKey:  "savedEvents")

                AppDelegate.userDefaults.set(EncodePreferences(user.notificationPreferences), forKey: "encodedNotificationSettings")

                AppDelegate.userDefaults.setValue(2, forKey: "maxRangeFilter")

                if user.pictures.count == 0 {
                    //TODO: add default image
                    AppDelegate.userDefaults.set("", forKey: "profilePictureUrl")
                    completion(nil)
                } else {
                    let image = PictureHolder(image: user.pictures[0], index: user.picNum)
                    DatabaseManager.shared.updateImages(key: user.userId, images: [image], forKey: "profileIndex", completion: { res in
                        switch res{
                        case .success(let urls):
    //                        guard let urls = url else {
    //                            completion(nil)
    //                            return
    //                        }
                            AppDelegate.userDefaults.set(urls[0].url?.absoluteString, forKey: "profilePictureUrl")
                            completion(nil)
                        case .failure(let error):
                            print("storage manager error \(error)")
                            completion(error)
                        }
                        
                    }, completionProfileUrl: {_ in})
    //                StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName, completion: {results in
    //                    switch results {
    //                    case .success(let downloadUrl):
    //                        AppDelegate.userDefaults.set(downloadUrl.description, forKey: "profilePictureUrl")
    //                        completion(nil)
    //                    case .failure(let error):
    //                        print("Storage Manager Error: \(error)")
    //                        completion(error)
    //                    }
    //                })
                }
            }
        }
}
//MARK: Depreciated
//public func updateImages(key: String, images: [PictureHolder], forKey: String, completion: @escaping (Result<[PictureHolder], Error>) -> Void){
//        let localRef = firestore.collection("UserProfiles").document("\(key)")
//        var altered: [PictureHolder] = []
//        var indices: [Int] = []
//        var pres = AppDelegate.userDefaults.value(forKey: "picNum") as! Int
//        if(images.count == 0){
//            localRef.updateData([forKey : []]) { err in
//                if let err = err {
//                    AppDelegate.userDefaults.set([] , forKey: forKey)
//                    completion(.failure(err))
//                } else {
//                    completion(.success([]))
//                }
//            }
//        } else {
//            var indicesCopy : [Int] = []
//            for i in 0..<images.count {
//
//                guard let image = images[i].image else {
//                    indices.append(images[i].idx)
//                    continue
//                }
//                images[i].idx = pres + 1
//                pres += 1
//                altered.append(images[i])
//                indices.append(images[i].idx)
//                indicesCopy.append(images[i].idx)
//            }
//
//            if(altered.count > 0){
//                for i in altered {
//                    guard let imgtemp = i.image else {
//                        continue
//                    }
//                    guard let dataholder = imgtemp.jpegData(compressionQuality: 0.8) else {
//                        print("something is very wrong")
//                        continue
//                    }
//                    StorageManager.shared.AddPicture(with: dataholder, key: key, index: i.idx, completion: { [weak self] res in
//                        guard let strongself = self else {
//                            AppDelegate.userDefaults.set(pres, forKey: "picNum")
//                            completion(.failure(StorageManager.StorageErrors.failedToUpload))
//                           return
//                        }
//                        switch res{
//                        case .success(let holder):
//                            if let indexofItem = indicesCopy.firstIndex(of: holder.idx){
//                                indicesCopy.remove(at: indexofItem)
//                                var checkadded = false
//                                for j in 0..<images.count{
//                                    if (images[j].idx == holder.idx) {
//                                        images[j].url = holder.url
//                                        checkadded = true
//                                    }
//                                }
//                                if(checkadded && (indicesCopy.count == 0)){
//                                    if (AppDelegate.userDefaults.value(forKey: "picNum") as! Int != pres){
//                                        localRef.updateData([forKey : indices, "picNum" : pres]) { [weak self] err in
//                                            guard err == nil,
//                                                  let strongself = self
//                                                 else {
//                                                AppDelegate.userDefaults.set(pres, forKey: "picNum")
//                                                completion(.failure(err!))
//                                               return
//                                            }
//                                            AppDelegate.userDefaults.set(indices , forKey: forKey)
//                                            AppDelegate.userDefaults.set(pres, forKey: "picNum")
//                                            completion(.success(images))
//                                        }
//                                    } else {
//                                        localRef.updateData([forKey : indices]) { [weak self] err in
//                                            guard err == nil,
//                                                  let strongself = self
//                                                 else {
//                                                completion(.failure(err!))
//                                               return
//                                            }
//                                            AppDelegate.userDefaults.set(indices , forKey: forKey)
//                                            completion(.success(images))
//                                        }
//                                    }
//
//                                }
//                            }
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                    })
//                }
//            } else {
//                localRef.updateData([forKey : indices]) { [weak self] err in
//                    guard let strongself = self else {
//                        completion(.failure(StorageManager.StorageErrors.failedToUpload))
//                        return
//                    }
//                    if let err = err {
//                        completion(.failure(err))
//                    } else {
//                        if(AppDelegate.userDefaults.value(forKey: "picNum") as! Int != pres){
//                            AppDelegate.userDefaults.set(pres, forKey: "picNum")
//                        }
//                        AppDelegate.userDefaults.set([] , forKey: forKey)
//                        completion(.success([]))
//                    }
//                }
//            }
//        }
//    }
