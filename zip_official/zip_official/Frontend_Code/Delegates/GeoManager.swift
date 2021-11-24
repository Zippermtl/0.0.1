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
        
    var ZFUlist: [User] = []
    var alreadyReadySeen: [User] = []

    
    let geofireRef = Database.database().reference().child("geoLocation/")
    var geoFire: GeoFire
    
    init(){
        geoFire = GeoFire(firebaseRef: geofireRef)
    }
    
//    static func safeEmail(email: String) -> String {
//        let safeEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
    

    public func updateLocation(location: CLLocation){
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

    public func getUserByLoc(location: CLLocation, range: Int){
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
        var queryHandle = query.observe(.keyEntered, with: { [self] (key: String!, location: CLLocation!) in
            if(ZFUlist.count > 100){
                query.finalize()
            }
            if(userIsValid(key: key)){
                GeoManager.shared.ZFUlist.append(User(userId : key))
                print("added \(key)")
            }
        })
        query.observeReady({
            print("All initial data has been loaded and events have been fired!")
            query.finalize()
        })
    }
    
    public func userIsValid(key: String) -> Bool{
        for user in ZFUlist{
            if(user.userId == key){
                return false;
            }
        }
        return true;
    }
    
    public func loadNextUsers() -> [User]{
        var data: [User] = []
//        if(GeoManager.shared.ZFUlist.isEmpty){
//            let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
//            GeoManager.shared.getUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]))
//        }
        let userSize = GeoManager.shared.ZFUlist.count
        if(userSize > 10){
            data = GeoManager.shared.loadUsers(size: 10)
//            hasMore = true
            print(GeoManager.shared.ZFUlist.count)
        } else {
            data = GeoManager.shared.loadUsers(size: userSize)
//            hasMore = false
            print(GeoManager.shared.ZFUlist.count)
        }
        print("have data")
        return data
    }
    
    public func loadUsers(size: Int) -> [User]{
        var listUser: [User] = []
        print("loading users \(size)")
        for i in 0..<size{
            DatabaseManager.shared.loadUserProfile(given: ZFUlist[0].userId, completion: { [weak self] result in
                switch result {
                case .success(let user):
                    listUser.append(user)
                    print("big succ")
                    print("copied \(user.username)")
                case .failure(let error):
                    print("big fuck")
                }
            })
            var temp = ZFUlist[0];
            alreadyReadySeen.append(temp)
            ZFUlist.remove(at: 0)
        }
        return listUser
//         Query location by region
//        let span = MKCoordinateSpanMake(0.001, 0.001)
//        let region = MKCoordinateRegionMake(center.coordinate, span)
//        var regionQuery = geoFire.queryWithRegion(region)
    }
//    public func circleQ(center: CLLocation, geoRange: Double) ->  GFCircleQuery {
//
//    }
    public func createTestCodeZip(){
        geoFire.setLocation(CLLocation(latitude: 51.5014, longitude: -0.1419), forKey: "test1-zipper-com"){ (error) in
            if (error != nil) {
                print("An error occured: \(error)")
//              Yianni insert a call to whatever happens if location is                    unavailable
            }
        }
        geoFire.setLocation(CLLocation(latitude: 51.5313, longitude: -0.1570), forKey: "test2-zipper-com"){ (error) in
            if (error != nil) {
                print("An error occured: \(error)")
//              Yianni insert a call to whatever happens if location is                    unavailable
            }
        }
        geoFire.setLocation(CLLocation(latitude: 51.5013, longitude: -0.2070), forKey: "test3-zipper-com"){ (error) in
            if (error != nil) {
                print("An error occured: \(error)")
//              Yianni insert a call to whatever happens if location is                    unavailable
            }
        }
        geoFire.setLocation(CLLocation(latitude: 51.5013, longitude: -0.5070), forKey: "test4-zipper-com"){ (error) in
            if (error != nil) {
                print("An error occured: \(error)")
//              Yianni insert a call to whatever happens if location is                    unavailable
            }
        }
    }
}
