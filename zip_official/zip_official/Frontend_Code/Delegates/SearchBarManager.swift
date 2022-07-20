//
//  SearchBarManager.swift
//  zip_official
//
//  Created by user on 6/27/22.
//

import Foundation
import FirebaseDatabase

class SearchManager{
    static let shared = SearchManager()
    var loadedEvents: [Event] = []
    var loadedUsers: [User] = []
//    var unfinishedUsers: [User] = []
//    var unfinishedEvents: [Event] = []
//    var tempData = NSDictionary
    var searchString: String = ""
    
    init(){
    }
    
    public func searchBarUserFullName(first: String, last: String, completion: @escaping (Error?) -> Void){
        if searchString == first + " " + last {
            print("dryFire")
            completion(nil)
        } else {
            searchString = first + " " + last
            loadedUsers = []
            DatabaseManager.shared.searchUserWithoutUpdates(first: first, last: last, username: "") { _ in
                completion(nil)
                for i in SearchManager.shared.loadedUsers {
                    let temp = SearchManager.shared.loadedUsers
                    print(i.fullName)
                }
            }
        }
    }
    
    public func searchBarUserName(username: String, completion: @escaping (Error?) -> Void){
        if searchString == username {
            completion(nil)
        } else {
            searchString = username
            loadedUsers = []
            DatabaseManager.shared.searchUserWithoutUpdates(first: "", last: "", username: username) { _ in
                completion(nil)
            }
        }
    }
    
    public func searchBarEvent(input: String, completion: @escaping (Error?) -> Void){
        if searchString == input {
            completion(nil)
        } else {
            searchString = input
            loadedEvents = []
            DatabaseManager.shared.searchEventWithoutUpdates(name: input) { _ in
                
                var temp = SearchManager.shared.loadedEvents
                for i in SearchManager.shared.loadedEvents {
                    print(i.title)
                }
                completion(nil)
            }
        }
    }
    
    public func searchBoth(input: String, completion: @escaping (Error?) -> Void){
        if searchString == input {
            completion(nil)
        } else {
            searchString = input
            loadedUsers = []
            loadedEvents = []
            DatabaseManager.shared.searchEventWithoutUpdates(name: input) { _ in
                
//                var temp = SearchManager.shared.loadedEvents
                for i in SearchManager.shared.loadedEvents {
                    print(i.title)
                }
                let tp = input.split(separator: " ")
                if (tp.count > 1) {
                    DatabaseManager.shared.searchUserWithoutUpdates(first: String(tp[0]), last: String(tp[1]), username: input) { _ in
                        completion(nil)
                    }
                } else {
                    DatabaseManager.shared.searchUserWithoutUpdates(first: "", last: "", username: input) { _ in
                        let a = SearchManager.shared.loadedUsers
                        completion(nil)
                    }
                }
                
            }
        }
    }
    
}

