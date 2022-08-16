//
//  GeoManager.swift
//  zip_official
//
//  Created by user on 10/17/21.
//

import Foundation
import FirebaseDatabase
import GeoFire
import CoreLocation

class GeoManager {
    
    static let shared = GeoManager()
        
    var userIdList: [User] = []
    var loadedUsers: [User] = []
    var alreadyReadySeen: [String] = []

    let noUsers = User(userId: "empty")
    var moreUsersInQuery = false
    var queryRunning = false
    var initialLaunch = true
        
    let geofireRef = Database.database().reference().child("geoLocation/")
    var geoFire: GeoFire
    
    let geoFireEventRefPromoter = Database.database().reference().child("geoEvent/Promoter")
    let geoFireEventRefPublic = Database.database().reference().child("geoEvent/Public")
    var geoFireEventPublic: GeoFire
    var geoFireEventPromoter: GeoFire
    
//    var eventIdList: [Event] = []
    var loadedEvent: [Event] = []
    var alreadyReadySeenEvent: [String] = []
    
    var eventRange: Double = 0
    
    init(){
        geoFire = GeoFire(firebaseRef: geofireRef)
        geoFireEventPublic = GeoFire(firebaseRef: geoFireEventRefPublic)
        geoFireEventPromoter = GeoFire(firebaseRef: geoFireEventRefPromoter)
        let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as! [String : [String: String]]
        let helper = DecodeFriendsUserDefaults(raw_friendships)
        for friendship in helper{
            if(friendship.status == .REQUESTED_OUTGOING){
                alreadyReadySeen.append(friendship.receiver.userId)
            } else if(friendship.status == .ACCEPTED){
                alreadyReadySeen.append(friendship.receiver.userId)
            }
        }
    }
    
//    static func safeEmail(email: String) -> String {
//        let safeEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
    public func UpdateEventLocation(event: Event){
        if(event.getType() == EventType.Promoter){
            geoFireEventPromoter.setLocation(CLLocation(latitude: event.coordinates.coordinate.latitude, longitude: event.coordinates.coordinate.longitude), forKey: event.eventId){ (error) in
                if (error != nil) {
                    print("An error occured: \(error)")
                }
            }
        }
        //MARK: no longer applicable saved for later use
//        else if (event.getType() == EventType.Public){
//            geoFireEventPublic.setLocation(CLLocation(latitude: event.coordinates.coordinate.latitude, longitude: event.coordinates.coordinate.longitude), forKey: event.eventId){ (error) in
//                if (error != nil) {
//                    print("An error occured: \(error)")
//                }
//            }
//        }
        //MARK: GABE COME BACK TOO
    }

    public func UpdateLocation(location: CLLocation){
        print("got here")
        guard initialLaunch == true else {
            return
        }
        
        let userID = AppDelegate.userDefaults.value(forKey: "userId")
        geoFire.setLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forKey: userID as! String){ [weak self] error in
            guard error == nil else {
                print("An error occured: \(error)")
                return
            }
            self?.initialLaunch = false
//              Yianni insert a call to whatever happens if location is                    unavailable
        }
        //adds test set to test1 -> test4 inclusive
//        createTestCodeZip()
        DatabaseManager.shared.updateLocationUserLookUp(location: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), completion: { [weak self] err in
            guard err == nil else {
                print("failed to updated self userlookup")
                return
            }
            self?.initialLaunch = false
            
            print("successfully updated self userlookup")
           
        })
    }
    
    public func GetPromoterEventByLocation(location: CLLocation, range: Double, max: Int, completion: @escaping () -> Void){
        let center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if (range < eventRange){
            eventRange = range
            
            let query = self.geoFireEventPromoter.query(at: center, withRadius: range)
            
            query.observe(.keyEntered, with: { [weak self] (key: String!, location: CLLocation!) in
                guard let strongSelf = self else {
                    return
                }
                if(strongSelf.loadedEvent.count > max){
                    query.removeAllObservers()
                }
                strongSelf.eventIsValid(key: key)
            })
        }
    }
