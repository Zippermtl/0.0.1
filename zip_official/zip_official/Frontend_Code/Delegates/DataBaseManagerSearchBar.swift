//
//  DataBaseManagerSearchBar.swift
//  zip_official
//
//  Created by user on 6/27/22.
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

extension DatabaseManager {
    
    public func getSearchBarData(queryText: String, event: Bool = false, user: Bool = false, finishedLoadingCompletion: @escaping (Result<SearchObject, Error>) -> Void, allCompletion: @escaping (Result <[SearchObject], Error>) -> Void){
        var finishedEvent = false
        var finishedUsername = false
        var finishedName = false
        var dataholder: [String:SearchObject] = [:]
        if(user){
            print("got here in search fullname ln 27")
            searchFullNameWithUpdates(queryText: queryText, indivCompletion: { res in
                switch res{
                case .success(let uInd1):
                    let tempkey = uInd1.getId()
//                    if (SearchManager.shared.loadedData[tempkey]!.getUrl() == nil as! Bool){
//                        
//                    }
                    print(uInd1.user!)
                    finishedLoadingCompletion(.success(uInd1))
                case .failure(let err1):
                    finishedLoadingCompletion(.failure(err1))
                }
            }, allCompletion: { res in
                switch res{
                case .success(let uInd2):
                    print("gggggg")
                    for i in uInd2 {
                        let id = i.getId()
                        if (dataholder[id] == nil) {
                            dataholder[id] = i
                        }
                    }
                    finishedName = true
                    print("finishing 1 = \(finishedName) + \(finishedUsername) + \(finishedEvent)" )
                    if (event){
                        if(finishedEvent && finishedUsername){
                            print("mmmmmm")
                            allCompletion(.success(Array(dataholder.map({_,value in value}))))
                        }
                    } else if (finishedUsername){
                        allCompletion(.success(Array(dataholder.map({_,value in value}))))
                    }
                case .failure(let err1):
                    allCompletion(.failure(err1))
                }
            })
            
            print("got here in search username ln 54")
            searchUsernameWithUpdates(queryText: queryText, indivCompletion: { res in
                switch res{
                case .success(let uInd1):
                    finishedLoadingCompletion(.success(uInd1))
                case .failure(let err1):
                    finishedLoadingCompletion(.failure(err1))
                }
            }, allCompletion: { res in
                print("gggggg")
                switch res{
                case .success(let uInd2):
                    for i in uInd2 {
                        let id = i.getId()
                        if (dataholder[id] == nil) {
                            dataholder[id] = i
                        }
                    }
                    finishedUsername = true
                    print("finishing 2 = \(finishedName) + \(finishedUsername) + \(finishedEvent)" )

                    if (event){
                        if(finishedEvent && finishedName){
                            print("mmmmmm")
                            allCompletion(.success(Array(dataholder.map({_,value in value}))))
                        }
                    } else if (finishedName){
                        allCompletion(.success(Array(dataholder.map({_,value in value}))))
                    }
                case .failure(let err1):
                    allCompletion(.failure(err1))
                }
            })
            
            
            if(event){
                print("got here in search user ln 79")
                searchEvent(queryText: queryText, indivCompletion: { res in
                    switch res{
                    case .success(let Ind1):
                        finishedLoadingCompletion(.success(Ind1))
                    case .failure(let err):
                        finishedLoadingCompletion(.failure(err))
                    }
                }, allCompletion:{ res in
                    switch res{
                    case .success(let uInd2):
                        print("gggggg")
                        for i in uInd2 {
                            let id = i.getId()
                            if (dataholder[id] == nil) {
                                dataholder[id] = i
                            }
                        }
                        finishedEvent = true
                        print("finishing 3 = \(finishedName) + \(finishedUsername) + \(finishedEvent)" )

                        if(finishedUsername && finishedName){
                            print("mmmmmm")
                            allCompletion(.success(Array(dataholder.map({_,value in value}))))
                        }
                    case .failure(let err1):
                        allCompletion(.failure(err1))
                    }
                })
            }
            
            
        } else if(event){
            print("got here in search event ln 103")
            searchEvent(queryText: queryText, indivCompletion: { res in
                switch res{
                case .success(let Ind1):
                    finishedLoadingCompletion(.success(Ind1))
                case .failure(let err):
                    finishedLoadingCompletion(.failure(err))
                }
            }, allCompletion: { res in
                switch res{
                case .success(let uInd2):
                    print("gggggg")
                    for i in uInd2 {
                        let id = i.getId()
                        if (dataholder[id] == nil) {
                            dataholder[id] = i
                        }
                    }
                    finishedEvent = true
                    allCompletion(.success(Array(dataholder.map({_,value in value}))))
                case .failure(let err1):
                    allCompletion(.failure(err1))
                }
            })
        }
    }
    
