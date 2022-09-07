//
//  Event.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import Foundation
import UIKit
import FirebaseFirestore
import CodableFirebase
import CoreLocation
import FirebaseFirestoreSwift
import MapKit

enum EventSaveStatus: Int {
    case SAVED = 0
    case GOING = 1

}

extension EventType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Event: return "Event"
        case .Open: return "Open Event"
        case .Closed: return "Closed Event"
        case .Promoter: return "Promoter Event"
        }
    }
    
    public var color: UIColor {
        switch self {
        case .Event: return .zipYellow
        case .Open: return .zipBlue
        case .Closed: return .zipBlue
        case .Promoter: return .zipYellow
        }
    }
    
    public func getData(document: QueryDocumentSnapshot) throws -> Event  {
        switch self {
        case .Event: return try document.data(as: EventCoder.self).createEvent()
        case .Open: return try document.data(as: OpenEventCoder.self).createEvent()
        case .Closed: return try document.data(as: ClosedEventCoder.self).createEvent()
        case .Promoter: return try document.data(as: EventCoder.self).createEvent()
        }
    }
}

public class LocalEventCoder : EventCoder {
    var id: String?
    var imageUrl : String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case imageUrl = "imageUrl"
    }
    
    override init(event: Event) {
        self.id = event.eventId
        self.imageUrl = event.imageUrl?.absoluteString
        super.init(event: event)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(imageUrl, forKey: .imageUrl)
        try super.encode(to: encoder)
    }
    
    override public func createEvent() -> Event {
        let event = super.createEvent()
        if let id = id {
            event.eventId = id
        }
        if let imageUrl = imageUrl {
            event.imageUrl = URL(string: imageUrl)
        }
        return event
    }

}

//for future, enumerate event type
public class EventCoder: Codable {
    var title: String
    var coordinates: [String: Double]
    var hosts: [String]
    var bio: String
    var address: String
    var maxGuests: Int
    var usersGoing: [String]
    var usersNotGoing: [String]
    var usersInvite: [String]
    var startTime: Timestamp
    var endTime: Timestamp
    var type: Int
    var eventCoverIndex: [Int]
    var eventPicIndices: [Int]
    var picNum: Int
    var LCTitle: String
    var allowUserInvites: Bool
    var ownerName: String
    var ownerId: String
    
