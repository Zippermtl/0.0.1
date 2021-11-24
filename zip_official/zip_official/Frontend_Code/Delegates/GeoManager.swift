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
        
    var userIdList: [String] = []
    var loadedUsers: [User] = []
    var alreadyReadySeen: [String] = []

    let noUsers = User(userId: "empty")
    var moreUsers = false
    var loading = false
        
    let geofireRef = Database.database().reference().child("geoLocation/")
    var geoFire: GeoFire
    
    init(){
        geoFire = GeoFire(firebaseRef: geofireRef)
    }
    
//    static func safeEmail(email: String) -> String {
//        let safeEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
    

    public func UpdateLocation(location: CLLocation){
        print("got here")

        let userID = AppDelegate.userDefaults.value(forKey: "userId")
        geoFire.setLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forKey: userID as! String){ (error) in
            if (error != nil) {
                print("An error occured: \(error)")
//              Yianni insert a call to whatever happens if location is                    unavailable
            }
        }
        //adds test set to test1 -> test4 inclusive
//        createTestCodeZip()

    }

    public func GetUserByLoc(location: CLLocation, range: Double, max: Int){
        print("zipfinder")
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
        loading = true
        query.observe(.keyEntered, with: { [weak self] (key: String!, location: CLLocation!) in
            guard let strongSelf = self else {
                return
            }
            if(strongSelf.userIdList.count > max){
                query.finalize()
                strongSelf.moreUsers = true
            }
            if(strongSelf.userIsValid(key: key)){
                GeoManager.shared.userIdList.append(key)
                print("added \(key.description)")
            }
        })
        var count = 0
        query.observeReady({
            print("All initial data has been loaded and events have been fired! \(count)")
            count += 1
            self.userIdList.append(self.noUsers.userId)
            self.loading = false
            query.finalize()
        })
    }
    
    public func userIsValid(key: String) -> Bool{
        for user in userIdList{
            if(user == key){
                return false;
            }
        }
        for user in alreadyReadySeen{
            if(user == key){
                return false;
            }
        }
        return true;
    }
    
    public func LoadNextUsers(size: Int) {//        if(GeoManager.shared.userIdList.isEmpty){
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
        print("have data")
    }
    
    public func LoadUsers(size: Int){
        print("loading users \(size)")
        for _ in 0..<size{
            DatabaseManager.shared.loadUserProfile(given: userIdList[0], completion: { [weak self] result in
                switch result {
                case .success(let user):
                    self?.loadedUsers.append(user)
                    print("big succ")
                    print("copied \(user.username)")
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                }
            })
            let temp = userIdList[0];
            alreadyReadySeen.append(temp)
            userIdList.remove(at: 0)
        }
//         Query location by region
//        let span = MKCoordinateSpanMake(0.001, 0.001)
//        let region = MKCoordinateRegionMake(center.coordinate, span)
//        var regionQuery = geoFire.queryWithRegion(region)
    }
//    public func circleQ(center: CLLocation, geoRange: Double) ->  GFCircleQuery {
//
//    }
    
    public func PullNextUser(index: Int) -> User {
        if(loadedUsers.count-index < 5){
            LoadNextUsers(size: 10)
        }
        if(loadedUsers.count-index == 0){
            return noUsers
        }
        return loadedUsers[index]
    }
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
