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
import CoreData

public enum EventType: Int {
    case Event = 0
    case Public = 1
    case Promoter = 2
    case Private = 3
    case Friends = 4
}

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
    
    public func loadEvent(key: String, completion: @escaping (Result<Event, Error>) -> Void){
        let path = "eventProfiles/" + key
        database.child(path).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("failed to fetch user profile")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("big succccc sample")
            guard let startTime = value["startTime"] as? String,
                  let coordinates = value["coordinates"] as? [String : Double],
                  let addy = value["address"] as? String,
                  let desc = value["description"] as? String,
//                  let dur = value["duration"] as? Int,
                  let endTime = value["endTime"] as? String,
                  let userHost = value["hosts"] as? [String : String],
                  let title = value["title"] as? String,
                  let type = value["type"] as? Int,
                  let usersGoing = value["usersGoing"] as? [String : String],
//                  let usersInterested = value["usersInterested"] as? [String : String],
                  let max = value["max"] as? Int,
                  let userInvite = value["usersInvite"] as? [String : String] else {
                      print("Data Failed")
                      return
                  }
            print("data good")
            var usersInvited: [User] = []
            for (key, value) in userInvite {
                let componentsName = value.description.components(separatedBy: " ")
                usersInvited.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
            }
            var host: [User] = []
            for (key, value) in userHost {
                let componentsName = value.description.components(separatedBy: " ")
                host.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
            }
            var going: [User] = []
            for (key, value) in usersGoing {
                let componentsName = value.description.components(separatedBy: " ")
                going.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
            }
//            var interested: [User] = []
//            for (key, value) in usersInterested {
//                let componentsName = value.description.components(separatedBy: " ")
//                interested.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
//            }
            let imagePath = "Event/" + key
            print("got to image path")
            print(imagePath)
            StorageManager.shared.getProfilePicture(path: imagePath) { result in
                switch result{
                case .success(let url):
                    print("making event")
                    completion(.success(DatabaseManager.shared.createEventLocal(eventId: key,
                                                                                title: title,
                                                                                coordinates: CLLocation(latitude: coordinates["lat"]!, longitude: coordinates["long"]!),
                                                                                hosts: host,
                                                                                description: desc,
                                                                                address: addy,
                                                                                maxGuests: max,
                                                                                usersGoing: going,
                                                                                usersInvite: usersInvited,
                                                                                imageURL: url[0],
                                                                                endTimeString: endTime,
                                                                                startTimeString: startTime,
                                                                                type: EventType(rawValue: type)!)))
                case .failure(let error):
                    print("failed to make event")
                    completion(.failure(error))
                }
            }
        })
            
    }
    
    public func createEvent(event: Event, completion: @escaping (Result<String,Error>) -> Void) {
        let path = "eventProfiles/\(event.eventId)"
//        let dispatch = DispatchGroup()
        let ref = Database.database().reference()
        var datadic: [String:Any] = [
            "eventProfiles/\(event.eventId)/title" : event.title,
            "eventProfiles/\(event.eventId)/coordinates/lat" : event.coordinates.coordinate.latitude,
            "eventProfiles/\(event.eventId)/coordinates/long" : event.coordinates.coordinate.longitude,
            "eventProfiles/\(event.eventId)/description" : event.description,
            "eventProfiles/\(event.eventId)/address" : event.address,
            "eventProfiles/\(event.eventId)/type" : event.getType().rawValue,
            "eventProfiles/\(event.eventId)/startTime" : event.startTimeString,
//            "eventProfiles/\(event.eventId)/duration" : event.duration,
            "eventProfiles/\(event.eventId)/endTime" : event.endTimeString,
            "eventProfiles/\(event.eventId)/max" : event.maxGuests
        ]
        for i in event.hosts{
            datadic["eventProfiles/\(event.eventId)/hosts/\(i.userId)"] = i.fullName
        }
        for j in event.usersInvite{
            datadic["eventProfiles/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
        }
        GeoManager.shared.UpdateEventLocation(event: event)
        ref.updateChildValues(datadic) { (error, _) in
            if let error = error {
                completion(.failure(error))
            }
            StorageManager.shared.updateIndividualImage(with: event.image!, path: "Event/" + event.eventId + "/", index: 0, completion: { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
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
//                datadic["eventQuick/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
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
    
//    public func markInterested(event: Event, completion: @escaping (Error?) -> Void){
//        var datadic: [String:Any] = [:]
//        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
//        let selfName = AppDelegate.userDefaults.value(forKey: "name") as! String
//        let ref = Database.database().reference()
//        datadic["eventProfiles/\(event.eventId)/usersInterested/\(selfId)"] = selfName
//        ref.updateChildValues(datadic) { (error, _) in
//            if let error = error {
//                completion(error)
//            }
//            completion(nil)
//        }
//    }
    public func checkSampleEvent(){
        print("check Sample")
        let key = "sample"
        loadEvent(key: key) { result in
            switch result{
            case .success(let event):
                print("check sample event suc")
                event.out()
            case .failure(let error):
                print("check sample got fucked in the ass")
                print(error)
            }
        }
    }
    
    public func makeSampleEvent(){
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        let a = PublicEvent(eventId: "sample",
                            title: "sample",
                            coordinates: userLoc,
                            hosts: [User(userId: "test", firstName: "Gabe", lastName: "Denton")],
                            description: "fuck",
                            address: "shit",
                            locationName: "yianni's butthole",
                            maxGuests: 1,
                            usersGoing: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")],
                            usersInterested: [],
                            usersInvite: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")],
                            startTime: Date(),
                            endTime: Date(),
                            duration: TimeInterval(3))
        createEvent(event: a) { [weak self] fuck in
            guard let strongSelf = self else {
                return
            }
            switch fuck{
            case .success(let f):
                print("finished creating event sample")
                print("sample url: " + f)
                strongSelf.markGoing(event: a) { [weak self] failuresfuckingsuckass in
                    guard failuresfuckingsuckass == nil else {
                        print("return 1")
                        return
                    }
                    guard let strongSelf = self else {
                        print("return 2")
                        return
                    }
                    print("Yianni marked as going")
                    strongSelf.inviteUsers(event: a, users: [User(userId: "FUCK", firstName: "SHIT", lastName: "BITCH"), User(userId: "Cunt", firstName: "ASS", lastName: "HELL")]) { error in
                        guard error == nil else {
                            print("return 3")
                            return
                        }
                        print("finished inviting FUCK and CUNT")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
//        markInterested(event: a) { error in
//            guard error != nil else {
//                return
//            }
//        }
        
    }
                                                               
//    public func FindEvents(path: String, type: Int, completion: @escaping (Result<Any, Error>) -> Void){
//            database.child("EventFull/\(path)")
//
//    }
    
    public func createEventLocal(eventId Id: String = "",
                            title tit: String = "",
                            coordinates loc: CLLocation = CLLocation(),
                            hosts host: [User] = [],
                            description desc: String = "",
                            address addy: String = "",
                            locationName locName: String = "",
                            maxGuests maxG: Int = 0,
                            usersGoing ugoing: [User] = [],
                            usersInterested uinterested: [User] = [],
                            usersInvite uinvite: [User] = [],
                            startTime stime: Date = Date(),
                            endTime etime: Date = Date(),
                            duration dur: TimeInterval = TimeInterval(1),
                            image im: UIImage? = UIImage(named: "launchevent"),
                            imageURL url: URL = URL(string: "a")!,
                            endTimeString ets: String = "",
                            startTimeString sts: String = "",
                            type t: EventType = .Event) -> Event{
        switch t{
        case .Event:
            return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        case .Public:
            return PublicEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        case .Promoter:
            return PromoterEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        case .Private:
            return PrivateEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        case .Friends:
            return FriendsEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        default:
            return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        }
        
    }

}