    var price: Double?
    var link: String?

    
    init(event: Event) {
        self.title = event.title
        self.coordinates = ["lat":event.coordinates.coordinate.latitude,"long": event.coordinates.coordinate.longitude]
        self.hosts = event.hosts.map({($0.userId)})
        self.bio = event.bio
        self.address = event.address
        self.maxGuests = event.maxGuests
        self.usersGoing = event.usersGoing.map({$0.userId})
        self.usersNotGoing = event.usersNotGoing.map({$0.userId})
        self.usersInvite = event.usersInvite.map({$0.userId})
        self.startTime = Timestamp(date: event.startTime)
        self.endTime = Timestamp(date: event.endTime)
        self.type = event.getType().rawValue
        self.eventCoverIndex = event.eventCoverIndex
        self.eventPicIndices = event.eventPicIndices
        self.picNum = event.picNum
        self.LCTitle = event.title.lowercased()
        self.allowUserInvites = event.allowUserInvites
        self.ownerId = event.ownerId
        self.ownerName = event.ownerName

        if let pEvent = event as? PromoterEvent {
            self.price = pEvent.price
            self.link = pEvent.buyTicketsLink?.absoluteString
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case coordinates = "coordinates"
        case hosts = "hosts"
        case bio = "bio"
        case address = "address"
        case maxGuests = "max"
        case usersGoing = "usersGoing"
        case usersInvite = "usersInvite"
        case startTime = "startTime"
        case endTime = "endTime"
        case type = "type"
        case eventCoverIndex = "eventCoverIndex"
        case eventPicIndices = "eventPicIndices"
        case picNum = "picNum"
        case LCTitle = "LCTitle"
        case usersNotGoing = "usersNotGoing"
        case allowUserInvites = "allowUserInvites"
        case ownerName = "ownerName"
        case ownerId = "ownerId"
        case price = "price"
        case link = "buyTicketsLink"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.coordinates = try container.decode([String:Double].self, forKey: .coordinates)
        self.hosts = try container.decode([String].self, forKey: .hosts)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.address = try container.decode(String.self, forKey: .address)
        self.maxGuests = try container.decode(Int.self, forKey: .maxGuests)
        self.usersGoing = try container.decode([String].self, forKey: .usersGoing)
        self.usersNotGoing = try container.decode([String].self, forKey: .usersNotGoing)
        self.usersInvite = try container.decode([String].self, forKey: .usersInvite)
        self.startTime = try container.decode(Timestamp.self, forKey: .startTime)
        self.endTime = try container.decode(Timestamp.self, forKey: .endTime)
        self.type = try container.decode(Int.self, forKey: .type)
        self.eventCoverIndex = try container.decode([Int].self, forKey: .eventCoverIndex)
        self.eventPicIndices = try container.decode([Int].self, forKey: .eventPicIndices)
        self.picNum = try container.decode(Int.self, forKey: .picNum)
        self.LCTitle = try container.decode(String.self, forKey: .LCTitle)
        self.allowUserInvites = try container.decode(Bool.self, forKey: .allowUserInvites)
        self.ownerName = try container.decode(String.self, forKey: .ownerName)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        
        self.price = try? container.decode(Double.self, forKey: .price)
        self.link = try? container.decode(String.self, forKey: .link)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(hosts, forKey: .hosts)
        try container.encode(bio, forKey: .bio)
        try container.encode(address, forKey: .address)
        try container.encode(maxGuests, forKey: .maxGuests)
        try container.encode(usersGoing, forKey: .usersGoing)
        try container.encode(usersNotGoing, forKey: .usersNotGoing)
        try container.encode(usersInvite, forKey: .usersInvite)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(type, forKey: .type)
        try container.encode(eventCoverIndex, forKey: .eventCoverIndex)
        try container.encode(eventPicIndices, forKey: .eventPicIndices)
        try container.encode(picNum, forKey: .picNum)
        try container.encode(LCTitle, forKey: .LCTitle)
        try container.encode(allowUserInvites, forKey: .allowUserInvites)
        try container.encode(ownerName, forKey: .ownerName)
        try container.encode(ownerId, forKey: .ownerId)
        
        try? container.encode(price, forKey: .price)
        try? container.encode(link, forKey: .link)
    }
    
    public func createEvent() -> Event {
        switch EventType(rawValue: type)! {
        case .Event:
            let event = Event()
            updateEvent(event: event)
            return event
        case .Open:
            let event = OpenEvent()
            updateEvent(event: event)
            return event
        case .Closed:
            let event = ClosedEvent()
            updateEvent(event: event)
            return event
        case .Promoter:
            let event = PromoterEvent()
            updateEvent(event: event)
            return event
        }
    }
    
    public func updateEvent(event: Event) {
        event.title = title
        event.coordinates = CLLocation(latitude: coordinates["lat"]!, longitude: coordinates["long"]!)
        event.hosts = hosts.map({ User(userId: $0 )})
        event.bio = bio
        event.address = address
        event.maxGuests = maxGuests
        event.usersGoing = usersGoing.map( { User(userId: $0 )} )
        event.usersNotGoing = usersNotGoing.map( { User(userId: $0 )} )
        event.usersInvite = usersInvite.map( { User(userId: $0 )} )
        event.startTime = startTime.dateValue()
        event.endTime = endTime.dateValue()
        event.allowUserInvites = allowUserInvites
        event.ownerId = ownerId
        event.ownerName = ownerName
        
        guard let price = price,
              let link = link,
            let pEvent = event as? PromoterEvent else {
            return
        }
        pEvent.price = price
        pEvent.buyTicketsLink = URL(string: link)
    }
}

public class Event : Equatable, CustomStringConvertible, CellItem {
    public var isUser: Bool = false
    public var isEvent: Bool = true
    public func getId() -> String {
        return eventId
    }
    
