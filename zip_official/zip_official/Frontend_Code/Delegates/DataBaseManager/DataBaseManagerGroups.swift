//
//  DataBaseManagerGroups.swift
//  zip_official
//
//  Created by user on 10/28/22.
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

extension DatabaseManager {
    
    public func createGroup(group: Group, completion: @escaping (Error?) -> Void){
        var reff : DocumentReference
        let merge = (group.id != "")
        if(group.id == ""){
            reff = firestore.collection("GroupProfiles").document()
            group.id = reff.documentID
        } else {
            reff = firestore.collection("GroupProfiles").document(group.id)
        }
        do {
            try reff.setData(from: group.getEncoder(), merge: merge) { [weak self] err in
                guard let strongSelf = self else {
                    print("ERR")
                    return
                }
                guard err == nil else {
                    print("failure to write group with id: \(group.id) to FireStore")
                    completion(err)
                    return
                }
                strongSelf.addToGroup(group: group, users: group.users, completion: { err1 in
                    guard err1 == nil else {
                        print("failure to write group to member, groupId: \(group.id)")
                        completion(err1)
                        return
                    }
                })
            }
        } catch let error {
            print("failed to create Group \(error)")
            completion(error)
        }
    }
    
    public func getGroup(group: Group, completion: @escaping (Error?) -> Void){
        firestore.collection("GroupProfiles").document(group.id).getDocument(as: GroupCoder.self)  { result in
            switch result {
            case .success(let coder):
                let usId = AppDelegate.userDefaults.value(forKey: "userId") as! String
                if (coder.validate(id: usId)){
                    coder.updateGroup(group: group)
                    completion(nil)
                } else {
                    
                }
            case .failure(let error):
                completion(error)
                print("failed to load group \(group.id): \(error)")
            }
        }
    }
    
    public func updateGroup(group: Group, completion: @escaping (Error?) -> Void){
        firestore.collection("GroupProfiles").document(group.id).updateData(for: group.getEncoder()) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    public func deleteGroup(group: Group, users: [User], completion: @escaping (Error?) -> Void){
        guard group.id != "" else {
            completion(DatabaseError.failedToGetGroupId)
            print("can't add to group without groupId")
            return
        }
        firestore.collection("GroupProfiles").document(group.id).delete() { [weak self] err in
            guard let strongSelf = self else {
                print("can't capture self as strongself in addGroupToUsers")
                return
            }
            guard err == nil else {
                completion(err)
                print("Error removing document: \(err)")
                return
            }
            strongSelf.removeGroupFromUser(users: group.users, group: group, completion: { err1 in
                guard err1 == nil else {
                    completion(err)
                    print("Error removing group from users: \(err)")
                    return
                }
            })
        }
    }

    public func removeFromGroup(group: Group, users: [User], completion: @escaping (Error?) -> Void){
        removeFromGroupUserList(group: group, users: users, completion: { [weak self] err in
            guard let strongSelf = self else {
                print("can't capture self as strongself in addGroupToUsers")
                return
            }
            guard err == nil else {
                completion(err)
                return
            }
            strongSelf.removeGroupFromUser(users: users, group: group, completion: { err1 in
                guard err == nil else {
                    completion(err1)
                    return
                }
            })
        })
    }
    
    public func addToGroup(group: Group, users: [User], completion: @escaping (Error?) -> Void){
        addToGroupUsersList(group: group, users: users, completion: { [weak self] err in
            guard let strongSelf = self else {
                print("can't capture self as strongself in addGroupToUsers")
                return
            }
            guard err == nil else {
                completion(err)
                return
            }
            strongSelf.addGroupToUsers(users: users, group: group, completion: { err1 in
                guard err == nil else {
                    completion(err1)
                    return
                }
            })
        })
    }
    
    private func addToGroupUsersList(group: Group, users: [User], completion: @escaping (Error?) -> Void){
        guard group.id != "" else {
            completion(DatabaseError.failedToGetGroupId)
            print("can't add to group without groupId")
            return
        }
        
        firestore.collection("GroupProfiles").document(group.id).updateData([
            "users" : FieldValue.arrayUnion(users.map({$0.userId}))
        ]) { err in
            guard err == nil else {
                completion(err)
                print("failed to update group's users")
                return
            }
        }
    }
    
    private func addGroupToUsers(users: [User], group: Group, completion: @escaping (Error?) -> Void){
        let lref = firestore.collection("UserProfiles")
        guard group.id != "" else {
            completion(DatabaseError.failedToGetGroupId)
            return
        }
        for i in users {
            lref.document(i.userId).updateData([
                "Groups" : FieldValue.arrayUnion([group.id])
            ]) { err in
                guard err == nil else {
                    print("adding group member failed \(err)")
                    completion(err)
                    return
                }
            }
        }
    }
    
    private func removeFromGroupUserList(group: Group, users: [User], completion: @escaping (Error?) -> Void){
        guard group.id != "" else {
            completion(DatabaseError.failedToGetGroupId)
            print("can't add to group without groupId")
            return
        }
        
        firestore.collection("GroupProfiles").document(group.id).updateData([
            "users" : FieldValue.arrayRemove(users.map({$0.userId}))
        ]) { err in
            guard err == nil else {
                completion(err)
                print("failed to update group's users")
                return
            }
        }
    }
    
    private func removeGroupFromUser(users: [User], group: Group, completion: @escaping (Error?) -> Void){
        let lref = firestore.collection("UserProfiles")
        guard group.id != "" else {
            completion(DatabaseError.failedToGetGroupId)
            return
        }
        for i in users {
            lref.document(i.userId).updateData([
                "Groups" : FieldValue.arrayRemove([group.id])
            ]) { err in
                guard err == nil else {
                    print("adding group member failed \(err)")
                    completion(err)
                    return
                }
            }
        }
    }
}
