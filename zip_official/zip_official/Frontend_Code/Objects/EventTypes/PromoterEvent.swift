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
    
    override func getParticipants() -> [CellSectionData] {
        let sections = [hostingSection, goingSection, notGoingSection]
        return sections
    }
}
