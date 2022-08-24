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
    
    public var coderType: EventCoder.Type {
        switch self {
        case .Event: return EventCoder.self
        case .Open: return OpenEventCoder.self
        case .Closed: return ClosedEventCoder.self
        case .Promoter: return PromoterEventCoder.self
        }
    }
}



//for future, enumerate event type
public class EventCoder: Codable {
    var title: String
    var coordinates: [String: Double]
    var hosts: [String: String]
    var hostIds: [String]
    var bio: String
    var address: String
    var maxGuests: Int
    var usersGoing: [String]
    var usersInvite: [String]
    var startTime: Timestamp
    var endTime: Timestamp
    var type: Int
    var eventCoverIndex: [Int]
    var eventPicIndices: [Int]
    var picNum: Int
    var LCTitle: String
    
    init(event: Event) {
        self.title = event.title
        self.coordinates = ["lat":event.coordinates.coordinate.latitude,"long": event.coordinates.coordinate.longitude]
        self.hosts = Dictionary(uniqueKeysWithValues: event.hosts.map({($0.userId,$0.fullName)}))
        self.hostIds = event.hosts.map({ $0.userId })
        self.bio = event.bio
        self.address = event.address
        self.maxGuests = event.maxGuests
        self.usersGoing = event.usersGoing.map({$0.userId})
        self.usersInvite = event.usersInvite.map({$0.userId})
        self.startTime = Timestamp(date: event.startTime)
        self.endTime = Timestamp(date: event.endTime)
        self.type = event.getType().rawValue
        self.eventCoverIndex = event.eventCoverIndex
        self.eventPicIndices = event.eventPicIndices
        self.picNum = event.picNum
        self.LCTitle = event.title.lowercased()
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
        case hostIds = "hostIds"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.coordinates = try container.decode([String:Double].self, forKey: .coordinates)
        self.hosts = try container.decode([String:String].self, forKey: .hosts)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.address = try container.decode(String.self, forKey: .address)
        self.maxGuests = try container.decode(Int.self, forKey: .maxGuests)
        self.usersGoing = try container.decode([String].self, forKey: .usersGoing)
        self.usersInvite = try container.decode([String].self, forKey: .usersInvite)
        self.startTime = try container.decode(Timestamp.self, forKey: .startTime)
        self.endTime = try container.decode(Timestamp.self, forKey: .endTime)
        self.type = try container.decode(Int.self, forKey: .type)
        self.eventCoverIndex = try container.decode([Int].self, forKey: .eventCoverIndex)
        self.eventPicIndices = try container.decode([Int].self, forKey: .eventPicIndices)
        self.picNum = try container.decode(Int.self, forKey: .picNum)
        self.LCTitle = try container.decode(String.self, forKey: .LCTitle)
        self.hostIds = try container.decode([String].self, forKey: .hostIds)
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
        try container.encode(usersInvite, forKey: .usersInvite)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(type, forKey: .type)
        try container.encode(eventCoverIndex, forKey: .eventCoverIndex)
        try container.encode(eventPicIndices, forKey: .eventPicIndices)
        try container.encode(picNum, forKey: .picNum)
        try container.encode(LCTitle, forKey: .LCTitle)
        try container.encode(hostIds, forKey: .hostIds)
    }
    
    public func createEvent() -> Event {
        let event = Event()
        updateEvent(event: event)
        return event
    }
    
    public func updateEvent(event: Event) {
        var hostUsers: [User] = []
        for (id,fullName) in hosts {
            let fullNameArr = fullName.components(separatedBy: " ")
            let firstName: String = fullNameArr[0]
            let lastName: String = fullNameArr[1]
            hostUsers.append(User(userId: id, firstName: firstName, lastName: lastName))
        }
        
        event.title = title
        event.coordinates = CLLocation(latitude: coordinates["lat"]!, longitude: coordinates["long"]!)
        event.hosts = hostUsers
        event.bio = bio
        event.address = address
        event.maxGuests = maxGuests
        event.usersGoing = usersGoing.map( { User(userId: $0 )} )
        event.usersInvite = usersInvite.map( { User(userId: $0 )} )
        event.startTime = startTime.dateValue()
        event.endTime = endTime.dateValue()
    }
}

public class Event : Equatable, CustomStringConvertible {
    public var description: String {
        var out = ""
        out += "ID: \(self.eventId)\n"
        out += "type: \(self.getType())\n"
        out += "coordinates: \(self.coordinates)\n"
        out += "address: \(self.address)\n"

        out += "hosts: \(self.hosts)\n"
        out += "bio: \(self.bio)\n"
        out += "max guests: \(self.maxGuests)\n"
        out += "startTime: \(self.startTime)\n"
        out += "endTime: \(self.endTime)\n"
        out += "usersInvite: \(self.usersInvite)\n"
        out += "usersGoing: \(self.usersGoing)\n"
        out += "picNum: \(self.picNum)\n"
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
    
    func getEncoder() -> EventCoder {
        let encoder = EventCoder(event: self)
        return encoder
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
            return
        }
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
        print("Img URL: ", imageUrl)
        print("Users invite", usersInvite)
        print("Users going", usersGoing)
    }
    
    public func update(eventId Id: String = "",
                       title tit: String = "",
                       coordinates loc: CLLocation = CLLocation(),
                       hosts host: [User] = [],
                       bio b: String = "",
                       address addy: String = "",
                       locationName locName: String = "",
                       maxGuests maxG: Int = -1,
                       usersGoing ugoing: [User] = [],
                       usersInterested uinterested: [User] = [],
                       usersInvite uinvite: [User] = [],
                       startTime stime: Date = Date(),
                       endTime etime: Date = Date(),
                       duration dur: TimeInterval = TimeInterval(1),
                       image im: UIImage? = UIImage(named: "launchevent")){
        if(Id != self.eventId){
            eventId = Id
        }
        if(tit != self.title){
            title = tit
        }
        if(loc.coordinate.latitude != CLLocation().coordinate.latitude || loc.coordinate.longitude != CLLocation().coordinate.longitude){
            coordinates = loc
        }
        if(host.count != 0){
            hosts = host
        }
        if(b != ""){
            bio = b
        }
        if(addy != ""){
            address = addy
        }
        if(locName != ""){
            locationName = locName
        }
        if(maxG != -1){
            maxGuests = maxG
        }
        if(ugoing.count != 0){
            usersGoing = ugoing
        }
        if(uinterested.count != 0){
            usersInterested = uinterested
        }
        if(uinvite.count != 0){
            usersInvite = uinvite
        }
        if(stime != Date()){
            startTime = stime
        }
        if(etime != Date()){
            endTime = etime
        }
        if(dur != TimeInterval(1)){
            duration = dur
        }
        if(im != UIImage(named: "launchevent")){
            image = im
        }
    }
    
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
         eventPicIndices epI: [Int] = []) {
        eventId = Id
        title = tit
        coordinates = loc
        hosts = host
        bio = b
        address = addy
        locationName = locName
        maxGuests = maxG
        usersGoing = ugoing
        usersInterested = uinterested
        usersInvite = uinvite
        startTime = stime
        endTime = etime
        duration = dur
        image = im
        imageUrl = url
        eventCoverIndex = ecI
        eventPicIndices = epI
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
        self.usersInterested = event.usersInterested
        self.usersInvite = event.usersInterested
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.duration = event.duration
        self.image = event.image
        self.imageUrl = event.imageUrl
        self.eventCoverIndex = event.eventCoverIndex
        self.eventPicIndices = event.eventPicIndices
        self.startTime = event.startTime
        self.endTime = event.endTime
    }
    
    init(){
        
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
