//
//  RecurringEvent.swift
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

public class RecurringEvent: PromoterEvent {
    //    1var title
    //        var id2
    //       3 var Venue
    //       5 var address
    //      4  var latitude
    //      6  var longitude
    //      7  var category
    //      9  var bio
    //      8  var date
    //     10   var startTime
    //      11  var endTime
    //     12   var phoneNumber
    //      13  var website
    var website: String? = ""
    var category: CategoryType? = .Deal
    var phoneNumber: Int? = -1
    var venu: String? = ""
    var dayOfTheWeek: String = ""
    
    override init() {
        super.init()
    }
    
    init(event: Event, cat: CategoryType?, phoneN: Int?, web: String?, ven: String?, price: Double?, buyTicketsLink: URL?) {
        self.phoneNumber = phoneN
        self.category = cat
        self.website = web
        self.venu = ven
        super.init(event: event, price: price, buyTicketsLink: buyTicketsLink)
        self.allowUserInvites = true
    }
    
    override public func dispatch(user:User) -> Bool {
        return true
    }
    
    init(vals: [String]){
        super.init()
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var toMakeDate = DateComponents()
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        toMakeDate.year = calendarDate.year
        toMakeDate.month = calendarDate.month
        toMakeDate.day = calendarDate.day
        
        guard let lat = Double(vals[4]),
                let long = Double(vals[5]) else {
            print("u done fucked up bad line 59 Recurring Event")
            return
        }
        if vals[11] == "" {
            self.phoneNumber = nil
        } else {
            let phoneNumArray = vals[11].components(separatedBy: "-")
            let phoneNumString = phoneNumArray[0] + phoneNumArray[1] + phoneNumArray[2]
            self.phoneNumber = Int(phoneNumString)
        }
        
        self.dayOfTheWeek = vals[8]
       
            
        let a1 = vals[9].components(separatedBy: ":")
        let b1 = vals[10].components(separatedBy: ":")

        let a = a1.map { Int($0) ?? 0 }
        let b = b1.map { Int($0) ?? 0 }
        toMakeDate.hour = a[0]
        toMakeDate.minute = a[1]
        let stDate = calendar.date(from: toMakeDate as DateComponents)
        self.startTime = stDate! as Date
        toMakeDate.hour = b[0]
        toMakeDate.minute = b[1]
        if (a[0] < b[0]){
            let edDate = calendar.date(from: toMakeDate as DateComponents)
            self.endTime = edDate! as Date
        } else {
            toMakeDate.day = (calendarDate.day!) + 1
            let edDate = calendar.date(from: toMakeDate as DateComponents)
            self.endTime = edDate! as Date
        }
        self.title = vals[0]
        self.eventId = vals[1]
        self.venu = vals[2]
        self.address = vals[3]
        self.coordinates = CLLocation(latitude: lat, longitude: long)
        self.category = CategoryType(rawValue: vals[0])
        self.bio = vals[7]
//        self.endTime = vals[10]
        self.website = vals[12]
        
    }
    
//    public func dayOfTheWeak() -> String? {
//        return startTime.dayOfWeek()
//    }
    
    override public func getType() -> EventType {
        return .Recurring
    }
}