    public var description: String {
        var out = ""
        out += "ID: \(self.eventId)\n"
        out += "type: \(self.getType())\n"
        out += "coordinates: \(self.coordinates)\n"
        out += "address: \(self.address)\n"
        out += "hosts: \(self.hosts.map({ $0.userId }))\n"
        out += "bio: \(self.bio)\n"
        out += "max guests: \(self.maxGuests)\n"
        out += "startTime: \(self.startTime)\n"
        out += "endTime: \(self.endTime)\n"
        out += "usersInvite: \(self.usersInvite.map({ $0.userId }))\n"
        out += "usersGoing: \(self.usersGoing.map({ $0.userId }))\n"
        out += "picNum: \(self.picNum)\n"
        out += "url: \(imageUrl?.absoluteString)\n"

        return out
    }
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.eventId == rhs.eventId
    }
    
    
    
    var eventId: String = ""
    var title: String = ""
    var coordinates: CLLocation = CLLocation()
    var hosts: [User] = []
    var bio: String = ""
    var address: String = ""
    var locationName: String = ""
//Mark: Will comment out once fixed Yianni's old code
    var maxGuests: Int = -1
    var usersGoing: [User] = []
    var usersNotGoing: [User] = []
    var usersInterested: [User] = []
    var usersInvite: [User] = []
    
    
//    var type: String = "promoter"
//    var isPublic: Bool = false
//    var type: Int
    var startTime: Date = Date()
    var endTime: Date = Date(timeInterval: TimeInterval(3600), since: Date())
    var duration: TimeInterval = TimeInterval(1)
    var eventCoverIndex: [Int] = []
    var eventPicIndices: [Int] = []
    var eventPicUrls: [URL] = []
    var picNum: Int = 0
    var allowUserInvites: Bool = false
    var ownerName: String = ""
    var ownerId: String = ""
    
    func getEncoder() -> EventCoder {
        let encoder = EventCoder(event: self)
        return encoder
    }
    
    func getLocalizedEncoder() -> LocalEventCoder {
        return LocalEventCoder(event: self)
    }
    
    func getEncoderType() -> EventCoder.Type {
        return EventCoder.self
    }
    
    var imageUrl: URL? {
        didSet {
            if annotationView != nil {
                annotationView!.updateImage(imageUrl!)
            }
            if tableViewCell != nil {
                tableViewCell!.configureImage(self)
            }
        }
    }
    
    var annotationView : EventAnnotationView?
    var tableViewCell: AbstractEventTableViewCell?
    var mapView: MKMapView?
    var image: UIImage?
    
    func addToMap(){
        guard let mapView = mapView else {
            print("NO MAP VIEW")
            return
        }
        print("ADDING TO MAP ")
        mapView.addAnnotation(EventAnnotation(event: self))
    }
    
    var latitude : Double {
        return coordinates.coordinate.latitude
    }
    
