//
//  DataBaseManagerEvents.swift
//  zip_official
//
//  Created by Gabe on 5/25/22.
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

extension Timestamp: TimestampType {}

public enum EventType: Int {
    case Event = 0
    case Public = 1
    case Promoter = 2
    case Private = 3
    case Friends = 4
}

extension DatabaseManager {
    
    public func getAllPublic(eventCompletion: @escaping (Event) -> Void,
                                         allCompletion: @escaping (Result<[Event], Error>) -> Void){
       guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
           return
       }
       
        firestore.collection("EventProfiles").whereField("type", arrayContains: EventType.Public.rawValue).getDocuments() { [weak self] (querySnapshot, err) in
           guard let strongSelf = self,
                 err == nil else {
               print("Error getting documents: \(err!)")
               allCompletion(.failure(err!))
               return
           }
           
            var events: [Event] = []
            for document in querySnapshot!.documents {
                print("there are docs")
                do {
                    let currentEvent = try document.data(as: PublicEventCoder.self).createEvent()
                    currentEvent.eventId = document.documentID
                    events.append(currentEvent)
                    print("CURRENT EVENT \n\(currentEvent)")
                    eventCompletion(currentEvent)
                    DatabaseManager.shared.getImages(Id: currentEvent.eventId, indices: currentEvent.eventCoverIndex, event: true, completion: { res in
                        switch res {
                        case .success(let urls):
                            print("2")
                            if urls.count != 0 {
                                currentEvent.imageUrl = urls[0]
                            }
                        case .failure(let error):
                            print("3")
                            print("error loading image in map load Error: \(error)")
                        }
                    })
                }
                catch {
                    // event wasn't same as promoter event type shouldn't be happening
                    print("unexpected error \(error)")
                    continue
                }
            }
            
           allCompletion(.success(events))
       }
   }
    
    public func getAllPromoter(eventCompletion: @escaping (Event) -> Void,
                                         allCompletion: @escaping (Result<[Event], Error>) -> Void){
       guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
           return
       }
        
        print("not running ")
        firestore.collection("EventProfiles").whereField("type", isEqualTo: EventType.Promoter.rawValue).getDocuments() { (querySnapshot, err) in
           guard err == nil else {
               print("Error getting documents: \(err!)")
               allCompletion(.failure(err!))
               return
           }
           print("1")
           var events: [Event] = []
           for document in querySnapshot!.documents {
               print("there are docs")
               do {
                   let currentEvent = try document.data(as: PromoterEventCoder.self).createEvent()
                   currentEvent.eventId = document.documentID

                   events.append(currentEvent)
                   print("CURRENT EVENT \n\(currentEvent)")
                   eventCompletion(currentEvent)
                   DatabaseManager.shared.getImages(Id: currentEvent.eventId, indices: currentEvent.eventCoverIndex, event: true, completion: { res in
                       switch res {
                       case .success(let urls):
                           print("2")
                           if urls.count != 0 {
                               currentEvent.imageUrl = urls[0]
                           }
                       case .failure(let error):
                           print("3")
                           print("error loading image in map load Error: \(error)")
                       }
                   })
               }
               catch {
                   // event wasn't same as promoter event type shouldn't be happening
                   print("unexpected error \(error)")
                   continue
               }
           }
            
            allCompletion(.success(events))
       }
   }
    
    public func getAllHostedEventsForMap(eventCompletion: @escaping (Event) -> Void,
                                         allCompletion: @escaping (Result<[Event], Error>) -> Void){
       guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
           return
       }
       
       firestore.collection("EventProfiles").whereField("hosts", arrayContains: userId).getDocuments() { [weak self] (querySnapshot, err) in
           guard let strongSelf = self,
                 err == nil else {
               print("Error getting documents: \(err!)")
               allCompletion(.failure(err!))
               return
           }
           
           var events: [Event] = []
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           
           for document in querySnapshot!.documents {
               let data = document.data()
               if let type = data["type"] as? Int,
                  let coderType = EventType(rawValue: type)?.coderType {
                   do {
                       let currentEvent = try document.data(as: coderType.self).createEvent()
                       currentEvent.eventId = document.documentID

                       events.append(currentEvent)
                       print("CURRENT EVENT \n\(currentEvent)")
                       eventCompletion(currentEvent)
                       DatabaseManager.shared.getImages(Id: currentEvent.eventId, indices: currentEvent.eventCoverIndex, event: true, completion: { res in
                           switch res {
                           case .success(let urls):
                               print("2")
                               if urls.count != 0 {
                                   currentEvent.imageUrl = urls[0]
                               }
                           case .failure(let error):
                               print("3")
                               print("error loading image in map load Error: \(error)")
                           }
                       })
                   }
                   catch {
                       // event wasn't same as promoter event type shouldn't be happening
                       print("unexpected error \(error)")
                       continue
                   }
               }
               
               
           }
           let invitedEvents: [String] = events.map({ $0.eventId })
           AppDelegate.userDefaults.set(invitedEvents, forKey: "myHostedEvents")
           allCompletion(.success(events))
       }
   }
    
    public func getAllPrivateEventsForMap(eventCompletion: @escaping (Event) -> Void,
                                          allCompletion: @escaping (Result<[Event], Error>) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        firestore.collection("EventProfiles").whereField("usersInvite", arrayContains: userId).getDocuments() { [weak self] (querySnapshot, err) in
            guard let strongSelf = self,
                  err == nil else {
                print("Error getting documents: \(err!)")
                allCompletion(.failure(err!))
                return
            }
                
            var events: [Event] = []
            for document in querySnapshot!.documents {
                do {
                    let currentEvent = try document.data(as: PrivateEventCoder.self).createEvent()
                    currentEvent.eventId = document.documentID

                    events.append(currentEvent)
                    eventCompletion(currentEvent)
                    DatabaseManager.shared.getImages(Id: currentEvent.eventId, indices: currentEvent.eventCoverIndex, event: true, completion: { res in
                        switch res {
                        case .success(let urls):
                            if urls.count != 0 {
                                currentEvent.imageUrl = urls[0]
                            }
                        case .failure(let error):
                            print("error loading image in map load Error: \(error)")
                        }
                    })
                }
                catch {
                    // event wasn't same as promoter event type shouldn't be happening
                    continue
                }
            }
                
            let invitedEvents: [String] = events.map({ $0.eventId })
            AppDelegate.userDefaults.set(invitedEvents, forKey: "myInvitedEvents")
            allCompletion(.success(events))
        }
    }
    
    public func loadEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void){
        print("HERE123456")
        print("eventId = ", event.eventId)
        print("event type = ", event.getType())
        print("expected type = \(PromoterEventCoder.self)")

        print("encoder = \(event.getEncoderType())")
        print("encoder.self = \(event.getEncoderType().self)")
        firestore.collection("EventProfiles").document(event.eventId).getDocument(as: event.getEncoderType().self)  { result in
            switch result {
            case .success(let eventCoder):
                print("Success loading")
                eventCoder.updateEvent(event: event)
                completion(.success(event))
                DatabaseManager.shared.getImages(Id: event.eventId, indices: event.eventCoverIndex, event: true, completion: { res in
                    switch res{
                    case .success(let url):
                        print("making event")
                        if url.count != 0 {
                            event.imageUrl = url[0]
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        print("Failed to make event because image failed to load Error: \(error)")
                    }
                })
                
            case .failure(let error):
                print("failed to load event Error: \(error)")
            }
        }
    }
    
    
    
    public func createEvent(event: Event, completion: @escaping (Result<String,Error>) -> Void) {
        do {
            try firestore.collection("EventProfiles").document("\(event.eventId)").setData(from: event.getEncoder())  { [weak self] error in
                guard error == nil else {
                    print("failure to write event with id: \(event.eventId) to FireStore")
                    completion(.failure(error!))
                    return
                }
                var hostedEvents = AppDelegate.userDefaults.value(forKey: "hostedEvents") as? [String] ?? []
                hostedEvents.append(event.eventId)
                AppDelegate.userDefaults.set(hostedEvents, forKey: "hostedEvents")
                
                GeoManager.shared.UpdateEventLocation(event: event)
                self?.updateEventImage(event: event, completion: { result in
                    switch result {
                    case .success(let url):
                        completion(.success(url))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
                
            }
        } catch let error {
            print("Error writing event to Firestore: \(error)")
        }
        
    }

    public func updateEvent(event: Event, completion: @escaping (Error?) -> Void) {
        firestore.collection("EventProfiles").document(event.eventId).updateData(for: event.getEncoder()) { error in
            guard error == nil else{
                print("failed to write to database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    public func updateEventImage(event: Event, completion: @escaping (Result<String,Error>) -> Void) {
        guard let image = event.image else {
            print("failed to get image from event.image")
            return
        }
        let pic = PictureHolder(image: image)
        DatabaseManager.shared.updateEventImage(event: event, images: [pic], imageType: DatabaseManager.ImageType.eventCoverIndex, completion: { res in
            switch res {
            case .success(let url):
                completion(.success(url[0].url!.absoluteString))
            case .failure(let error):
                completion(.failure(error))
            }
        })
//        StorageManager.shared.updateIndividualImage(with: event.image!, path: "Event/" + event.eventId + "/", index: 0, completion: { result in
//            switch result {
//            case .success(let url):
//                completion(.success(url))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        })
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
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        firestore.collection("EventProfiles").document(event.eventId).updateData(["usersGoing" : FieldValue.arrayUnion([selfId])]) { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                completion(error!)
                return
            }
            
            strongSelf.firestore.collection("UserStoredEvents").document(selfId).setData([event.eventId:EventSaveStatus.GOING.rawValue]) { error in
                guard error == nil else {
                    completion(error!)
                    return
                }
                var events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []

                events.removeAll(where: { event.eventId == $0 })
                AppDelegate.userDefaults.set(events, forKey: "savedEvents")
                var tmpGoing = AppDelegate.userDefaults.value(forKey: "goingEvents") as? [String] ?? []
                tmpGoing.append(event.eventId)
                AppDelegate.userDefaults.set(tmpGoing, forKey: "goingEvents")
                completion(nil)
            }
        }
    }
    
    public func markNotGoing(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        firestore.collection("EventProfiles").document(event.eventId).updateData(["usersGoing" : FieldValue.arrayRemove([selfId])]) { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                completion(error!)
                return
            }
            
            strongSelf.firestore.collection("UserStoredEvents").document(selfId).updateData([event.eventId:FieldValue.delete()] ) { error in
                guard error == nil else {
                    completion(error!)
                    return
                }
                var events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []
//                events.removeValue(forKey: event.eventId)
                events.removeAll(where: { event.eventId == $0 })
                AppDelegate.userDefaults.set(events, forKey: "savedEvents")
                completion(nil)
            }
        }
    }
    
    public func markSaved(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        firestore.collection("UserStoredEvents").document(selfId).updateData([event.eventId:EventSaveStatus.SAVED.rawValue] ) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            var events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []
//            events[event.eventId] = EventSaveStatus.SAVED.rawValue
            events.append(event.eventId)
            AppDelegate.userDefaults.set(events, forKey: "savedEvents")
            completion(nil)
        }
    }
    
    public func markUnsaved(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        firestore.collection("UserStoredEvents").document(selfId).updateData([event.eventId:FieldValue.delete()] ) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            var events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []
            events.removeAll(where: { event.eventId == $0 })
            AppDelegate.userDefaults.set(events, forKey: "savedEvents")
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
    
    
   
    
    //    public func FindEvents(path: String, type: Int, completion: @escaping (Result<Any, Error>) -> Void){
    //            database.child("EventFull/\(path)")
    //
    //    }
    
    public func createEventLocal(eventId Id: String = "",
                                 title tit: String = "",
                                 coordinates loc: CLLocation = CLLocation(),
                                 hosts host: [User] = [],
                                 bio b: String = "",
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
                                 type t: EventType = .Event,
                                 eventCoverIndex ecI: [Int] = [],
                                 eventPicIndices epI: [Int] = []) -> Event{
        switch t{
        case .Event:
            return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
        case .Public:
            return PublicEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
        case .Promoter:
            return PromoterEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
        case .Private:
            return PrivateEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
        case .Friends:
            return FriendsEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
//        default:
//            return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
        }
        
    }
    
    public func eventLoadTableView(event: Event, completion: @escaping (Result<Event, Error>) -> Void){
        loadEvent(event: event, completion: { result in
            switch result {
            case .success(let event):
                completion(.success(event))
            case .failure(let error):
                print("error loading event in tableview: \(error)")
                completion(.failure(error))
            }
        })
        
    }
    
}





//    public func loadEvent(key: String, completion: @escaping (Result<Event, Error>) -> Void){
//        let path = "eventProfiles/" + key
//        database.child(path).observeSingleEvent(of: .value, with: { snapshot in
//            guard let value = snapshot.value as? [String: Any] else {
//                print("failed to fetch user profile")
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//            print("big succccc sample")
//            guard let startTimeString = value["startTime"] as? String,
//                  let coordinates = value["coordinates"] as? [String : Double],
//                  let addy = value["address"] as? String,
//                  let desc = value["description"] as? String,
////                  let dur = value["duration"] as? Int,
//                  let endTimeString = value["endTime"] as? String,
//                  let userHost = value["hosts"] as? [String : String],
//                  let title = value["title"] as? String,
//                  let type = value["type"] as? Int,
////                  let usersGoing = value["usersGoing"] as? [String : String],
////                  let usersInterested = value["usersInterested"] as? [String : String],
//                  let max = value["max"] as? Int,
//                  let userInvite = value["usersInvite"] as? [String : String] else {
//                      print("Data Failed")
//                      return
//                  }
//            print("data good")
//            var usersInvited: [User] = []
//            for (key, value) in userInvite {
//                let componentsName = value.description.components(separatedBy: " ")
//                usersInvited.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
//            }
//            var host: [User] = []
//            for (key, value) in userHost {
//                let componentsName = value.description.components(separatedBy: " ")
//                host.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
//            }
//            var going: [User] = []
////            for (key, value) in usersGoing {
////                let componentsName = value.description.components(separatedBy: " ")
////                going.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
////            }
////            var interested: [User] = []
////            for (key, value) in usersInterested {
////                let componentsName = value.description.components(separatedBy: " ")
////                interested.append(User(userId: key, firstName: componentsName[0], lastName: componentsName[1]))
////            }
//            let imagePath = "Event/" + key
//            print("got to image path")
//            print(imagePath)
//
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//            let startTime = formatter.date(from: startTimeString)!
//            let endTime = formatter.date(from: endTimeString)!
//
//            print("IN LOAD String: \(startTimeString)")
//            print("IN LOAD time: \(startTime)")
//
//
//            StorageManager.shared.getProfilePicture(path: imagePath) { result in
//                switch result{
//                case .success(let url):
//                    print("making event")
//                    completion(.success(DatabaseManager.shared.createEventLocal(eventId: key,
//                                                                                title: title,
//                                                                                coordinates: CLLocation(latitude: coordinates["lat"]!, longitude: coordinates["long"]!),
//                                                                                hosts: host,
//                                                                                description: desc,
//                                                                                address: addy,
//                                                                                maxGuests: max,
//                                                                                usersGoing: going,
//                                                                                usersInvite: usersInvited,
//                                                                                startTime: endTime,
//                                                                                endTime: startTime,
//                                                                                imageURL: url[0],
//                                                                                type: EventType(rawValue: type)!)))
//                case .failure(let error):
//                    print("failed to make event")
//                    completion(.failure(error))
//                }
//            }
//        })
//
//    }


//    public func createEvent(event: Event, completion: @escaping (Result<String,Error>) -> Void) {
//        let path = "eventProfiles/\(event.eventId)"
////        let dispatch = DispatchGroup()
//        let ref = Database.database().reference()
//        var datadic: [String:Any] = [
//            "eventProfiles/\(event.eventId)/title" : event.title,
//            "eventProfiles/\(event.eventId)/coordinates/lat" : event.coordinates.coordinate.latitude,
//            "eventProfiles/\(event.eventId)/coordinates/long" : event.coordinates.coordinate.longitude,
//            "eventProfiles/\(event.eventId)/description" : event.bio,
//            "eventProfiles/\(event.eventId)/address" : event.address,
//            "eventProfiles/\(event.eventId)/type" : event.getType().rawValue,
//            "eventProfiles/\(event.eventId)/startTime" : event.startTimeString,
////            "eventProfiles/\(event.eventId)/duration" : event.duration,
//            "eventProfiles/\(event.eventId)/endTime" : event.endTimeString,
//            "eventProfiles/\(event.eventId)/max" : event.maxGuests
//        ]
//        for i in event.hosts{
//            datadic["eventProfiles/\(event.eventId)/hosts/\(i.userId)"] = i.fullName
//        }
//        for j in event.usersInvite{
//            datadic["eventProfiles/\(event.eventId)/usersInvite/\(j.userId)"] = j.fullName
//        }
//        GeoManager.shared.UpdateEventLocation(event: event)
//        ref.updateChildValues(datadic) { (error, _) in
//            if let error = error {
//                completion(.failure(error))
//            }
//            StorageManager.shared.updateIndividualImage(with: event.image!, path: "Event/" + event.eventId + "/", index: 0, completion: { result in
//                switch result {
//                case .success(let url):
//                    completion(.success(url))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            })
//        }
//
//    }

