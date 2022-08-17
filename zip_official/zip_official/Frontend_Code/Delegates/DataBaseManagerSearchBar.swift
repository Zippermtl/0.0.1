//
//  DataBaseManagerSearchBar.swift
//  zip_official
//
//  Created by user on 6/27/22.
//

import Foundation
import FirebaseDatabase
import MessageKit
import FirebaseAuth
import CoreLocation

extension DatabaseManager {
    public func searchUserWithUpdates(first: String, last: String, username: String, completion: @escaping ((Error?) -> Void)){
        database.child("userProfiles").observe(.childAdded, with: {
            (snapshot) in
            let keyvalue = snapshot.key
//            print("aaaaaaaaaa")
            let bio = snapshot.childSnapshot(forPath: "bio").value
            let datefix = DateFormatter()
            datefix.dateFormat = "MM-dd-yy"
            var canadd = true
            let birthday = datefix.date(from: snapshot.childSnapshot(forPath: "birthday").value as! String)
            let firstname = snapshot.childSnapshot(forPath: "firstName").value as! String
            let notifications = snapshot.childSnapshot(forPath: "notifications").value
            let picNum = snapshot.childSnapshot(forPath: "picNum").value
            let school = snapshot.childSnapshot(forPath: "school").value as! String
            let lastname = snapshot.childSnapshot(forPath: "lastName").value as! String
            let userN = snapshot.childSnapshot(forPath: "username").value as! String
            print(snapshot)
            print("birthday")
            print(birthday)
//            DatabaseManager.shared.filterUser(users: allChildren!, first: first, last: last, username: "", completion: {_ in
//                completion(nil)
//            })
//                .children.allObjects
//            for snap in allChildren {
//                print(snap.key)
                
//                let bio = snap.childSnapshot(forPath: "bio")
//                let birthday = snap.childSnapshot(forPath: "birthday") as Date
//                let firstname = snap.childSnapshot(forPath: "firstName") as String
//                let notifications = snap.childSnapshot(forPath: "notifications")
//                let picnum = snap.childSnapshot(forPath: "picnum")
//                let school = snap.childSnapshot(forPath: "school") as String
//                let lastname = snap.childSnapshot(forPath: "lastName") as String
//                let username = snap.childSnapshot(forPath: "username") as String
            let temp = User(userId: keyvalue, username: userN, firstName: firstname, lastName: lastname, birthday: birthday!, picNum: picNum as! Int, bio: bio as! String, school: school)
                SearchManager.shared.loadedUsers.append(temp)
                print(temp)
//            }
            if(username != ""){
                if(temp.username.lowercased().contains(username.lowercased()) || temp.username.lowercased() == username.lowercased()){
                    SearchManager.shared.loadedUsers.append(temp)
                    canadd = false
                }
            }
            if(first != "" && last != ""){
                if(temp.fullName.lowercased().contains(first.lowercased()) || temp.fullName.lowercased().contains(last.lowercased())){
                    if canadd {
                        SearchManager.shared.loadedUsers.append(temp)
                    }
                }
            }
            completion(nil)
            //SearchManager.shared.loadedUsers.append(contentsOf: snapshot)
        }) { (error) in
            print(error.localizedDescription)
            completion(error)
        }
        
//        firebase.database().ref('users')
//            .orderByChild('user_details/username')
//            .equalTo(username)
//            .once('value', snapshot => {
//              if (!snapshot.exists()) {
//                console.log('No users found')
//              }
//              else {
//                snapshot.forEach(child => {
//                  console.log('User found: '+child.key)
//                });
//              }
//            });
    }
//    database.child("userProfiles").observeSingleEvent(of: DataEventType.value, with: T##(FIRDataSnapshot) -> Void)
    public func searchUserWithoutUpdates(first: String, last: String, username: String, completion: @escaping ((Error?) -> Void)){
        database.child("userProfiles").observeSingleEvent(of: DataEventType.value, with: {
            (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                var canadd = true
                let keyvalue = rest.key
//                print("aaaaaaaaaa")
                let bio = rest.childSnapshot(forPath: "bio").value
                let datefix = DateFormatter()
                datefix.dateFormat = "MM-dd-yy"
                let birthday = datefix.date(from: rest.childSnapshot(forPath: "birthday").value as! String)
                let firstname = rest.childSnapshot(forPath: "firstName").value as! String
                let notifications = rest.childSnapshot(forPath: "notifications").value
                let picNum = rest.childSnapshot(forPath: "picNum").value
                let school = rest.childSnapshot(forPath: "school").value as! String
                let lastname = rest.childSnapshot(forPath: "lastName").value as! String
                let userN = rest.childSnapshot(forPath: "username").value as! String
                let temp = User(userId: keyvalue, username: userN, firstName: firstname, lastName: lastname, birthday: birthday!, picNum: picNum as! Int, bio: bio as! String, school: school)
//                    SearchManager.shared.loadedUsers.append(temp)
                    print(temp)
    //            }
                let copy = SearchManager.shared.loadedUsers
                if(username != ""){
                    if(temp.username.lowercased().contains(username.lowercased()) || temp.username.lowercased() == username.lowercased()){
                        if canadd {
                            SearchManager.shared.loadedUsers.append(temp)
                            canadd = false
                        }
                    }
                }
                if(first != "" && last != ""){
                    if canadd {
                        if(temp.fullName.lowercased().contains(first.lowercased()) || temp.fullName.lowercased().contains(last.lowercased())){
                            SearchManager.shared.loadedUsers.append(temp)
                        }
                    }
                }
            }
//            let keyvalue = snapshot.key
//            print("aaaaaaaaaa")
//            let bio = snapshot.childSnapshot(forPath: "bio").value
//            let datefix = DateFormatter()
//            datefix.dateFormat = "MM-dd-yy"
//            let birthday = datefix.date(from: snapshot.childSnapshot(forPath: "birthday").value as! String)
//            let firstname = snapshot.childSnapshot(forPath: "firstName").value as! String
//            let notifications = snapshot.childSnapshot(forPath: "notifications").value
//            let picnum = snapshot.childSnapshot(forPath: "picNum").value
//            let school = snapshot.childSnapshot(forPath: "school").value as! String
//            let lastname = snapshot.childSnapshot(forPath: "lastName").value as! String
//            let userN = snapshot.childSnapshot(forPath: "username").value as! String
//            print(snapshot)
//            print("birthday")
//            print(birthday)
//            DatabaseManager.shared.filterUser(users: allChildren!, first: first, last: last, username: "", completion: {_ in
//                completion(nil)
//            })
//                .children.allObjects
//            for snap in allChildren {
//                print(snap.key)
                
//                let bio = snap.childSnapshot(forPath: "bio")
//                let birthday = snap.childSnapshot(forPath: "birthday") as Date
//                let firstname = snap.childSnapshot(forPath: "firstName") as String
//                let notifications = snap.childSnapshot(forPath: "notifications")
//                let picnum = snap.childSnapshot(forPath: "picnum")
//                let school = snap.childSnapshot(forPath: "school") as String
//                let lastname = snap.childSnapshot(forPath: "lastName") as String
//                let username = snap.childSnapshot(forPath: "username") as String
//            let temp = User(userId: keyvalue, username: userN, firstName: firstname, lastName: lastname, birthday: birthday!, picNum: picnum as! Int, bio: bio as! String, school: school)
//                SearchManager.shared.loadedUsers.append(temp)
//                print(temp)
////            }
//            if(username != ""){
//                if(temp.username.contains(username) || temp.username == username){
//                    SearchManager.shared.loadedUsers.append(temp)
//                }
//            }
//            if(first != "" && last != ""){
//                if(temp.fullName.contains(first) || temp.fullName.contains(last)){
//                    SearchManager.shared.loadedUsers.append(temp)
//                }
//            }
            completion(nil)
            //SearchManager.shared.loadedUsers.append(contentsOf: snapshot)
        }) { (error) in
            print(error.localizedDescription)
            completion(error)
        }
        
//        firebase.database().ref('users')
//            .orderByChild('user_details/username')
//            .equalTo(username)
//            .once('value', snapshot => {
//              if (!snapshot.exists()) {
//                console.log('No users found')
//              }
//              else {
//                snapshot.forEach(child => {
//                  console.log('User found: '+child.key)
//                });
//              }
//            });
    }
    