    var longitude : Double {
        return coordinates.coordinate.longitude
    }
    
    
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: startTime)
    }
    
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: startTime)
    }
    
    func getDistance() -> Double {
        guard let userCoordinates = UserDefaults.standard.object(forKey: "userLoc") as? [Double] else {
            return 0
        }
        let userLoc = CLLocation(latitude: userCoordinates[0], longitude: userCoordinates[1])
        print("user lat: ", userCoordinates[0])
        print("user long: ", userCoordinates[1])
        print("Event lat: ", coordinates.coordinate.latitude)
        print("Event long: ", coordinates.coordinate.longitude)

        return userLoc.distance(from: coordinates)
    }
    
    func getDistanceString() -> String {
        var distanceText = ""
        var unit = "km"
        var distance = Double(round(10*(getDistance())/1000))/10
        
        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
            
            if distance == 1 {
                unit = "mile"
            }
        }
            
        if distance < 0 {
            distanceText = "<\(Int(0)) \(unit)"
        } else if distance > 500 {
            distanceText = ">\(Int(500)) \(unit)"
        } else {
            if distance > 10 {
                distanceText = String(Int(distance)) + " \(unit)"
            } else {
                distanceText = String(distance) + " \(unit)"
            }
        }
        
        return distanceText + " away"
    }
    
    var createEventId: String {
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return ""
        }
        let dateString = ChatViewController.dateFormatter.string(from: Date())
        return "\(userId)_\(title.replacingOccurrences(of: " ", with: "-"))_\(dateString)"
    }
    
    func markGoing(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.markGoing(event: self, completion: { err in
            completion(err)
            guard err == nil else {
                return
            }
            let _ = User.removeUDEvent(event: self, toKey: .invitedEvents)
            User.setUDEvents(events: User.removeUDEvent(event: self, toKey: .notGoingEvents), toKey: .goingEvents)
        })
    }
    
    func markNotGoing(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.markGoing(event: self, completion: { err in
            completion(err)
            guard err == nil else {
                return
            }
            let _ = User.removeUDEvent(event: self, toKey: .invitedEvents)
            User.setUDEvents(events: User.removeUDEvent(event: self, toKey: .goingEvents), toKey: .notGoingEvents)
        })
    }
    
    func markSaved(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.markSaved(event: self, completion: { err in
            completion(err)
        })
    }
    
    func markUnsaved(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.markUnsaved(event: self, completion: { err in
            completion(err)
        })
    }
    
    public func dispatch(user: User) -> Bool {
        return true
    }
    
    public func out(){
        print("ID: ", eventId)
        print("Title : ", title)
        print("Lat: ", coordinates.coordinate.latitude)
        print("Long : ", coordinates.coordinate.longitude)
        print("Hosts :", hosts)
        print("Bio: ", bio)
        print("Max guests: ", maxGuests)
        print("Start Time: ", startTimeString)
        print("End Time: ", endTimeString)
        print("Img URL: ", imageUrl ?? "")
        print("Users invite ", usersInvite)
        print("Users going ", usersGoing)
        print("Users Not Going ", usersNotGoing)
        print("allowUserInvites ", allowUserInvites)
    }
    
    func sortUsers(a: User, b: User) -> Bool {
        if a.userId == AppDelegate.userDefaults.value(forKey: "userId") as! String && b.userId == ownerId { return false }
        if b.userId == AppDelegate.userDefaults.value(forKey: "userId") as! String && a.userId == ownerId { return true }
        if a.userId == AppDelegate.userDefaults.value(forKey: "userId") as! String { return true }
        if b.userId == AppDelegate.userDefaults.value(forKey: "userId") as! String { return false }
        return a > b
    }
    
    func getSortedUsers(users: [User]) -> [User] {
        return users.sorted(by:{ sortUsers(a: $0 , b: $1) })
    }
    
    func getParticipants() -> [CellSectionData] {
        let sections = [hostingSection, goingSection, invitedSection, notGoingSection]
        return sections
    }
    
    var hostingSection: CellSectionData { get {
        let items = getSortedUsers(users: self.hosts)
        return CellSectionData(title: "Hosts", items: items, cellType: CellType(userType: .zipList))
    }}
    
    var goingSection: CellSectionData { get {
        let items = getSortedUsers(users: usersGoing).filter({ !hosts.contains($0)} )
        return CellSectionData(title: "Going", items: items, cellType: CellType(userType: .zipList))
    }}
    
    var invitedSection: CellSectionData { get {
        let items = getSortedUsers(users: usersInvite).filter({ !(usersGoing.contains($0)
                                                                  || usersNotGoing.contains($0)
                                                                  || hosts.contains($0)) })
        return CellSectionData(title: "Invited", items: items, cellType: CellType(userType: .zipList))
    }}
    
    var notGoingSection: CellSectionData { get {
        let items = getSortedUsers(users: usersNotGoing)
        return CellSectionData(title: "Not Going", items: items, cellType: CellType(userType: .zipList))
    }}
    
    //MARK: accessory function for yianni to pull for visuals if needed:
    // ex sponsor events could return an even with the visual appened on
    // the picture etc this is the pull for map if it is needed
    public func pullVisual(){
        fatalError("Must Override!")
    }

    public func isPublic() -> Bool {
        return true
    }
        
    public func getType() -> EventType {
        return EventType.Event
    }
        
    init(eventId Id: String = "",
         title tit: String = "",
         coordinates loc: CLLocation = CLLocation(),
         hosts host: [User] = [],
         bio b: String = "",
         address addy: String = "",
         locationName locName: String = "",
         maxGuests maxG: Int = -1,
         usersGoing ugoing: [User] = [],
         usersNotGoing uNotGoing: [User] = [],
         usersInterested uinterested: [User] = [],
         usersInvite uinvite: [User] = [],
         startTime stime: Date = Date(),
         endTime etime: Date = Date(),
         duration dur: TimeInterval = TimeInterval(1),
         image im: UIImage? = UIImage(named: "launchevent"),
         imageURL url: URL = URL(string: "a")!,
         endTimeString ets: String = "",
         startTimeString sts: String = "",
         eventCoverIndex ecI: [Int] = [],
         eventPicIndices epI: [Int] = [],
         allowUserInvites aui: Bool = false,
         ownerName oN: String = "",
         ownerId oId: String = ""

    ) {
        eventId = Id
        title = tit
        coordinates = loc
        hosts = host
        bio = b
        address = addy
        locationName = locName
        maxGuests = maxG
        usersGoing = ugoing
        usersNotGoing = uNotGoing
        usersInterested = uinterested
        usersInvite = uinvite
        startTime = stime
        endTime = etime
        duration = dur
        image = im
        imageUrl = url
        eventCoverIndex = ecI
        eventPicIndices = epI
        allowUserInvites = aui
        ownerId = oId
        ownerName = oN
        if(ets != ""){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            endTime = formatter.date(from: ets)!
        }
        if(sts != ""){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            endTime = formatter.date(from: sts)!
        }
    }
    
    init(event: Event) {
        self.eventId = event.eventId
        self.title = event.title
        self.coordinates = event.coordinates
        self.hosts = event.hosts
        self.bio = event.bio
        self.address = event.address
        self.locationName = event.locationName
        self.maxGuests = event.maxGuests
        self.usersGoing = event.usersGoing
        self.usersNotGoing = event.usersNotGoing
        self.usersInterested = event.usersInterested
        self.usersInvite = event.usersInvite
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.duration = event.duration
        self.image = event.image
        self.imageUrl = event.imageUrl
        self.eventCoverIndex = event.eventCoverIndex
        self.eventPicIndices = event.eventPicIndices
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.allowUserInvites = event.allowUserInvites
        self.ownerId = event.ownerId
        self.ownerName = event.ownerName
    }
    
    init(){
        
    }
    
    static func getTodayUpcomingPrevious(events: [Event]) -> ([Event],[Event],[Event]) {
        var today = [Event]()
        var upcoming = [Event]()
        var previous = [Event]()

        for event in events {
            if event.endTime <= Date() {
                previous.append(event)
            } else if event.startTime >= Date(timeIntervalSinceNow: 86400) {
                upcoming.append(event)
            } else {
                today.append(event)
            }
        }
        
        return (today,upcoming,previous)
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
                             usersNotGoing uNotGoing: [User] = [],
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
                             eventPicIndices epI: [Int] = [],
                             allowUserInvites aui: Bool = false,
                             ownerName oN: String = "",
                             ownerId oId: String = "") -> Event {
    let baseEvent = Event(eventId: Id, title: tit, coordinates: loc, hosts: host, bio: b, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersNotGoing: uNotGoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI,eventPicIndices: epI,allowUserInvites: aui, ownerName: oN, ownerId: oId)
    switch t{
    case .Event: return baseEvent
    case .Closed: return ClosedEvent(event: baseEvent)
    case .Promoter: return PromoterEvent(event: baseEvent, price: nil, buyTicketsLink: nil)
    case .Open: return OpenEvent(event: baseEvent)
    }
    
    
    
    
    
}
