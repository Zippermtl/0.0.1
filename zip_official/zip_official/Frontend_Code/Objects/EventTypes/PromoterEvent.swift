//
//  PromoterEvent.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/20/22.
//

import Foundation
import UIKit
import FirebaseFirestore
import CodableFirebase
import CoreLocation
import FirebaseFirestoreSwift
import MapKit


public class PromoterEvent: Event {
    
    var price: Double?
    var buyTicketsLink: URL?
    
    override init() {
        super.init()
    }
    
    init(event: Event, price: Double?, buyTicketsLink: URL?) {
        self.price = price
        self.buyTicketsLink = buyTicketsLink
        super.init(event: event)
        self.allowUserInvites = true
    }
    
    override public func dispatch(user:User) -> Bool {
        return true
    }
    override public func getType() -> EventType {
        return .Promoter
    }
    
    override func getEncoderType() -> EventCoder.Type {
        return PromoterEventCoder.self
    }
    
    override func getEncoder() -> EventCoder {
        return PromoterEventCoder(event: self)
    }
    
    override func getParticipants() -> [UserCellSectionData] {
        let going = UserCellSectionData(title: "Going",
                                        users: usersGoing)
        let invited = UserCellSectionData(title: "Not Going",
                                          users: usersNotGoing)
        
        let sections = [going, invited]
        return sections
    }
}

public class PromoterEventCoder: EventCoder {
    var price: Double?
    var link: String?
    
    init(event: PromoterEvent){
        self.price = event.price
        self.link = event.buyTicketsLink?.absoluteString
        super.init(event: event)
    }
    
    enum CodingKeys: String, CodingKey {
        case price = "price"
        case link = "buyTicketsLink"
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try? container.decode(Double.self, forKey: .price)
        link = try? container.decode(String.self, forKey: .link)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(price, forKey: .price)
        try container.encode(link, forKey: .link)
        try super.encode(to: encoder)
    }
    
    public func updateEvent(event: PromoterEvent) {
        super.updateEvent(event: event)
        event.price = price
        event.buyTicketsLink = URL(string: link ?? "")
    }
    
    override public func createEvent() -> PromoterEvent {
        let baseEvent = super.createEvent()
        let event = PromoterEvent(event: baseEvent, price: price, buyTicketsLink: URL(string: link ?? "") )
        return event
    }
}
