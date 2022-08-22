//
//  PrivateEvent.swift
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

public class PrivateEvent: Event {

    override public func dispatch(user:User) -> Bool {
        if(usersInvite.contains(where: { (id) in
            return (user.userId == id.userId)
        })) {
            return true
        } else {
            return false
        }

    }
    override func getEncoder() -> EventCoder {
        return PrivateEventCoder(event: self)
    }
    
    override func getEncoderType() -> EventCoder.Type {
        return PrivateEventCoder.self
    }
    
    override public func getType() -> EventType {
        return .Private
    }
}

public class PrivateEventCoder: EventCoder {

    init(event: PrivateEvent){
        super.init(event: event)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override public func createEvent() -> Event {
        let event = PrivateEvent()
        updateEvent(event: event)
        return event
    }
}
