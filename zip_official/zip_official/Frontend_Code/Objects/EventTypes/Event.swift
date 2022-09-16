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
        case .Recurring: return "Recurring Event"
        }
    }
    
    public var color: UIColor {
        switch self {
        case .Event: return .zipBlue
        case .Open: return .zipBlue
        case .Closed: return .zipBlue
        case .Promoter: return .zipYellow
        case .Recurring: return .zipYellow
        }
    }
    
    public func getData(document: QueryDocumentSnapshot) throws -> Event  {
        return try document.data(as: EventCoder.self).createEvent()
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
    
    public enum EventLoadType: Int {
        case EventProfile = 0
        case EventProfileUpdates = 1
        case EventProfileNoPic = 2
        case SubView = 3
        case ProfilePicUrl = 4
        case PicUrls = 5
        case Unloaded = 6
    }
    
    public var loadStatus: User.UserLoadType = .Unloaded
    
    
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
    
    var viewController : EventViewController {
        if hosts.contains(where: {$0.userId == AppDelegate.userDefaults.value(forKey: "userId") as! String})  {
            return MyEventViewController(event: self)
        } else {
            return EventViewController(event: self)
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
        if let mapVC = mapView.parentViewController as? MapViewController {
            mapVC.addEvent(event: self)
        }
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
    
    func canIGo() -> Bool {
        let selfUser = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String)
        return getType() == .Promoter || hosts.contains(selfUser) || usersInvite.contains(selfUser) || usersGoing.contains(selfUser)
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
    
    func uninviteUser(user: User) {
        if let inviteIndx = self.usersInvite.firstIndex(of: user) {
            self.usersInvite.remove(at: inviteIndx)
        }
        
        if let goingIdx = self.usersGoing.firstIndex(of: user) {
            self.usersInvite.remove(at: goingIdx)
        }
        
        if let notGoingIdx = self.usersNotGoing.firstIndex(of: user) {
            self.usersNotGoing.remove(at: notGoingIdx)
        }
        
        if let hostIdx = self.hosts.firstIndex(of: user) {
            self.hosts.remove(at: hostIdx)
        }
    }
    
    func uninviteHost(user: User) {
        if let hostIdx = self.hosts.firstIndex(of: user) {
            self.hosts.remove(at: hostIdx)
        }
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
            User.removeUDEvent(event: self, toKey: .invitedEvents)
            User.removeUDEvent(event: self, toKey: .notGoingEvents)
            User.appendUDEvent(event: self, toKey: .goingEvents)
        })
    }
    
    func markNotGoing(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.markNotGoing(event: self, completion: { err in
            completion(err)
            guard err == nil else {
                return
            }
            User.removeUDEvent(event: self, toKey: .invitedEvents)
            User.removeUDEvent(event: self, toKey: .goingEvents)
            User.appendUDEvent(event: self, toKey: .notGoingEvents)
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
    
    func getImage(completion: @escaping (Result<URL?,Error>) -> Void) {
        DatabaseManager.shared.getImages(Id: eventId, indices: eventCoverIndex, event: true, completion: { [weak self] res in
            guard let strongSelf = self else { return }
            switch res {
            case .success(let urls) :
                if urls.count == 0 {
                    completion(.success(nil))
                } else {
                    strongSelf.imageUrl = urls[0]
                    completion(.success(urls[0]))
                }
            case .failure(let error) :
                completion(.failure(error))
            }
        })
    }
    
    func updateImageInView(completion: @escaping (Error?) -> Void) {
        getImage { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let url) :
                if let annotationView = strongSelf.annotationView {
                    guard let url = url else { return }
                    annotationView.updateImage(url)
                }
                
                if let cell = strongSelf.tableViewCell {
                    cell.configureImage(strongSelf)
                }
                completion(nil)
            case .failure(let error): completion(error)
            }
            
        }
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
        let items = getSortedUsers(users: usersNotGoing).filter({ !hosts.contains($0)} )
        return CellSectionData(title: "Not Going", items: items, cellType: CellType(userType: .zipList))
    }}
    
    //MARK: accessory function for yianni to pull for visuals if needed:
    // ex sponsor events could return an even with the visual appened on
    // the picture etc this is the pull for map if it is needed
    public func pullVisual(){
        fatalError("Must Override!")
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
         image im: UIImage? = UIImage(named: "defaultPromoterEventProfilePic"),
         imageURL url: URL? = nil,
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
                             image im: UIImage? = UIImage(named: "defaultPromoterEventProfilePic"),
                             imageURL url: URL? = nil,
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
    case .Closed, .Open: return UserEvent(event: baseEvent, type: t)
    case .Promoter: return PromoterEvent(event: baseEvent, price: nil, buyTicketsLink: nil)
    case .Recurring: return RecurringEvent(event: baseEvent, cat: .Deal, phoneN: nil, web: nil, ven: nil, price: nil, buyTicketsLink: nil)
    }
    
}
