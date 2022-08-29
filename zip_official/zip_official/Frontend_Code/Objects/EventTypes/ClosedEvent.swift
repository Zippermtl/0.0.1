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

public class ClosedEvent: Event {
    
    override init() {
        super.init()
    }
    
    override init(event: Event) {
        super.init(event: event)
    }
    
    init(openEvent: OpenEvent) {
        super.init(event: openEvent)
    }
    
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
        return ClosedEventCoder(event: self)
    }
    
    override func getEncoderType() -> EventCoder.Type {
        return ClosedEventCoder.self
    }
    
    override public func getType() -> EventType {
        return .Closed
    }
}

public class ClosedEventCoder: EventCoder {

    init(event: ClosedEvent){
        super.init(event: event)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    public override func createEvent() -> ClosedEvent {
        let event = ClosedEvent()
        updateEvent(event: event)
        print("PRINTING IN CREATE EVENT", event.getType())
        return event
    }
}