    public func searchEventWithUpdates(name: String, completion: @escaping ((Error?) -> Void)){
        database.child("eventProfiles").observe(.childAdded, with: {
            (snapshot) in
//            var addtolist = true
            let keyvalue = snapshot.key
//            print(keyvalue)
            print("bbbbb")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            print(snapshot.childSnapshot(forPath: "username").value)
            let bio = snapshot.childSnapshot(forPath: "bio").value
            let address = snapshot.childSnapshot(forPath: "address").value
            let lat = snapshot.childSnapshot(forPath: "coordinates").childSnapshot(forPath: "lat").value
            let long = snapshot.childSnapshot(forPath: "coordinates").childSnapshot(forPath: "long").value
            let desc = snapshot.childSnapshot(forPath: "description").value
            let endtime = formatter.date(from: snapshot.childSnapshot(forPath: "endTime").value as! String)
            let starttime = formatter.date(from: snapshot.childSnapshot(forPath: "startTime").value as! String)
            let max = snapshot.childSnapshot(forPath: "max").value
            let title = snapshot.childSnapshot(forPath: "title").value
            let type = snapshot.childSnapshot(forPath: "type").value
            var hosts: [User] = []
//            print("cccc")
//            print(snapshot.childSnapshot(forPath: "hosts"))
//            print("BbbbbBBbbB")
//            print(snapshot)
            for rest in snapshot.childSnapshot(forPath: "hosts").children.allObjects as! [DataSnapshot] {
                let keyval = rest.key
                let dataval = rest.value as! String
                let names = dataval.split(separator: " ")
                let temp = User(userId: keyval, firstName: String(names[0]), lastName: String(names[1]))
                hosts.append(temp)
            }
            let temp = zip_official.createEvent(eventId: keyvalue, title: title as! String, coordinates: CLLocation(latitude: lat as! Double, longitude: long as! Double), hosts: hosts, description: desc as! String, address: address as! String, maxGuests: max as! Int, startTime: starttime!, endTime: endtime!, type: EventType(rawValue: type as! Int)!)
            if(temp.title.lowercased().contains(name.lowercased())){
                SearchManager.shared.loadedEvents.append(temp)
            } else {
                for i in temp.hosts {
                    if(i.username.lowercased().contains(name.lowercased()) || i.fullName.lowercased().contains(name.lowercased())){
                        SearchManager.shared.loadedEvents.append(temp)
                    } else if (i.username.lowercased() == name.lowercased() || i.fullName.lowercased() == name.lowercased()){
                        SearchManager.shared.loadedEvents.append(temp)
                    }
                }
            }

//
        }) { (error) in
            print(error.localizedDescription)
            completion(error)
        }
    }
    
