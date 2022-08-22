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


public class PromoterEvent: PublicEvent {
    var price: Double?
    var buyTicketsLink: String?
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
}

public class PromoterEventCoder: EventCoder {
    var price: Double?
    var link: String?
    init(event: PromoterEvent){
        self.price = event.price
        self.link = event.buyTicketsLink
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
        event.buyTicketsLink = link
    }
    
    override public func createEvent() -> Event {
        let event = PromoterEvent()
        updateEvent(event: event)
        return event
    }
}