    private func searchFullNameWithUpdates(queryText: String, indivCompletion: @escaping (Result<SearchObject, Error>) -> Void, allCompletion: @escaping (Result<[SearchObject], Error>) -> Void){
//        let usernameRef = firestore.collection("UserProfiles")
        let nameRef = firestore.collection("AllUserIds")
        var users: [User] = []
//        var friends = User.getMyZips()
        nameRef.whereField("fullName", isGreaterThanOrEqualTo: queryText).whereField("fullName", isLessThanOrEqualTo: queryText+"~").getDocuments() { [weak self] (querySnapshot, err) in
            guard let strongSelf = self,
                  err == nil else {
                print("Error getting documents: \(err!)")
                allCompletion(.failure(err!))
                return
            }
//            let decoder = JSONDecoder()
            for doc in querySnapshot!.documents {
                print("Doc in query snapshot")
                let dataAr = doc.data()
                let id = doc.documentID
                let fullName = dataAr["fullName"] as? String ?? ""
                let fullNameArr = fullName.components(separatedBy: " ")
                let firstName: String = fullNameArr[0]
                let lastName: String = fullNameArr[1]
                let user = User(userId: id, firstName: firstName, lastName: lastName)
                users.append(user)
                print(user)
//                DatabaseManager.shared.loadUserProfileNoPic(given: user, completion: { res in
//                    switch res {
//                    case .success(let pres):
//                        user = pres
//                        indivCompletion(.success(SearchObject(pres)))
//                        DatabaseManager.shared.
//                    case .failure(let err):
//                        indivCompletion(.failure(err))
//                    }
//                })
                DatabaseManager.shared.loadUserProfile(given: user, completion: { res in
                    switch res {
                    case .success(let pres):
                        print(pres.username + " is present in 149")
                        if let testing = pres.profilePicUrl {
                            print(testing)
                        } else {
                            print("lost url")
                        }
                        let forval = SearchObject(pres)
//                        print(forval.getUrl() as! URL)
                        indivCompletion(.success(SearchObject(pres)))
                    case .failure(let err):
                        indivCompletion(.failure(err))
                    }
                })
            }
            var returns: [SearchObject] = []
            for i in users {
                returns.append(SearchObject(i))
            }
            print("got here FFFFF")
            print(returns.count)
            allCompletion(.success(returns))
//            allCompletion(.success(users))
        }
    }
    
    private func searchUsernameWithUpdates(queryText: String, indivCompletion: @escaping (Result<SearchObject, Error>) -> Void, allCompletion: @escaping (Result<[SearchObject], Error>) -> Void){
//        let usernameRef = firestore.collection("UserProfiles")
        let nameRef = firestore.collection("UserProfiles")
        var users: [User] = []
//        var friends = User.getMyZips()
        nameRef.whereField("username", isGreaterThanOrEqualTo: queryText).whereField("username", isLessThanOrEqualTo: queryText+"~").getDocuments() { [weak self] (querySnapshot, err) in
            guard let strongSelf = self,
                  err == nil else {
                print("Error getting documents: \(err!)")
                allCompletion(.failure(err!))
                return
            }
//            let decoder = JSONDecoder()
            for doc in querySnapshot!.documents {
//                if let dataAr = doc.data(as: UserCoder.self){
//                    let user dataAr.createUser()
//                }
                do {
                    var user = try doc.data(as: UserCoder.self).createUser()
//                    if(friends.contains(user)){
//
//                    }
                    print("203 user:")
                    print(user.description)
                    StorageManager.shared.getProfilePicture(path: "images/\(user.userId)", completion: { res in
                        switch res {
                        case .success(let url):
                            print(user.userId + " profile found")
//                            user.profilePicUrl = url
//                            print(user.profilePicUrl as! URL)
                            let tmp = SearchObject(user)
                            indivCompletion(.success(tmp))
                        case .failure(let err):
                            indivCompletion(.failure(err))
                        }
                        
                    })
                    users.append(user)
                    
                } catch {
                    indivCompletion(.failure(DatabaseError.failedToFetch))
                    continue
                }
//                let dataAr = doc.data()
////                let userId = doc.
//                let userdecoder = try? decoder.decode(UserCoder.self, from: dataAr).createUser()
            }
            var returns: [SearchObject] = []
            for i in users {
                returns.append(SearchObject(i))
            }
            allCompletion(.success(returns))
//            allCompletion(.success(users))
//                for doc in querySnapshot!.documents {
//                    let data = doc.data()
//                    let userdecoder = try decoder.decode(UserCoder.self, from: data).createUser()
//
//                }
//                allCompletion(.success(users))
            
        }
    }
    
    private func searchEvent(queryText: String, indivCompletion: @escaping (Result<SearchObject, Error>) -> Void, allCompletion: @escaping (Result<[SearchObject], Error>) -> Void){
        let nameRef = firestore.collection("EventProfiles")
        var events: [Event] = []
//        var friends = User.getMyZips()
        if(queryText != SearchManager.shared.presQuery) {
            return
        }
        nameRef.whereField("LCTitle", isGreaterThanOrEqualTo: queryText).whereField("LCTitle", isLessThanOrEqualTo: queryText+"~").getDocuments() { [weak self] (querySnapshot, err) in
            guard let strongSelf = self,
                  err == nil else {
                print("Error getting documents: \(err!)")
                allCompletion(.failure(err!))
                return
            }
//            let decoder = JSONDecoder()
            for doc in querySnapshot!.documents {
//                if let dataAr = doc.data(as: UserCoder.self){
//                    let user dataAr.createUser()
//                }
                do {
                    var event = try doc.data(as: EventCoder.self).createEvent()
//                    if(friends.contains(user)){
//
//                    }
                    event.eventId = doc.documentID
                    StorageManager.shared.getProfilePicture(path: "images/\(event.eventId)", completion: { res in
                        switch res {
                        case .success(let url):
                            event.imageUrl = url
                            let temp = SearchObject(event)
                            indivCompletion(.success(temp))
                        case .failure(let err):
                            indivCompletion(.failure(err))
                        }
                        
                    })
                    events.append(event)
                    
                } catch {
                    indivCompletion(.failure(DatabaseError.failedToFetch))
                    continue
                }
            }
            var returns: [SearchObject] = []
            for i in events {
                returns.append(SearchObject(i))
            }
            allCompletion(.success(returns))
            
        }
    }
}
