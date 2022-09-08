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

public class UserEvent: Event {
    var type: EventType
    
    
    init(type: EventType) {
        self.type = type
        super.init()
    }
    
    init(event: Event, type: EventType) {
        self.type = type
        super.init(event: event)
    }
    
    override init() {
        type = .Closed
        super.init()
    }
    
    override init(event: Event) {
        self.type = event.getType()
        super.init(event: event)
    }
    
    override public func dispatch(user:User) -> Bool {
        if (usersGoing.count < maxGuests){
            return true
        }
        return false
    }
    
    public override func getType() -> EventType {
        return type
    }
}