    public func searchEventWithoutUpdates(name: String, completion: @escaping ((Error?) -> Void)){
        database.child("eventProfiles").observeSingleEvent(of: DataEventType.value, with: {
            (ds) in
            for snapshot in ds.children.allObjects as! [DataSnapshot] {
                let keyvalue = snapshot.key
    //            print(keyvalue)
                print("bbbbb")
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //            print(snapshot.childSnapshot(forPath: "username").value)
                let bio = snapshot.childSnapshot(forPath: "bio").value
                let address = snapshot.childSnapshot(forPath: "address").value
                let lat = snapshot.childSnapshot(forPath: "coordinates").childSnapshot(forPath: "lat").value
                let long = snapshot.childSnapshot(forPath: "coordinates").childSnapshot(forPath: "long").value
                let desc = snapshot.childSnapshot(forPath: "description").value
                let endtime = formatter.date(from: snapshot.childSnapshot(forPath: "endTime").value as! String)
                let starttime = formatter.date(from: snapshot.childSnapshot(forPath: "startTime").value as! String)
                let max = snapshot.childSnapshot(forPath: "max").value
                let title = snapshot.childSnapshot(forPath: "title").value
                let type = snapshot.childSnapshot(forPath: "type").value
                var hosts: [User] = []
                var fml = SearchManager.shared.loadedEvents
    //            print("cccc")
    //            print(snapshot.childSnapshot(forPath: "hosts"))
    //            print("BbbbbBBbbB")
    //            print(snapshot)
                for rest in snapshot.childSnapshot(forPath: "hosts").children.allObjects as! [DataSnapshot] {
                    let keyval = rest.key
                    let dataval = rest.value as! String
                    let names = dataval.split(separator: " ")
                    let temp = User(userId: keyval, firstName: String(names[0]), lastName: String(names[1]))
                    hosts.append(temp)
                    }
                let temp = zip_official.createEvent(eventId: keyvalue, title: title as! String, coordinates: CLLocation(latitude: lat as! Double, longitude: long as! Double), hosts: hosts, description: desc as! String, address: address as! String, maxGuests: max as! Int, startTime: starttime!, endTime: endtime!, type: EventType(rawValue: type as! Int)!)
                print(temp.title)
                if(temp.title.lowercased().contains(name.lowercased())){
                    print("adding " + temp.title)
                    SearchManager.shared.loadedEvents.append(temp)
                } else {
                    for i in temp.hosts {
                        if(i.username.lowercased().contains(name.lowercased()) || i.fullName.lowercased().contains(name.lowercased())){
                            print("adding " + temp.title)
                            SearchManager.shared.loadedEvents.append(temp)
                        } else if (i.username.lowercased() == name.lowercased() || i.fullName.lowercased() == name.lowercased()){
                            print("adding " + temp.title)
                            SearchManager.shared.loadedEvents.append(temp)
                        }
                    }
                }
            }
            completion(nil)
        }) { (error) in
            print(error.localizedDescription)
            completion(error)
        }
    }
}
