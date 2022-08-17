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
        case .Public: return "Public Event"
        case .Private: return "Private Event"
        case .Friends: return "Zips Event"
        case .Promoter: return "Promoter Event"
        }
    }
    
    public var color: UIColor {
        switch self {
        case .Event: return .zipYellow
        case .Public: return .zipGreen
        case .Private: return .zipBlue
        case .Friends: return .zipBlue
        case .Promoter: return .zipYellow
        }
    }
    
    //TODO: Update with new default images
    public var defaultProfilePictureUrl: URL {
        guard let picString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String,
              let picUrl = URL(string: picString) else {
                  return URL(string: "https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6502222222%2Fprofile_picture.png?alt=media&token=a6e7800d-a34d-43b1-a179-a954d3486787)")!
        }
        
        switch self {
        case .Event: return picUrl
        case .Public: return picUrl
        case .Private: return picUrl
        case .Friends: return picUrl
        case .Promoter: return picUrl
        }
    }
}



//for future, enumerate event type
public class EventCoder: Codable {
    var title: String
    var coordinates: [String: Double]
    var hosts: [String: String]
    var description: String
    var address: String
    var maxGuests: Int
    var usersGoing: [String]
    var usersInvite: [String]
    var startTime: Timestamp
    var endTime: Timestamp
    var type: Int
    var eventCoverIndex: [Int]
    var eventPicIndices: [Int]
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case coordinates = "coordinates"
        
        case hosts = "hosts"
        
        case description = "description"
        
        case address = "address"
        
        case maxGuests = "max"
        case usersGoing = "usersGoing"
        case usersInvite = "usersInvite"
        case startTime = "startTime"
        case endTime = "endTime"
        case type = "type"
        case eventCoverIndex = "eventCoverIndex"
        case eventPicIndices = "eventPicIndices"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.coordinates = try container.decode([String:Double].self, forKey: .coordinates)
        self.hosts = try container.decode([String:String].self, forKey: .hosts)
        self.description = try container.decode(String.self, forKey: .description)
        self.address = try container.decode(String.self, forKey: .address)
        self.maxGuests = try container.decode(Int.self, forKey: .maxGuests)
        self.usersGoing = try container.decode([String].self, forKey: .usersGoing)
        self.usersInvite = try container.decode([String].self, forKey: .usersInvite)
        self.startTime = try container.decode(Timestamp.self, forKey: .startTime)
        self.endTime = try container.decode(Timestamp.self, forKey: .endTime)
        self.type = try container.decode(Int.self, forKey: .type)
        self.eventCoverIndex = try container.decode([Int].self, forKey: .eventCoverIndex)
        self.eventPicIndices = try container.decode([Int].self, forKey: .eventPicIndices)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(hosts, forKey: .hosts)
        try container.encode(description, forKey: .description)
        try container.encode(address, forKey: .address)
        try container.encode(maxGuests, forKey: .maxGuests)
        try container.encode(usersGoing, forKey: .usersGoing)
        try container.encode(usersInvite, forKey: .usersInvite)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(eventCoverIndex, forKey: .eventCoverIndex)
        try container.encode(eventPicIndices, forKey: .eventPicIndices)
    }
    
    public func createEvent() -> Event {
        var hostUsers: [User] = []
        for (id,fullName) in hosts {
            let fullNameArr = fullName.components(separatedBy: " ")
            let firstName: String = fullNameArr[0]
            let lastName: String = fullNameArr[1]
            hostUsers.append(User(userId: id, firstName: firstName, lastName: lastName))
        }
        
        return zip_official.createEvent(
            title: title,
            coordinates: CLLocation(latitude: coordinates["lat"]!, longitude: coordinates["long"]!),
            hosts: hostUsers,
            description: description,
            address: address,
            maxGuests: maxGuests,
            usersGoing: usersGoing.map( { User(userId: $0 )} ),
            usersInvite: usersInvite.map( { User(userId: $0 )} ),
            startTime: startTime.dateValue(),
            endTime: endTime.dateValue(),
            type: EventType(rawValue: type) ?? .Event,
            eventCoverIndex: eventCoverIndex,
            eventPicIndices: eventPicIndices
        )
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
        event.description = description
        event.address = address
        event.maxGuests = maxGuests
        event.usersGoing = usersGoing.map( { User(userId: $0 )} )
        event.usersInvite = usersInvite.map( { User(userId: $0 )} )
        event.startTime = startTime.dateValue()
        event.endTime = endTime.dateValue()
    }
}

public class Event : Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.eventId == rhs.eventId
    }
    
    var eventId: String = ""
    var title: String = ""
    
    var coordinates: CLLocation = CLLocation()
    var hosts: [User] = []
    var description: String = ""
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
        print("Host :", hosts[0].userId)
        print("Bio: ", description)
        print("Max guests: ", maxGuests)
        print("Start Time: ", startTimeString)
        print("End Time: ", endTimeString)
        print("Img URL: ", imageUrl)
        print("Users Invited")
        for i in usersInvite{
            print(i.userId)
        }
    }
    
    public func update(eventId Id: String = "",
                       title tit: String = "",
                       coordinates loc: CLLocation = CLLocation(),
                       hosts host: [User] = [],
                       description desc: String = "",
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
        if(desc != ""){
            description = desc
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
         description desc: String = "",
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
        description = desc
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
}

public class PublicEvent: Event {
   
    override public func dispatch(user:User) -> Bool {
        if (usersGoing.count < maxGuests){
            return true
        }
        return false
    }
    
    public override func getType() -> EventType {
        return .Public
    }
    
    public override func isPublic() -> Bool {
        return true
    }
    
}

public class PromoterEvent: PublicEvent {
    
    override public func dispatch(user:User) -> Bool {
        return true
    }
    override public func getType() -> EventType {
        return .Promoter
    }
}

public class PrivateEvent: Event {

    override public func dispatch(user:User) -> Bool {
        if(usersInvite.contains(where: { (id) in
            return (user.userId == id.userId)
        })) {
            return true
        } else {
            return false
        }
//        for i in usersInvite{
//            if (i == user.userId){
//                return true
//            }
//        }
//        return false
    }
    override public func getType() -> EventType {
        return .Private
    }
}

public class FriendsEvent: PrivateEvent {
    
    override public func dispatch(user:User) -> Bool {
        if(usersInvite.contains(where: { (id) in
            return (user.userId == id.userId)
        })) {
            return true
        } else {
            return false
        }
    }
    override public func getType() -> EventType {
        return .Friends
    }
}

public func createEvent(eventId Id: String = "",
                        title tit: String = "",
                        coordinates loc: CLLocation = CLLocation(),
                        hosts host: [User] = [],
                        description desc: String = "",
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
                        type t: EventType = .Event,
                        eventCoverIndex ecI: [Int] = [],
                        eventPicIndices epI: [Int] = []) -> Event{
    switch t{
    case .Event:
        return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI, eventPicIndices: epI)
    case .Public:
        return PublicEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI, eventPicIndices: epI)
    case .Promoter:
        return PromoterEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI, eventPicIndices: epI)
    case .Private:
        return PrivateEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI, eventPicIndices: epI)
    case .Friends:
        return FriendsEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts, eventCoverIndex: ecI, eventPicIndices: epI)
    }
}
