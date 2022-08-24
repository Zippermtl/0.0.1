//
//  PublicEvent.swift
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

public class OpenEvent: Event {
    override init() {
        super.init()
    }
    
    override init(event: Event) {
        super.init(event: event)
    }
    
    init(closedEvent: ClosedEvent) {
        super.init(event: closedEvent)
    }
    
    override public func dispatch(user:User) -> Bool {
        if (usersGoing.count < maxGuests){
            return true
        }
        return false
    }
    
    public override func getType() -> EventType {
        return .Open
    }
    
    public override func isPublic() -> Bool {
        return true
    }
    
    override func getEncoder() -> EventCoder {
        return OpenEventCoder(event: self)
    }
    
    override func getEncoderType() -> EventCoder.Type {
        return OpenEventCoder.self
    }
}

public class OpenEventCoder: EventCoder {
    
    init(event: OpenEvent){
        super.init(event: event)
    }
    
    enum CodingKeys: String, CodingKey {
        case discoverable = "discoverable"
    }
    
    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        discoverable = try container.decode(Bool.self, forKey: .discoverable)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(discoverable, forKey: .discoverable)
        try super.encode(to: encoder)
    }
    
    override public func createEvent() -> Event {
        let event = OpenEvent()
        updateEvent(event: event)
        return event
    }
}
