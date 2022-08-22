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
    
    override func getEncoder() -> EventCoder {
        return PublicEventCoder(event: self)
    }
    
    override func getEncoderType() -> EventCoder.Type {
        return PrivateEventCoder.self
    }
}

public class PublicEventCoder: EventCoder {

    init(event: PublicEvent){
        super.init(event: event)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override public func createEvent() -> Event {
        let event = PublicEvent()
        updateEvent(event: event)
        return event
    }
}
