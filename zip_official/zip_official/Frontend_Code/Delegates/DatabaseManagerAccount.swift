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
    /// - `email`: Target email to be checked
    ///  - `completion`: async clusire to return with result
    public func userExists(with userId: String, completion: @escaping (Bool) -> Void) {
        firestore.collection("AllUserIds").document(userId).getDocument { (document, error) in
            guard let document = document else {
                completion(false)
                return
            }
            if document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func createDatabaseUser(user: User, completion: @escaping (Error?) -> Void){
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let joinDate =  formatter.string(from: Date())
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let userData : [String:Any] = [
            "id": user.userId,
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "birthday": Timestamp(date: user.birthday),
            "notifications": EncodePreferences(user.notificationPreferences),
            "picNum": user.picNum,
            "school": "",
            "joinDate": joinDate,
            "deviceId": [deviceId],
            "bio" : "",
            "interests" : []
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
                let image = user.pictures[0]
                guard let data = image.pngData() else {
                    return
                }
                
                StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName, completion: {results in
                    switch results {
                    case .success(let downloadUrl):
                        AppDelegate.userDefaults.set(downloadUrl.description, forKey: "profilePictureUrl")
                        completion(nil)
                    case .failure(let error):
                        print("Storage Manager Error: \(error)")
                        completion(error)
                    }
                })
            }
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: User, completion: @escaping (Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let joinDate =  formatter.string(from: Date())
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        
        let userData : [String:Any] = [
            "id": user.userId,
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "birthday": Timestamp(date: user.birthday),
            "notifications": EncodePreferences(user.notificationPreferences),
            "picNum": user.picNum,
            "school": "",
            "joinDate": joinDate,
            "deviceId": [deviceId],
            "bio" : "",
            "interests" : []
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
            AppDelegate.userDefaults.set(1, forKey: "picNum")
            
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
                let image = user.pictures[0]
                guard let data = image.pngData() else {
                    return
                }
                
                StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName, completion: {results in
                    switch results {
                    case .success(let downloadUrl):
                        AppDelegate.userDefaults.set(downloadUrl.description, forKey: "profilePictureUrl")
                        completion(nil)
                    case .failure(let error):
                        print("Storage Manager Error: \(error)")
                        completion(error)
                    }
                })
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
            "deviceId": user.deviceId
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
            "deviceId": [devId],
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
                let friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int] ?? [:]
                let friendshipInt = friendships[user.userId] ?? -1
                if friendshipInt == -1 {
                    user.friendshipStatus = nil
                } else {
                    user.friendshipStatus = FriendshipStatus(rawValue: friendshipInt)
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
            let imagesPath = "images/" + user.userId
            StorageManager.shared.getAllImagesManually(path: imagesPath, picNum: user.picNum, completion: { result in
                switch result {
                case .success(let url):
                    user.pictureURLs = url
                    print("Successful pull of user image URLS for \(user.fullName) with \(user.pictureURLs.count) URLS ")
                    print(user.pictureURLs)
                    completion(.success(user))

                case .failure(let error):
                    print("error load in LoadUser image URLS -> LoadUserProfile -> LoadImagesManually \(error)")
                }
            })
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
            StorageManager.shared.getProfilePicture(path: imagesPath, completion: { result in
                switch result {
                case .success(let url):
                    if user.pictureURLs.count > 0 {
                        user.pictureURLs[0] = url
                    } else {
                        user.pictureURLs.append(url)
                    }
                    
                    print("Successful pull of user image URLS for \(user.fullName) with \(user.pictureURLs.count) URLS ")
                    print(user.pictureURLs)
                    completion(.success(user))

                case .failure(let error):
                    print("error load in LoadUser image URLS -> LoadUserProfile -> LoadImagesManually \(error)")
                }
                    
            })
        }
    }
    
    public func updatePicNum(id: String, picNum: Int, completion: @escaping (Error?) -> Void) {
        firestore.collection("UserProfiles").document(id).updateData(["picNum" : picNum]) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    
    public func userLoadTableView(user: User, completion: @escaping (Result<User, Error>) -> Void){
        loadUserProfileNoPic(given: user, completion: { result in
            switch result {
            case .success(let user):
                completion(.success(user))
                
                if user.tableViewCell != nil {
                    user.tableViewCell?.configure(user)
                }
                
                StorageManager.shared.getProfilePicture(path: "images/\(user.userId)", completion: { result in
                    switch result {
                    case .success(let url):
                        if user.pictureURLs.count > 0 {
                            user.pictureURLs[0] = url
                        } else {
                            user.pictureURLs.append(url)
                        }
                        
                        guard let cell = user.tableViewCell else {
                            return
                        }
                        cell.configureImage(user)
                    case .failure(let error):
                        print("error loading event in tableview: \(error)")
                    }
                    
                    
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

