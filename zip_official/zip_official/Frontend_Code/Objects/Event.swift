//
//  Event.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import Foundation
import UIKit
import CoreLocation

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
}


public class Event : Encodable {
    enum CodingKeys: String, CodingKey {
        case eventId
        case title
        case coordinates
        case hosts
        case description
        case address
        case maxGuests = "max"
        case usersGoing
        case usersInvite
        case startTime
        case endTime
        case type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventId, forKey: .eventId)
        try container.encode(title, forKey: .title)
        try container.encode(["lat" : latitude, "long": longitude], forKey: .coordinates)
        try container.encode(Dictionary(uniqueKeysWithValues: hosts.map { ($0.userId, $0.fullName )}), forKey: .hosts)
        try container.encode(description, forKey: .description)
        try container.encode(address, forKey: .address)
        try container.encode(maxGuests, forKey: .maxGuests)
        try container.encode(Dictionary(uniqueKeysWithValues: usersGoing.map { ($0.userId, $0.fullName )}), forKey: .usersGoing)
        try container.encode(Dictionary(uniqueKeysWithValues: usersInvite.map { ($0.userId, $0.fullName )}), forKey: .usersInvite)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
    }
    
//    enum CodingKeys: String, CodingKey {
//        case eventId
//        case title
//        case latitude
//        case longitude
//        case description
//        case address
//        case startTime
//        case endTime
//        case maxGuests
//        case hosts
//        case usersInvite
//
//        case locationName
//        case usersInterested
//        case duration
//        case imageUrl
//        case image
//    }
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.eventId = try container.decode(String.self, forKey: .eventId)
//        self.title = try container.decode(String.self, forKey: .title)
//        let lat = try container.decode(Double.self, forKey: .latitude)
//        let long = try container.decode(Double.self, forKey: .longitude)
//        self.coordinates = CLLocation(latitude: lat, longitude: long)
//        self.description = try container.decode(String.self, forKey: .description)
//
//        let startTimeDouble = try  container.decode(Double.self, forKey: .startTime)
//        self.startTime = Date(timeIntervalSince1970: startTimeDouble)
//
//        let endTimeDouble = try  container.decode(Double.self, forKey: .endTime)
//        self.endTime = Date(timeIntervalSince1970: endTimeDouble)
//
//        self.maxGuests = try container.decode(Int.self, forKey: .maxGuests)
//
//        let hostsDict = try container.decode([String:String].self, forKey: .hosts)
//        self.hosts = hostsDict.keys.map { User(userId: $0) }
//
//        let inviteDict = try container.decode([String:String].self, forKey: .usersInvite)
//        self.usersInvite = inviteDict.keys.map { User(userId: $0) }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(eventId, forKey: .eventId)
//        try container.encode(title, forKey: .title)
//
//        try container.encode(coordinates.coordinate.latitude, forKey: .latitude)
//        try container.encode(coordinates.coordinate.longitude, forKey: .longitude)
//        try container.encode(description, forKey: .description)
//        try container.encode(address, forKey: .address)
//        try container.encode(startTime.timeIntervalSince1970, forKey: .startTime)
//        try container.encode(endTime.timeIntervalSince1970, forKey: .endTime)
//        try container.encode(maxGuests, forKey: .maxGuests)
//        try container.encode(Dictionary(uniqueKeysWithValues: hosts.map { ($0.userId, $0.fullName )}), forKey: .usersInvite)
//        try container.encode(Dictionary(uniqueKeysWithValues: usersInvite.map { ($0.userId, $0.fullName )}), forKey: .hosts)
//    }
    
    
    
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
    var endTime: Date = Date()
    var duration: TimeInterval = TimeInterval(1)
    var imageUrl: URL = URL(string: "a")!
    var image: UIImage? = UIImage(named: "launchevent")
    
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

        return userLoc.distance(from: coordinates)
    }
    
    func getDistanceString() -> String {
        var distanceText = ""
        var unit = "km"
        var distance = Double(round(10*(getDistance())/1000))/10

        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
        }
        
        if distance > 10 {
            let intDistance = Int(distance)
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceText = "<1 \(unit)"
            } else if distance >= 500 {
                distanceText = ">500 \(unit)"
            } else {
                distanceText = String(intDistance) + " \(unit)"
            }
        } else {
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceText = "<1 \(unit)"
            } else if distance >= 500 {
                distanceText = ">500 \(unit)"
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
         startTimeString sts: String = "") {
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
    }
}
