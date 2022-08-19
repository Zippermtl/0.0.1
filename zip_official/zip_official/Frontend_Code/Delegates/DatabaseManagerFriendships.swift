//
//  DatabaseManagerFriendships.swift
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
import SwiftUI



//MARK: - Friendships
extension DatabaseManager {
    public func loadUserFriendships(given id: String, completion: @escaping (Result<[Friendship], Error>) -> Void) {
        // Get user id inside userFriendships
        database.child("userFriendships").child(id).observe(.value, with: { result in
            guard let value = result.value as? [String: Any] else {
                completion(.success([]))
                return
            }

            let friendships = DecodeFriendships(value)
            completion(.success(friendships))
        })
    }
    
    public func loadUserZipsIds(given id: String, completion: @escaping (Result<[User], Error>) -> Void) {
        loadUserFriendships(given: id, completion: { result in
            switch result {
            case .success(let friendships):
                let users = friendships.filter({ $0.status == FriendshipStatus.ACCEPTED }).map({ $0.receiver })
                completion(.success(users))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    
    
    public func unsendRequest(user: User, completion: @escaping (Error?) -> Void) {
        let otherId = user.userId
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        database.child("userFriendships/\(otherId)/\(selfId)").removeValue() { [weak self] error, _ in
            guard let strongSelf = self,
                    error == nil else {
                        completion(error!)
                return
            }
            strongSelf.database.child("userFriendships/\(selfId)/\(otherId)").removeValue() { error, _ in
                guard error == nil else {
                    completion(error!)
                    return
                }
                completion(nil)
            }
        }
    }
    
    // Requests a friend
    public func sendRequest(user: User, completion: @escaping (Error?) -> Void) {
        let otherId = user.userId
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let name = AppDelegate.userDefaults.value(forKey: "name")  as? String ?? ""
        let username = AppDelegate.userDefaults.value(forKey: "username")
        
        database.child("userFriendships/\(otherId)").updateChildValues([selfId: ["status" : FriendshipStatus.REQUESTED_INCOMING.rawValue,
                                                                                 "name" : name,
                                                                                 "username" : username]
                                                                       ]) { [weak self] error, _ in
            guard let strongSelf = self,
                  error == nil else {
                      completion(error!)
                      return
                  }
            
            
            
            strongSelf.database.child("userFriendships/\(selfId)").updateChildValues([user.userId: ["status" : FriendshipStatus.REQUESTED_OUTGOING.rawValue,
                                                                                                    "name" : user.fullName,
                                                                                                    "username" : user.username]
                                                                                     ]) { error, _ in
                guard error == nil else {
                    completion(error!)
                    return
                }
                completion(nil)
            }
        }
    }

    // Accepts a friend (who made a friend request)
    public func acceptRequest(user: User, completion: @escaping (Error?) -> Void) {
        let otherId = user.userId
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let name = AppDelegate.userDefaults.value(forKey: "name")  as? String ?? ""
        let username = AppDelegate.userDefaults.value(forKey: "username")
        database.child("userFriendships/\(otherId)").updateChildValues([selfId: ["status" : FriendshipStatus.ACCEPTED.rawValue,
                                                                                 "name" : name,
                                                                                 "username" : username]
                                                                       ]) { [weak self] error, _ in
            guard let strongSelf = self,
                  error == nil else {
                      completion(error!)
                      return
                  }
            
            
            
            strongSelf.database.child("userFriendships/\(selfId)").updateChildValues([user.userId: ["status" : FriendshipStatus.ACCEPTED.rawValue,
                                                                                                    "name" : user.fullName,
                                                                                                    "username" :  user.username]
                                                                                     ]) { error, _ in
                guard error == nil else {
                    completion(error!)
                    return
                }
                completion(nil)
            }
        }
    }

    // Rejects a friend (who made a friend request)
    public func rejectRequest(user: User, completion: @escaping (Error?) -> Void) {
        let otherId = user.userId
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        database.child("userFriendships/\(otherId)/\(selfId)").removeValue() { [weak self] error, _ in
            guard let strongSelf = self,
                    error == nil else {
                        completion(error!)
                return
            }
            
            strongSelf.database.child("userFriendships/\(selfId)/\(otherId)").removeValue() { error, _ in
                guard error == nil else {
                    completion(error!)
                    return
                }
                completion(nil)
            }
        }
    }
    
    // Unfriends user
    public func unfriend(user: User, completion: @escaping (Error?) -> Void) {
        let otherId = user.userId
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        database.child("userFriendships/\(otherId)/\(selfId)").removeValue() { [weak self] error, _ in
            guard let strongSelf = self,
                    error == nil else {
                        completion(error!)
                return
            }
            strongSelf.database.child("userFriendships/\(selfId)/\(otherId)").removeValue() { error, _ in
                guard error == nil else {
                    completion(error!)
                    return
                }
                completion(nil)
            }
        }
    }

}

