//
//  GeoManager.swift
//  zip_official
//
//  Created by user on 10/17/21.
//

import Foundation
import FirebaseDatabase
import GeoFire

class GeoManager {
    
    static let shared = GeoManager()
        
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

    public func zipfinder(location: CLLocation){
        var list: [User] = []
        print("zipfinder")
        let userID = AppDelegate.userDefaults.value(forKey: "userID")
        let center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let geoRange = Double(10)
        //AppDelegate.userDefaults.value(forKey: "PinkCircle") as! Double
//        let circleQuery = self.geoFire.query(at: center, withRadius: geoRange)
//        _ = circleQuery.observe(.keyEntered, with: { key, location in
//            guard let key = key else { return }
//            print("Key: " + key + "entered the search radius.")
//        })
        let query = self.geoFire.query(at: center, withRadius: geoRange)
        var queryHandle = query.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            list.append(User(userId : key))
            print("added \(key)")
        })
        
        var counter = 0;
        for listUser in list {
            DatabaseManager.shared.loadUserProfile(given: listUser.userId, completion: { [weak self] result in
                switch result {
                case .success(let user):
                    list[counter] = user;
                    counter += 1;
                    print("big succ")
                case .failure(let error):
                    print("big fuck")
                }
                


            })
        }
        // Query location by region
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
