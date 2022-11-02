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
    case Recurring = 4
}

extension DatabaseManager {
    /// Gets all private events for current user
    /// `completion` - Error? if one of the quier
    public func getAllUserDefaultsEvents(completion : @escaping (Error?) -> Void) {
        guard let selfId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        var h = [Event]()
        var g = [Event]()
        var n = [Event]()
        var i = [Event]()
        var ph = [Event]()
        var pg = [Event]()
        getAllPrivateEventsForMap(getImage: false, eventCompletion: { event in
            if event.ownerId == selfId { h.append(event) }
            else if event.usersGoing.contains(User(userId: selfId)) { g.append(event) }
            else if event.usersNotGoing.contains(User(userId: selfId)) { n.append(event) }
            else { i.append(event) }
        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
                return
            }
            strongSelf.getPastGoingEvents(userId: userId, eventCompletion: { event in
                print("event title = \(event.title)")
                if event.ownerId == selfId { ph.append(event) }
                else { pg.append(event)}
                
            }, allCompletion: { result in
                strongSelf.getAllStoredEventsForUser(userId: selfId, completion: {
                    User.setUDEvents(events: h, toKey: .hostedEvents)
                    User.setUDEvents(events: g, toKey: .goingEvents)
                    User.setUDEvents(events: n, toKey: .notGoingEvents)
                    User.setUDEvents(events: i, toKey: .invitedEvents)
                    User.setUDEvents(events: ph, toKey: .pastHostEvents)
                    User.setUDEvents(events: pg, toKey: .pastGoingEvents)
                })
            })
        })
    }
    
    /// Gets all Open events for current user
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getAllPublic(eventCompletion: @escaping (Event) -> Void,
                             allCompletion: @escaping (Result<[Event], Error>) -> Void){
        queryFieldValue(collection: "EventProfiles", field: "type", isEqualTo: EventType.Open.rawValue, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    /// Gets all promoter events
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getAllPromoter(eventCompletion: @escaping (Event) -> Void,
                               allCompletion: @escaping (Result<[Event], Error>) -> Void){
        queryFieldValue(collection: "EventProfiles", field: "type", isEqualTo: EventType.Promoter.rawValue, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    /// Gets all currently going events for current user
    /// `fast` - boolean - if false then the function returns events when fully loaded instead of before image
    /// `getImage` - boolean - if true, load image
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getAllGoingEvents(userId: String,
                                  fast: Bool = true,
                                  getImage: Bool = true,
                                  eventCompletion: @escaping (Event) -> Void,
                                  allCompletion: @escaping (Result<[Event], Error>) -> Void){
        
        queryFieldArray(collection: "EventProfiles", field: "usersGoing", arrayContains: userId,fast: fast, getImage: getImage, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    /// Gets all current hosting events for current user
    /// `fast` - boolean - if false then the function returns events when fully loaded instead of before image
    /// `getImage` - boolean - if true, load image
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getAllHostedEvents(userId: String,
                                   fast: Bool = true,
                                   getImage: Bool = true,
                                   eventCompletion: @escaping (Event) -> Void,
                                   allCompletion: @escaping (Result<[Event], Error>) -> Void){
     
        queryFieldArray(collection: "EventProfiles", field: "hosts", arrayContains: userId, fast: fast, getImage: getImage, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    /// Gets all past attended events for current user
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getPastGoingEvents(userId: String,
                                   eventCompletion: @escaping (Event) -> Void,
                                  allCompletion: @escaping (Result<[Event], Error>) -> Void){
        
        queryFieldArray(collection: "ExpiredEvents", field: "usersGoing", arrayContains: userId, fast: true, getImage: false, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    /// Gets all past hosted events for current user
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getPastHostedEvents(userId: String,
                                    eventCompletion: @escaping (Event) -> Void,
                                    allCompletion: @escaping (Result<[Event], Error>) -> Void){
        queryFieldArray(collection: "ExpiredEvents", field: "hosts", arrayContains: userId, fast: true ,getImage: false, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    /// Gets all private events for current user
    /// `fast` - boolean - if false then the function returns events when fully loaded instead of before image
    /// `getImage` - boolean - if true, load image
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func getAllPrivateEventsForMap(fast: Bool = true,
                                          getImage: Bool = true,
                                          eventCompletion: @escaping (Event) -> Void,
                                          allCompletion: @escaping (Result<[Event], Error>) -> Void){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        queryFieldArray(collection: "EventProfiles", field: "usersInvite", arrayContains: userId, fast: fast, getImage: getImage, eventCompletion: { event in
            eventCompletion(event)
        }, allCompletion: { result in
            allCompletion(result)
        })
    }
    
    public func getMutualEvents(userId: String,
                                completion: @escaping (Result<[MultiSectionData],Error>) -> Void) {
        
        guard let selfId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        var todayHost = [String: Event]()
        var upcomingHost = [String: Event]()
        var pastHost = [String: Event]()
        var todayGoing = [String: Event]()
        var upcomingGoing = [String: Event]()
        var pastGoing = [String: Event]()
        getAllHostedEvents(userId: userId, eventCompletion: { event in
            if event.canIGo() {
                if event.startTime.isInSameDay(as: Date()) {
                    todayHost[event.eventId] = event
                } else {
                    upcomingHost[event.eventId] = event
                }
            }
        }, allCompletion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.getPastHostedEvents(userId: userId, eventCompletion: { event in
                if event.canIGo() {
                    pastHost[event.eventId] = event
                }
            }, allCompletion: { [weak self] _ in
                guard let strongSelf = self else { return }
//                let htodaySection = CellSectionData(title: "Today", items: todayHost.map({ $0.value }), cellType: CellType(eventType: .save))
//                let hupcomingSection = CellSectionData(title: "Upcomming", items: upcomingHost.map({ $0.value }), cellType: CellType(eventType: .save))
//                let hpastSection = CellSectionData(title: "Previous", items: pastHost.map({ $0.value }), cellType: CellType(eventType: .save))
//
//                let hostSection = MultiSectionData(title: "Hosting", sections: [htodaySection,hupcomingSection,hpastSection])
                
                strongSelf.getAllGoingEvents(userId: userId, eventCompletion: { event in
                    if event.canIGo() {
                        if todayHost[event.eventId] == nil
                            && upcomingHost[event.eventId] == nil {
                            if event.startTime.isInSameDay(as: Date()) {
                                todayGoing[event.eventId] = event
                            } else {
                                upcomingGoing[event.eventId] = event
                            }
                        }
                    }
                }, allCompletion: { [weak self] res in
                    guard let strongSelf = self else { return }
                    strongSelf.getPastGoingEvents(userId: userId, eventCompletion: { event in
                        if event.canIGo() {
                            if pastHost[event.eventId] == nil {
                                pastGoing[event.eventId] = event
                            }
                        }
                    }, allCompletion: { result in
                        let htodaySection = CellSectionData(title: "Today", items: todayHost.map({ $0.value }), cellType: CellType(eventType: .save))
                        let hupcomingSection = CellSectionData(title: "Upcoming", items: upcomingHost.map({ $0.value }), cellType: CellType(eventType: .save))
                        let hpastSection = CellSectionData(title: "Previous", items: pastHost.map({ $0.value }), cellType: CellType(eventType: .save))
                        
                        let hostSection = MultiSectionData(title: "Hosting", sections: [htodaySection,hupcomingSection,hpastSection])
                        
                        
                        let gtodaySection = CellSectionData(title: "Today", items: todayGoing.map({ $0.value }), cellType: CellType(eventType: .save))
                        let gupcomingSection = CellSectionData(title: "Upcoming", items: upcomingGoing.map({ $0.value }), cellType: CellType(eventType: .save))
                        let gpastSection = CellSectionData(title: "Previous", items: pastGoing.map({ $0.value }), cellType: CellType(eventType: .save))
                        
                        let goingSection = MultiSectionData(title: "Going", sections: [gtodaySection,gupcomingSection,gpastSection])
                        completion(.success([hostSection,goingSection]))
                        
                    })
                })
//                completion(.success([hostSection]))
//
//                strongSelf.firestore.collection("EventProfiles").whereField("usersGoing", arrayContains: selfId).whereField("usersGoing", arrayContains: userId).getDocuments(completion: { [weak self] (querySnapshot, err) in
//                    guard let strongSelf = self else { return }
//                    strongSelf.handleEventQueryResults(querySnapshot: querySnapshot, err: err, fast: false, eventCompletion: { event in
//                        if event.canIGo() {
//                            if todayHost[event.eventId] == nil
//                                && upcomingHost[event.eventId] == nil {
//                                if event.startTime.isInSameDay(as: Date()) {
//                                    todayGoing[event.eventId] = event
//                                } else {
//                                    upcomingGoing[event.eventId] = event
//                                }
//                            }
//                        }
//                    }, allCompletion: { result in
//                        strongSelf.firestore.collection("ExpireEvents").whereField("usersGoing", arrayContains: selfId).whereField("usersGoing", arrayContains: userId).getDocuments(completion: { [weak self] (querySnapshot, err) in
//                            guard let strongSelf = self else { return }
//                            strongSelf.handleEventQueryResults(querySnapshot: querySnapshot, err: err, fast: false, eventCompletion: { event in
//                                if event.canIGo() {
//                                    if pastHost[event.eventId] == nil {
//                                        pastGoing[event.eventId] = event
//                                    }
//                                }
//                            }, allCompletion: { result in
//
//                                let htodaySection = CellSectionData(title: "Today", items: todayHost.map({ $0.value }), cellType: CellType(eventType: .save))
//                                let hupcomingSection = CellSectionData(title: "Upcomming", items: upcomingHost.map({ $0.value }), cellType: CellType(eventType: .save))
//                                let hpastSection = CellSectionData(title: "Previous", items: pastHost.map({ $0.value }), cellType: CellType(eventType: .save))
//
//                                let hostSection = MultiSectionData(title: "Hosting", sections: [htodaySection,hupcomingSection,hpastSection])
//
//
//                                let gtodaySection = CellSectionData(title: "Today", items: todayGoing.map({ $0.value }), cellType: CellType(eventType: .save))
//                                let gupcomingSection = CellSectionData(title: "Upcomming", items: upcomingGoing.map({ $0.value }), cellType: CellType(eventType: .save))
//                                let gpastSection = CellSectionData(title: "Previous", items: pastGoing.map({ $0.value }), cellType: CellType(eventType: .save))
//
//                                let goingSection = MultiSectionData(title: "Going", sections: [gtodaySection,gupcomingSection,gpastSection])
//                                completion(.success([hostSection,goingSection]))
//                            })
//                        })
//                    })
//                })
                
            })
        })
        
        
        
        
    }
    public func getAllMutualGoingEvents(userId: String,
                                        eventCompletion: @escaping (Event) -> Void,
                                        allCompletion: @escaping (Result<[Event], Error>) -> Void){
       
        
       
    }
    
    public func getAllMutualInvited(userId: String,
                                    eventCompletion: @escaping (Event) -> Void,
                                    allCompletion: @escaping (Result<[Event], Error>) -> Void){
    guard let selfId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
        return
    }
        
        firestore.collection("EventProfiles").whereField("usersInvite", arrayContains: selfId).whereField("usersInvite", arrayContains: userId).getDocuments(completion: { [weak self] (querySnapshot, err) in
            guard let strongSelf = self else { return }
            strongSelf.handleEventQueryResults(querySnapshot: querySnapshot, err: err, fast: false, eventCompletion: { event in
                eventCompletion(event)
            }, allCompletion: { result in
                allCompletion(result)
            })
        })
    }
    
    
    public func getInivtedEventsListener(addedEventHandler: @escaping (Event) -> Void,
                                       modifiedEventHandler: @escaping (Event) -> Void,
                                       removedEventHandler: @escaping (Event) -> Void) -> ListenerRegistration{
        let id = AppDelegate.userDefaults.value(forKey: "userId") as! String
        return firestore.collection("EventProfiles").whereField("usersInvite", arrayContains: id).addSnapshotListener { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            strongSelf.handleEventLiveUpdates(querySnapshot: snapshot,
                                              error: error,
                                              addedEventHandler: addedEventHandler,
                                              modifiedEventHandler: modifiedEventHandler,
                                              removedEventHandler: removedEventHandler)
        }
    }
    
    public func getPromoterEventListener(addedEventHandler: @escaping (Event) -> Void,
                                         modifiedEventHandler: @escaping (Event) -> Void,
                                         removedEventHandler: @escaping (Event) -> Void) -> ListenerRegistration{
        return firestore.collection("EventProfiles").whereField("type", isEqualTo: EventType.Promoter.rawValue).addSnapshotListener { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            strongSelf.handleEventLiveUpdates(querySnapshot: snapshot,
                                              error: error,
                                              addedEventHandler: addedEventHandler,
                                              modifiedEventHandler: modifiedEventHandler,
                                              removedEventHandler: removedEventHandler)
        }
    }
    
    public func removeEventObserver(observer: NSObject) {
        firestore.removeObserver(observer, forKeyPath: "EventProfiles")
    }
    
    
    
    ///Queries database for a field equal to a value
    /// `collection` - string colelction name
    /// `field` - string field to query on
    /// `isEqualTo` - comparison
    /// `fast` - boolean - if false then the function returns events when fully loaded instead of before image
    /// `getImage` - boolean - if true, load image
    /// `eventCompletion` - returns an event whenever one is finished
    /// `allCompletion` - fires when all events are done loading
    public func queryFieldValue(collection : String,
                                field : String,
                                isEqualTo : Any,
                                fast: Bool = true,
                                getImage: Bool = true,
                                eventCompletion: @escaping (Event) -> Void,
                                allCompletion: @escaping (Result<[Event], Error>) -> Void){
       firestore.collection(collection).whereField(field, isEqualTo: isEqualTo).getDocuments() { [weak self] (querySnapshot, err) in
           guard let strongSelf = self else { return }
           strongSelf.handleEventQueryResults(querySnapshot: querySnapshot, err: err, fast: fast, getImage: getImage, eventCompletion: { event in
               eventCompletion(event)
           }, allCompletion: { result in
               allCompletion(result)
           })
       }
   }
    
    public func queryFieldArray(collection : String,
                                field : String,
                                arrayContains : Any,
                                fast: Bool = true,
                                getImage: Bool = true,
                                eventCompletion: @escaping (Event) -> Void,
                                allCompletion: @escaping (Result<[Event], Error>) -> Void){
        firestore.collection(collection).whereField(field, arrayContains: arrayContains).getDocuments() { [weak self] (querySnapshot, err) in
            guard let strongSelf = self else { return }
            strongSelf.handleEventQueryResults(querySnapshot: querySnapshot, err: err, fast: fast, getImage: getImage, eventCompletion: { event in
                eventCompletion(event)
            }, allCompletion: { result in
                allCompletion(result)
            })
        }
    }
    
    
    private func handleEventLiveUpdates(querySnapshot: QuerySnapshot?,
                                        error: Error?,
                                        addedEventHandler: @escaping (Event) -> Void,
                                        modifiedEventHandler: @escaping (Event) -> Void,
                                        removedEventHandler: @escaping (Event) -> Void) {
        guard let snapshot = querySnapshot,
              error == nil else {
            return
        }
        
        snapshot.documentChanges.forEach({ diff in
            do {
                guard let eventType = diff.document.data()["type"] as? Int,
                      let coderType = EventType(rawValue: eventType) else {
                    return
                }
                
                let event = try coderType.getData(document: diff.document)
                event.eventId = diff.document.documentID
                event.updateImageInView{_ in}
                switch diff.type {
                case .added:
                    addedEventHandler(event)
                case .modified:
                    modifiedEventHandler(event)
                case .removed:
                    removedEventHandler(event)
                }
            }
            catch {
            
            }
        })
    }
    
    /// handels a list of events query snapshot
    /// params
    /// - `querySnapshot` : Snapshot result
    /// - `err` :  optional error returned with query snapshot
    /// - `fast` :  - boolean - if false, return with fully loaded image
    /// - `getImage` - boolean - if true, load image

    /// - `eventCompletion` : completion firing when one event is loaded . When it returns depends on fast
    /// - `eventCompletion` : completion firing when all events are loaded
    private func handleEventQueryResults(querySnapshot: QuerySnapshot?,
                                         err: Error?,
                                         fast: Bool = true,
                                         getImage: Bool = true,
                                         eventCompletion: @escaping (Event) -> Void,
                                         allCompletion: @escaping (Result<[Event], Error>) -> Void) {
    
        guard err == nil else {
            print("Error getting documents: \(err!)")
            allCompletion(.failure(err!))
            return
        }
        
        var events: [Event] = []
        var count = 0
        for document in querySnapshot!.documents {
            let data = document.data()
            if let eventType = data["type"] as? Int,
               let coderType = EventType(rawValue: eventType) {

                do {
                    let currentEvent = try coderType.getData(document: document)
                    currentEvent.eventId = document.documentID
                    currentEvent.loadStatus = .UserProfileNoPic
                    events.append(currentEvent)
                    if fast || !getImage { // complete event without image
                        eventCompletion(currentEvent)
                    }
                    if getImage {
                        DatabaseManager.shared.getImages(Id: currentEvent.eventId, indices: currentEvent.eventCoverIndex, type: DatabaseManager.ImageType.eventCoverIndex, completion: { res in
//                        DatabaseManager.shared.getImages(Id: currentEvent.eventId, indices: currentEvent.eventCoverIndex, event: true, completion: { res in
                            count += 1

                            switch res {
                            case .success(let urls):
                                currentEvent.loadStatus = .UserProfile
                                if urls.count != 0 {
                                    currentEvent.imageUrl = urls[0]
                                }
                                if !fast {
                                    eventCompletion(currentEvent)
                                    if  count == querySnapshot!.documents.count {
                                        allCompletion(.success(events))
                                    }
                                }

                            case .failure(let error):
                                if  count == querySnapshot!.documents.count {
                                    allCompletion(.success(events))
                                }
                                print("error loading image in map load Error: \(error)")
                            }
                        })
                    }
                    
                }
                catch {
                    count += 1

                    guard let eventIdx = events.firstIndex(where: { $0.eventId == document.documentID}) else {
                        continue
                    }
                    events.remove(at: eventIdx)
                    if  count == querySnapshot!.documents.count {
                        allCompletion(.success(events))
                    }
                    continue
                }
            }
        }
        
        if fast {
            allCompletion(.success(events))
        }
    }
    
    
    
    public func getAllHappeningsToday(eventCompletion: @escaping (Event) -> Void,
                                      allCompletion: @escaping (Result<[Event], Error>) -> Void) {
        let date = Calendar.current.date(byAdding: .hour, value: -5, to: Date())
        let dayOfTheWeek = date?.dayOfWeek() ?? "Monday"
        
        firestore.collection("RecurringEvents").document(dayOfTheWeek).collection("events").getDocuments(completion: { [weak self] snapshot,err in
            guard let strongSelf = self else { return }
            strongSelf.handleEventQueryResults(querySnapshot: snapshot, err: err, fast: false, getImage: false, eventCompletion: { event in
                eventCompletion(event)
            }, allCompletion: { result in
                allCompletion(result)
            })
            
        })
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
            
            let events = s.map({ Event(eventId : $0) })
            var successEvents = [Event]()
            var count = 0
            for event in events {
                DatabaseManager.shared.loadEvent(event: event, completion: { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let event):
                        count += 1
                        successEvents.append(event)
                        if count == events.count {
                            User.setUDEvents(events: successEvents, toKey: .savedEvents)
                        }
                    case .failure(_):
                        strongSelf.loadExpiredEvent(event: event, completion: { result in
                            switch result {
                            case .success(let event) :
                                count += 1
                                successEvents.append(event)
                                if count == events.count {
                                    User.setUDEvents(events: successEvents, toKey: .savedEvents)
                                }
                            case .failure(let error) :
                                count += 1
                                if count == events.count {
                                    User.setUDEvents(events: successEvents, toKey: .savedEvents)
                                }
                                print("error loading saved event Error: \(error)")
                            }
                        })
                        
                    }
                })
            }
            completion()
        }
    }
    
    public func loadEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void){
        firestore.collection("EventProfiles").document(event.eventId).getDocument(as: event.getEncoderType().self)  { result in
            switch result {
            case .success(let eventCoder):
                print("Success loading")
                eventCoder.updateEvent(event: event)
                event.loadStatus = .UserProfileNoPic
                completion(.success(event))
                DatabaseManager.shared.getImages(Id: event.eventId, indices: event.eventCoverIndex, type: DatabaseManager.ImageType.eventCoverIndex, completion: { res in
//                DatabaseManager.shared.getImages(Id: event.eventId, indices: event.eventCoverIndex, event: true, completion: { res in
                    switch res{
                    case .success(let url):
                        event.loadStatus = .UserProfile
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
                completion(.failure(error))
                print("failed to load event Error: \(error)")
            }
            
        }
    }
    
    public func loadExpiredEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void){
        firestore.collection("EventProfiles").document(event.eventId).getDocument(as: event.getEncoderType().self)  { result in
            switch result {
            case .success(let eventCoder):
                print("Success loading")
                eventCoder.updateEvent(event: event)
                completion(.success(event))
                DatabaseManager.shared.getImages(Id: event.eventId, indices: event.eventCoverIndex, type: DatabaseManager.ImageType.eventCoverIndex, completion: { res in
//                DatabaseManager.shared.getImages(Id: event.eventId, indices: event.eventCoverIndex, event: true, completion: { res in
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
                completion(.failure(error))
                print("failed to load event Error: \(error)")
            }
            
        }
    }
    
    
    
    
    public func createHappenings(events: [RecurringEvent]) {
        for event in events {
            do {
                try  firestore.collection("RecurringEvents")
                    .document(event.dayOfTheWeek)
                    .collection("events")
                    .document(event.eventId)
                    .setData(from: event.getEncoder())
            } catch {
                print("Fuck")
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
                
                User.appendUDEvent(event: event, toKey: .hostedEvents)
                
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
    }
    
    public func inviteHosts(event: Event, users: [User], completion: @escaping (Error?) -> Void){
        firestore.collection("EventProfiles").document(event.eventId).updateData(["hosts" : FieldValue.arrayUnion(users.map({ $0.userId }))]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            
            completion(nil)
        }
    }
    
    public func uninviteHosts(event: Event, users: [User], completion: @escaping (Error?) -> Void){
        firestore.collection("EventProfiles").document(event.eventId).updateData(["hosts" : FieldValue.arrayRemove(users.map({ $0.userId }))]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            for user in users {
                event.uninviteHost(user: user)
            }
            
            completion(nil)
        }
    }
    
    public func uninviteUsers(event: Event, users: [User], completion: @escaping (Error?) -> Void){
        firestore.collection("EventProfiles").document(event.eventId).updateData(["usersInvite" : FieldValue.arrayRemove(users.map({ $0.userId })),
                                                                                  "usersGoing" : FieldValue.arrayRemove(users.map({ $0.userId })),
                                                                                  "usersNotGoing" : FieldValue.arrayRemove(users.map({ $0.userId })),
                                                                                  "hosts" : FieldValue.arrayRemove(users.map({ $0.userId }))]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            for user in users {
                event.uninviteHost(user: user)
            }
            completion(nil)
        }
    }

    public func inviteUsers(event: Event, users: [User], completion: @escaping (Error?) -> Void){
        firestore.collection("EventProfiles").document(event.eventId).updateData(["usersInvite" : FieldValue.arrayUnion(users.map({ $0.userId }))]) { error in
            guard error == nil else {
                completion(error!)
                return
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
            User.appendUDEvent(event: event, toKey: .goingEvents)
            User.removeUDEvent(event: event, toKey: .notGoingEvents)
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
            User.appendUDEvent(event: event, toKey: .notGoingEvents)
            User.removeUDEvent(event: event, toKey: .goingEvents)
            completion(nil)
        }
    }
    
    public func markSaved(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        User.appendUDEvent(event: event, toKey: .savedEvents)
        firestore.collection("UserStoredEvents").document(selfId).setData(["saved": FieldValue.arrayUnion([event.eventId])]) { error in
            guard error == nil else {
                completion(error!)
                return
            }
            completion(nil)
        }
    }
    
    public func markUnsaved(event: Event, completion: @escaping (Error?) -> Void){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        User.removeUDEvent(event: event, toKey: .savedEvents)
        firestore.collection("UserStoredEvents").document(selfId).setData(["saved": FieldValue.arrayRemove([event.eventId])]) { error in
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
                                 image im: UIImage? = UIImage(named: "defaultPromoterEventProfilePic"),
                                 imageURL url: URL? = nil,
                                 endTimeString ets: String = "",
                                 startTimeString sts: String = "",
                                 type t: EventType = .Event,
                                 eventCoverIndex ecI: [Int] = [],
                                 eventPicIndices epI: [Int] = []) -> Event{
        let baseEvent = Event(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI)
        switch t{
        case .Event: return baseEvent
        case .Closed, .Open: return UserEvent(event: baseEvent, type: t)
        case .Promoter: return PromoterEvent(event: baseEvent, price: nil, buyTicketsLink: nil)
        case .Recurring: return RecurringEvent(event: baseEvent, cat: .Deal, phoneN: nil, web: nil, ven: nil, price: nil, buyTicketsLink: nil)
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

