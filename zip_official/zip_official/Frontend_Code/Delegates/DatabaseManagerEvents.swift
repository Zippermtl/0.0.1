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
    case Open = 1
    case Closed = 2
    case Promoter = 3
}

extension DatabaseManager {
    
    public func getAllPublic(eventCompletion: @escaping (Event) -> Void,
                             allCompletion: @escaping (Result<[Event], Error>) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        firestore.collection("EventProfiles").whereField("type", arrayContains: EventType.Open.rawValue).getDocuments() { [weak self] (querySnapshot, err) in
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
                    let currentEvent = try document.data(as: OpenEventCoder.self).createEvent()
                    currentEvent.eventId = document.documentID
                    events.append(currentEvent)
                    print("CURRENT EVENT \n\(currentEvent)")
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
    
    public func getAllStoredEventsForUser(userId: String, completion: @escaping () -> Void){
        firestore.collection("UserStoredEvents").document(userId).getDocument() { (document, err) in
            guard err == nil,
                  let document = document,
                  document.exists,
                  let data = document.data() as? [String: [String]],
                  let s = data["saved"]
            else {
                completion()
                return
            }
            
            AppDelegate.userDefaults.set(s, forKey: "savedEvents")
            completion()
        }
    }
    
    public func getAllGoingEvents(eventCompletion: @escaping (Event) -> Void,
                                  allCompletion: @escaping (Result<[Event], Error>) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        firestore.collection("EventProfiles").whereField("usersGoing", arrayContains: userId).getDocuments() { [weak self] (querySnapshot, err) in
            print("getting hosts")
            guard err == nil else {
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
                   let coderType = EventType(rawValue: type) {
                    do {
                        let currentEvent = try coderType.getData(document: document)
                        currentEvent.eventId = document.documentID
                        
                        events.append(currentEvent)
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
            
            let goingEvents: [String] = events.map({ $0.eventId })
            AppDelegate.userDefaults.set(goingEvents, forKey: "goingEvents")
            allCompletion(.success(events))
        }
    }
    
    public func getAllHostedEventsForMap(eventCompletion: @escaping (Event) -> Void,
                                         allCompletion: @escaping (Result<[Event], Error>) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        firestore.collection("EventProfiles").whereField("hosts", arrayContains: userId).getDocuments() { [weak self] (querySnapshot, err) in
            print("getting hosts")
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
                   let coderType = EventType(rawValue: type) {
                    do {
                        let currentEvent = try coderType.getData(document: document)
                        currentEvent.eventId = document.documentID
                        
                        events.append(currentEvent)
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
            
            let hostedEvents: [String] = events.map({ $0.eventId })
            AppDelegate.userDefaults.set(hostedEvents, forKey: "hostedEvents")
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
                let data = document.data()
                if let eventType = data["type"] as? Int,
                   let coderType = EventType(rawValue: eventType) {
                    do {
                        
                        let currentEvent = try coderType.getData(document: document)
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
            }
            
            let invitedEvents: [String] = events.map({ $0.eventId })
            AppDelegate.userDefaults.set(invitedEvents, forKey: "myInvitedEvents")
            allCompletion(.success(events))
        }
    }
    
    public func loadEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void){
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
        firestore.collection("EventProfiles").document(event.eventId).updateData(["usersGoing" : FieldValue.arrayUnion([selfId]),
                                                                                  "usersNotGoing" : FieldValue.arrayRemove([selfId])]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            
            completion(nil)
        }
    }
    
    public func markNotGoing(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        firestore.collection("EventProfiles").document(event.eventId).updateData(["usersGoing" : FieldValue.arrayRemove([selfId]),"usersNotGoing" : FieldValue.arrayUnion([selfId])]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            
            completion(nil)
        }
    }
    
    public func markSaved(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        var events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []
        events.append(event.eventId)
        AppDelegate.userDefaults.set(events, forKey: "savedEvents")
        
        firestore.collection("UserStoredEvents").document(selfId).setData(["saved":events]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            completion(nil)
        }
    }
    
    public func markUnsaved(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        var events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []
        events.removeAll(where: { $0 == event.eventId })
        AppDelegate.userDefaults.set(events, forKey: "savedEvents")
        firestore.collection("UserStoredEvents").document(selfId).setData(["saved":events]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            completion(nil)
        }
    }
    
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
        let baseEvent = Event(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
        switch t{
        case .Event: return baseEvent
        case .Closed: return ClosedEvent(event: baseEvent)
        case .Promoter: return PromoterEvent(event: baseEvent, price: nil, buyTicketsLink: nil)
        case .Open: return OpenEvent(event: baseEvent)
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
    
    public func deleteEvent(eventId: String, completion: @escaping (Error?) -> Void){
        firestore.collection("EventProfiles").document(eventId).delete() { err in
            if let err = err {
                completion(err)
            } else {
                print("Successfully deleted Event")
                completion(nil)
            }
        }
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

