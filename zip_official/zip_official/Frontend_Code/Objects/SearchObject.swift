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
//    var ss: String = ""
    
    public func getUrl() -> URL?{
        guard self.type != -1 else {
            return nil
        }
        if(isEvent()){
            guard let url = self.event?.imageUrl  else {
                return nil
            }
            return url
        } else if (isUser()){
            guard let url = self.user?.profilePicUrl  else {
                return nil
            }
            return url
        } else {
            return nil
        }
    }
    
    public func setUrl(url: URL) -> Error? {
        guard self.type != -1 else {
            return nil
        }
//        let abcdurl = url
        if(isEvent()){
//            print("isEvent")
//            guard let local = self.event else {
//                return SearchObjectError.SearchObjectInvalidIndexing
//            }
                event?.imageUrl = url
                return nil
        } else if (isUser()){
//            print("isUser")
//            guard let local = self.user else {
//                return SearchObjectError.SearchObjectInvalidIndexing
//            }
//            print(url.absoluteString)
            user?.profilePicUrl = url
            return nil
        } else {
            return nil
        }
    }
    
//    var pictureUrls : [URL] = {
//        if (self.isUser()){
//            return user?.pictureURLs
//        } else if (self.isEvent()){
//            
//        }
//    }
    
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
    
    var cellItem: CellItem {
        if isUser() {
            return user ?? User()
        } else {
            return event ?? Event()
        }
    }
    
    
}
