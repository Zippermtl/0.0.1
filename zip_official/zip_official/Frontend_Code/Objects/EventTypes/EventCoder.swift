//
//  EventCoder.swift
//  zip_official
//
//  Created by user on 9/9/22.
//

import Foundation
import UIKit
import FirebaseFirestore
import CodableFirebase
import CoreLocation
import FirebaseFirestoreSwift
import MapKit

//MARK: Event Coder
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
    
    var phoneNumber: Int?
    var category: CategoryType?
    var website: String?
    var venu: String?
    
    
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
        
        if let rEvent = event as? RecurringEvent {
            self.phoneNumber = rEvent.phoneNumber
            self.category = rEvent.category
            self.website = rEvent.website
            self.venu = rEvent.venu
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
        
        case phoneNumber = "phoneNumber"
        case category = "category"
        case website = "website"
        case venu = "venu"
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
        
        self.phoneNumber = try? container.decode(Int.self, forKey: .phoneNumber)
//        self.category = try? container.decode(CategoryType(rawValue: String.self), forKey: .category)

        let catagoryString = try? container.decode(String.self, forKey: .category)
        if let s = catagoryString {
            self.category = CategoryType(rawValue: s)
        } else {
            self.category = nil
        }
        self.website = try? container.decode(String.self, forKey: .website)
        self.venu = try? container.decode(String.self, forKey: .venu)

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
        try? container.encode(phoneNumber, forKey: .phoneNumber)
        try? container.encode(category?.rawValue, forKey: .category)
        try? container.encode(website, forKey: .website)
        try? container.encode(venu, forKey: .venu)
    }
    
    public func createEvent() -> Event {
        let t = EventType(rawValue: type)!
        switch t {
        case .Event:
            let event = Event()
            updateEvent(event: event)
            return event
        case .Open, .Closed:
            let event = UserEvent(type: t)
            updateEvent(event: event)
            return event
        case .Promoter:
            let event = PromoterEvent()
            updateEvent(event: event)
            return event
        case .Recurring:
            let event = RecurringEvent()
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
        
        if let price = price,
           let link = link,
           let pEvent = event as? PromoterEvent  {
            pEvent.price = price
            pEvent.buyTicketsLink = URL(string: link)
        }
        
        if let p = phoneNumber,
           let c = category,
           let w = website,
           let v = venu,
           let rEvent = event as? RecurringEvent {
            rEvent.phoneNumber = p
            rEvent.category = c
            rEvent.website = w.replacingOccurrences(of: "\r", with: "")
            rEvent.venu = v
        }
            
       
    }
}
