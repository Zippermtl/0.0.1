//
//  DataBaseManagerEvents.swift
//  zip_official
//
//  Created by Gabe on 5/25/22.
//
import Foundation
import FirebaseDatabase
import MessageKit
import FirebaseAuth
import CoreLocation
import GeoFire

extension DatabaseManager {
    
//    public func updateEvent(path: String, updateDetails: Event, completion: @escaping (Result<Any, Error>) -> Void) {
//        // write later
//        //MARK: Yianni job for front end integration
//        completion(.success(value))
//    }
    
    //MARK: INCOMPLETE WILL COME BACK TOO
//    public func PullEvent(path: String, type: Int, completion: @escaping (Result<Any, Error>) -> Void) {
//        database.child("EventFull/\(path)").observeSingleEvent(of: .value, with: { snapshot in
//            guard let value = snapshot.value as? [String: Any] else {
//                print("failed to fetch user profile")
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//            guard let fullname = value["name"] as? String else {
//                      print("retuning SubView")
//                      return
//            }
//            completion(.success(value))
//        }
//    }
    public func createEvent(event: Event, completion: @escaping (Bool) -> Void) {
        let path = "eventProfiles/\(event.eventId)"
//        let dispatch = DispatchGroup()
        let ref = Database.database().reference()
        var datadic: [String:Any] = [
            "eventProfiles/\(event.eventId)/title" : event.title,
            "eventProfiles/\(event.eventId)/coordinates/lat" : event.coordinates.coordinate.latitude,
            "eventProfiles/\(event.eventId)/coordinates/long" : event.coordinates.coordinate.longitude,
            "eventProfiles/\(event.eventId)/description" : event.description,
            "eventProfiles/\(event.eventId)/address" : event.address,
            "eventProfiles/\(event.eventId)/type" : event.getType(),
            "eventProfiles/\(event.eventId)/startTime" : event.startTimeString,
            "eventProfiles/\(event.eventId)/duration" : event.duration,
            "eventQuick/\(event.eventId)/startTime" : event.startTime,
        ]
        for i in event.hosts{
            datadic["eventProfiles/\(event.eventId)/hosts/\(i.userId)"] = i.fullName
        }
        for j in event.usersInvite{
            datadic["eventProfiles/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
        }
        datadic["eventQuick/\(event.eventId)/startTime"] = event.startTimeString
        for j in event.usersInvite{
            datadic["eventQuick/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
        }
        GeoManager.shared.UpdateEventLocation(event: event)
        ref.updateChildValues(datadic) { (error, _) in
            if let error = error {
                completion(false)
            }
            completion(true)
        }
        
    }
    
    public func inviteUsers(event: Event, users: [User], completion: @escaping (Error?) -> Void){
        var datadic: [String:Any] = [:]
        let ref = Database.database().reference()
        for j in users{
            if(!event.usersInvite.contains(where: { (id) in
                return (j.userId == id.userId)
            })){
                datadic["eventProfiles/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
                datadic["eventQuick/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
            }
        }
        ref.updateChildValues(datadic) { (error, _) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
    public func markGoing(event: Event, completion: @escaping (Error?) -> Void){
        var datadic: [String:Any] = [:]
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let selfName = AppDelegate.userDefaults.value(forKey: "name") as! String
        let ref = Database.database().reference()
        //TODO: Yianni should I remove from interested if going?
        datadic["eventProfiles/\(event.eventId)/usersGoing/\(selfId)"] = selfName
        ref.updateChildValues(datadic) { (error, _) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
    public func markInterested(event: Event, completion: @escaping (Error?) -> Void){
        var datadic: [String:Any] = [:]
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let selfName = AppDelegate.userDefaults.value(forKey: "name") as! String
        let ref = Database.database().reference()
        datadic["eventProfiles/\(event.eventId)/usersInterested/\(selfId)"] = selfName
        ref.updateChildValues(datadic) { (error, _) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
    public func makeSampleEvent(){
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        let a = PublicEvent(eventId: "sample", title: "sample", coordinates: userLoc, hosts: [User(userId: "test", firstName: "Gabe", lastName: "Denton")], description: "fuck", address: "shit", locationName: "yianni's butthole", maxGuests: 1, usersGoing: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")], usersInterested: [], usersInvite: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")], startTime: Date(), duration: TimeInterval(3))
        createEvent(event: a) { fuck in
            print("fuck" + fuck.description)
        }
        markGoing(event: a) { error in
            guard error != nil else {
                return
            }
        }
        markInterested(event: a) { error in
            guard error != nil else {
                return
            }
        }
        inviteUsers(event: a, users: [User(userId: "FUCK", firstName: "SHIT", lastName: "BITCH"), User(userId: "Cunt", firstName: "ASS", lastName: "HELL")]) { error in
            guard error != nil else {
                return
            }
        }
    }
                                                               
//    public func FindEvents(path: String, type: Int, completion: @escaping (Result<Any, Error>) -> Void){
//            database.child("EventFull/\(path)")
//
//    }
}