//MARK: No longer applicable, saved for later use
//    public func GetPublicEventByLocation(location: CLLocation, range: Double, max: Int, completion: @escaping () -> Void){
//        let center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        if (range < eventRange){
//            eventRange = range
//
//            let query = self.geoFireEventPublic.query(at: center, withRadius: range)
//
//            query.observe(.keyEntered, with: { [weak self] (key: String!, location: CLLocation!) in
//                guard let strongSelf = self else {
//                    return
//                }
//                if(strongSelf.loadedEvent.count > max){
//                    query.removeAllObservers()
//                }
//                strongSelf.eventIsValid(key: key)
//            })
//        }
//    }

    public func eventIsValid(key: String){
        if(!alreadyReadySeenEvent.contains(key)){
            DatabaseManager.shared.loadEvent(event: Event(eventId: key)) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
//                guard strongSelf = self {
//                    return
//                }
                switch result{
                case .success(let event):
                    GeoManager.shared.loadedEvent.append(event)
                    strongSelf.alreadyReadySeenEvent.append(key)
                case .failure(let error):
                    strongSelf.alreadyReadySeenEvent.removeAll(where: { $0 == key})
                    print(error)
                }
                
            }
            
        }
    }
    public func GetUserByLoc(location: CLLocation, range: Double, max: Int, completion: @escaping () -> Void){
        print("Entering GetUserByLoc, range = \(range) max = \(max)")
        let userID = AppDelegate.userDefaults.value(forKey: "userID")
        let center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let geoRange = Double(range)
        //AppDelegate.userDefaults.value(forKey: "PinkCircle") as! Double
//        let circleQuery = self.geoFire.query(at: center, withRadius: geoRange)
//        _ = circleQuery.observe(.keyEntered, with: { key, location in
//            guard let key = key else { return }
//            print("Key: " + key + "entered the search radius.")
//        })
        let query = self.geoFire.query(at: center, withRadius: geoRange)
        queryRunning = true
        query.observe(.keyEntered, with: { [weak self] (key: String!, location: CLLocation!) in
            guard let strongSelf = self else {
                return
            }
            if(strongSelf.userIdList.count > max){
                query.removeAllObservers()
                strongSelf.moreUsersInQuery = true
            }
            if(strongSelf.userIsValid(key: key)){
                GeoManager.shared.userIdList.append(User(userId:key))
                print("userIdList appending \(key.description)")
            }
        })
        var count = 0
        query.observeReady({
            print("All initial data has been loaded and events have been fired! \(count)")
            count += 1
            self.queryRunning = false
            query.removeAllObservers()
            completion()
        })
        
    }
    
    public func userIsValid(key: String) -> Bool{
        for user in userIdList{
            if(user.userId == key){
                print("A user is duplicated")
                return false
            }
        }
        for user in alreadyReadySeen{
            if(user == key){
                print("A user is already seen")
                return false
            }
        }
        if(key == AppDelegate.userDefaults.value(forKey: "userId") as? String){
            return false
        }
        return true
    }
    
    public func LoadNextUsers(size: Int, completion: () -> Void) {//        if(GeoManager.shared.userIdList.isEmpty){
//            let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
//            GeoManager.shared.getUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]))
//        }
        let userSize = GeoManager.shared.userIdList.count
        if(userSize > size){
            GeoManager.shared.LoadUsers(size: size)
//            hasMore = true
            print("userIdList.count = \(GeoManager.shared.userIdList.count)")
        } else {
            GeoManager.shared.LoadUsers(size: userSize)
//            hasMore = false
            print("userIdList.count = \(GeoManager.shared.userIdList.count)")
        }
        print("have data, exiting LoadNextUsers")
        
//        print("before completion of load next users")
//        print(GeoManager.shared.loadedUsers)
        completion()
    }
    
    public func LoadUsers(size: Int){
        print("LoadUsers \(size) with array size \(userIdList.count)")
        for _ in 0..<size{
            DatabaseManager.shared.loadUserProfile(given: userIdList[0], dataCompletion: { [weak self] result in
                switch result {
                case .success(let user):
                    self?.loadedUsers.append(user)
                    print("completed user profile copy for: ")
                    print("copied \(user.username)")
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                }
            }, pictureCompletion: { result in })
            let temp = userIdList[0]
            alreadyReadySeen.append(temp.userId)
            userIdList.remove(at: 0)
        }
        print("exiting loadUsers with loadedUsers: \(loadedUsers.count) and ")

//         Query location by region
//        let span = MKCoordinateSpanMake(0.001, 0.001)
//        let region = MKCoordinateRegionMake(center.coordinate, span)
//        var regionQuery = geoFire.queryWithRegion(region)
    }
//    public func circleQ(center: CLLocation, geoRange: Double) ->  GFCircleQuery {
//
//    }
    
    
}


//public func CreateTestCodeZip(){
//    geoFire.setLocation(CLLocation(latitude: 51.5014, longitude: -0.1419), forKey: "test1-zipper-com"){ error in
//        guard error == nil else {
//            print("error setting location \(error)")
//            return
//        }
//    }
//    geoFire.setLocation(CLLocation(latitude: 51.5313, longitude: -0.1570), forKey: "test2-zipper-com"){ error in
//        if (error != nil) {
//            print("An error occured: \(error)")
////              Yianni insert a call to whatever happens if location is                    unavailable
//        }
//    }
//    geoFire.setLocation(CLLocation(latitude: 51.5013, longitude: -0.2070), forKey: "test3-zipper-com"){ error in
//        if (error != nil) {
//            print("An error occured: \(error)")
////              Yianni insert a call to whatever happens if location is                    unavailable
//        }
//    }
//    geoFire.setLocation(CLLocation(latitude: 51.5013, longitude: -0.5070), forKey: "test4-zipper-com"){ error in
//        if (error != nil) {
//            print("An error occured: \(error)")
////              Yianni insert a call to whatever happens if location is                    unavailable
//        }
//    }
//}
