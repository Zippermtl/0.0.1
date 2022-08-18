//
//  SearchObject.swift
//  zip_official
//
//  Created by user on 8/18/22.
//
import Foundation
//import MapKit
//import FirebaseFirestore

class SearchObject : Equatable{
    static func == (lhs: SearchObject, rhs: SearchObject) -> Bool {
        return lhs.getId() == rhs.getId()
    }
    
    var user: User? = nil
    var event: Event? = nil
    //type -1 is error 0 is user 1 is event
    var type: Int = -1
    
    init(_ user: User?){
        self.user = user
        self.type = 0
    }
    
    init(_ event: Event?){
        self.event = event
        self.type = 1
    }
    
    public func isEvent() -> Bool{
        if(self.type == 1){
            return true
        }
        return false
    }
   
    public func isUser() -> Bool{
        if(self.type == 0){
            return true
        }
        return false
    }
    
    public func getId() -> String {
        if self.isEvent() {
            guard let id = self.event?.eventId else {
                return ""
            }
            return id
        }
        if self.isUser() {
            guard let id = self.user?.userId else {
                return ""
            }
            return id
        }
        return ""
    }
    
    
    
}
