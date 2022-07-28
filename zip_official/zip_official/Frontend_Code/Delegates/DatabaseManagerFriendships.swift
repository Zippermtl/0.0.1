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



//MARK: - Friendships
extension DatabaseManager {
    public func loadUserFriendships(given id: String, completion: @escaping (Result<[Friendship], Error>) -> Void) {
        // Get user id inside userFriendships
        database.child("userFriendships").child(id).observe(.value, with: { result in
            guard let value = result.value as? [String: Int] else {
                completion(.success([]))
                return
            }
            
            let friendships = DecodeFriendships(value)
            
            completion(.success(friendships))
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
        database.child("userFriendships/\(otherId)").updateChildValues([selfId: FriendshipStatus.REQUESTED_INCOMING.rawValue]) { [weak self] error, _ in
            guard let strongSelf = self,
                  error == nil else {
                      completion(error!)
                      return
                  }
            strongSelf.database.child("userFriendships/\(selfId)").updateChildValues([otherId: FriendshipStatus.REQUESTED_OUTGOING.rawValue]) { error, _ in
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
        database.child("userFriendships/\(otherId)").updateChildValues([selfId: FriendshipStatus.ACCEPTED.rawValue]) { [weak self] error, _  in
            guard let strongSelf = self,
                  error == nil else {
                      completion(error!)
                      return
                  }
            strongSelf.database.child("userFriendships/\(selfId)").updateChildValues([otherId: FriendshipStatus.ACCEPTED.rawValue]) { error, _ in
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

