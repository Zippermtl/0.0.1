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
    
    enum SearchObjectError: Error {
        case SearchObjectInvalidIndexing
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
    
    public func getSearch() -> [String] {
        var hold: [String] = []
        if self.isEvent() {
            guard let id = self.event?.title.lowercased() else {
                return []
            }
            hold.append(id)
        }
        if self.isUser() {
            guard let username = self.user?.username else {
                return []
            }
            guard let fullname = self.user?.fullName else {
                return []
            }
            hold.append(username)
            hold.append(fullname)
        }
        return hold
    }
    
}
