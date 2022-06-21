//
//  Event.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import Foundation
import UIKit
import CoreLocation

//for future, enumerate event type

public class Event {
    var eventId: String = ""
    var title: String = ""
    
    var coordinates: CLLocation = CLLocation()
    var hosts: [User] = []
    var description: String = ""
    var address: String = ""
    var locationName: String = ""
//Mark: Will comment out once fixed Yianni's old code
    var maxGuests: Int
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
        print(eventId)
        print(title)
        print(coordinates.coordinate.latitude)
        print(coordinates.coordinate.longitude)
        print(hosts[0].userId)
        print(description)
        print(maxGuests)
        print(startTimeString)
        print(endTimeString)
        print(imageUrl)
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
        let type = getType()
        switch type{
        case 0:
            return true
        case 1:
            return true
        case 2:
            return true
        case 3:
            return false
        case 4:
            return false
        default:
            return false
        }
    }
    public func getType() -> Int{
        return 0
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
    
    override public func getType() -> Int {
        return 1
    }
}

public class PromoterEvent: PublicEvent {
    
    override public func dispatch(user:User) -> Bool {
        return true
    }
    override public func getType() -> Int {
        return 2
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
    override public func getType() -> Int {
        return 3
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
    override public func getType() -> Int {
        return 4
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
                        type t: Int = -1) -> Event{
    switch t{
    case 0:
        return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
    case 1:
        return PublicEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
    case 2:
        return PromoterEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
    case 3:
        return PrivateEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
    case 4:
        return FriendsEvent(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
    default:
        return Event(eventId: Id, title: tit, coordinates: loc, hosts: host, description: desc, address: addy, locationName: locName, maxGuests: maxG, usersGoing: ugoing, usersInterested: uinterested, usersInvite: uinvite, startTime: stime, endTime: etime, duration: dur, image: im, imageURL: url, endTimeString: ets, startTimeString: sts)
    }
    
}
