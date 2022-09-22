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
    var loadedUsers: [String:User] = [:]
    var alreadyReadySeen: [String] = []
    var userLocDict: [String:CLLocation] = [:]
    var limitUsers: [String] = []

    let noUsers = User(userId: "empty")
    var moreUsersInQuery = false
    var queryRunning = false
    var initialLaunch = true
    var hasMaxRange = true
    var blockFutureQueries = false
    
    var reloadFromForceChange = false
        
    let geofireRef = Database.database().reference().child("geoLocation/")
    var geoFire: GeoFire
    
    let geoFireEventRefPromoter = Database.database().reference().child("geoEvent/Promoter")
    let geoFireEventRefPublic = Database.database().reference().child("geoEvent/Public")
    var geoFireEventPublic: GeoFire
    var geoFireEventPromoter: GeoFire
    
//    var eventIdList: [Event] = []
    var loadedEvent: [Event] = []
    var alreadyReadySeenEvent: [String] = []
    
    public var presentRange = Double(5)
    public var rangeMultiplier = Double(1)
    public var maxRangeFilter = (AppDelegate.userDefaults.value(forKey: "maxRangeFilter") as? Double) ?? 100
    public var maxRange : Double {
        return Double(maxRangeFilter * rangeMultiplier)
    }
    var eventRange: Double = 0
    
    var filtersChanged = false
    
    init(){
        geoFire = GeoFire(firebaseRef: geofireRef)
        geoFireEventPublic = GeoFire(firebaseRef: geoFireEventRefPublic)
        geoFireEventPromoter = GeoFire(firebaseRef: geoFireEventRefPromoter)
        let blocked = (AppDelegate.userDefaults.value(forKey: "blockedUsers") as? [String]) ?? []
        alreadyReadySeen.append(contentsOf: blocked)
        let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String : [String: String]] ?? [:]
        let helper = DecodeFriendsUserDefaults(raw_friendships)
        for friendship in helper{
            if(friendship.status == .REQUESTED_OUTGOING){
                alreadyReadySeen.append(friendship.receiver.userId)
            } else if(friendship.status == .ACCEPTED){
                alreadyReadySeen.append(friendship.receiver.userId)
            }
        }
        print("LOOK HERE FOR USERS")
        print(alreadyReadySeen.count)
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
    
    public func matchesFilters(user: User) -> Bool{
//        “MaxRangeFilter” - distance in km/miles - you’ll need to multiply by whatever to make it meters
//        “MinAgeFilter” - int
//        “MaxAgeFilter” - int
//        “genderFilter” - 0 (men), 1 (women), 2 (everyone)
        var monitor = true
        let minAgeFilter = AppDelegate.userDefaults.value(forKey: "MinAgeFilter") as? Int ?? 0
        let maxAgeFilter = AppDelegate.userDefaults.value(forKey: "MaxAgeFilter") as? Int ?? 1000
        let genderFilter = AppDelegate.userDefaults.value(forKey: "genderFilter") as? Int ?? 2
        let blockedUsers = AppDelegate.userDefaults.value(forKey: "blockedUsers") as? [String] ?? []
        let b = user.blockedUsers
        if b != [] {
            if b.contains(AppDelegate.userDefaults.value(forKey: "userId") as! String) {
                monitor = false
                print("blocked by \(user.userId)")
            }
        }
        if limitUsers.contains(user.userId){
            monitor = false
        }
        
        if blockedUsers.contains(user.userId){
            monitor = false
            print("u blocked them")
        }
        switch genderFilter{
        case 0:
            if (user.gender != "M"){
                monitor = false
            }
        case 1:
            if (user.gender != "W"){
                monitor = false
            }
        default:
            print("no execution statement")
        }
        if(minAgeFilter > user.age || user.age > maxAgeFilter){
            monitor = false
        }
        if(user.Zfpref == .HideProfile){
            monitor = false
        }
        return monitor
    }
    
    public func checkMatchesByString(Id: String) -> Bool{
        if let load = loadedUsers[Id] {
            if(matchesFilters(user: load)){
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    public func addUsersToLoadedIfFitModel(user: User) -> Bool{
        let u = user
        print("Geomanager 137 enter")
        if let loc = userIdList.firstIndex(of: u) {
            let localLoc = userIdList[loc].location
            u.location = localLoc
            loadedUsers[u.userId] = u
            userIdList.remove(at: loc)
            if (matchesFilters(user: user)) {
                return true
            }
            return false
        } else {
            print("Geomanager error 148 for addUser")
            return false
        }
    }

    
    public func GetUserByLoc(location: CLLocation, range: Double?, max: Int, completion: @escaping () -> Void){
        queryRunning = true
        let geoRange = (range ?? presentRange)
        let userID = AppDelegate.userDefaults.value(forKey: "userID")
        //MARK: Actual Location
//        var lat = location.coordinate.latitude
//        var long = location.coordinate.longitude
//        let center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //MARK: Vanderbilt Campus
//        let center = CLLocation(latitude: 36.144051, longitude: -86.800949)
//        Latitude: 31.2198 Longitude: 121.4870
        //MARK: Shanghai (no users nearby edge case)
//        let center = CLLocation(latitude: 31.2198, longitude: 121.4870)
//    Latitude: 45.5041 Longitude: -73.5747
        //MARK: McGuille Campus
        let center = CLLocation(latitude: 45.5041, longitude: -73.5747)
        print("Entering GetUserByLoc, range = \(geoRange) max = \(max)")

//        let geoRange = Double(locRange)
//        center =
       //AppDelegate.userDefaults.value(forKey: "PinkCircle") as! Double
//        let circleQuery = self.geoFire.query(at: center, withRadius: geoRange)
//        _ = circleQuery.observe(.keyEntered, with: { key, location in
//            guard let key = key else { return }
//            print("Key: " + key + "entered the search radius.")
//        })
        let query = self.geoFire.query(at: center, withRadius: geoRange)
        query.observe(.keyEntered, with: { [weak self] (key: String!, location: CLLocation!) in
            guard let strongSelf = self else {
                return
            }
            if(strongSelf.userIdList.count > max){
                query.removeAllObservers()
                strongSelf.moreUsersInQuery = true
            } else {
                strongSelf.moreUsersInQuery = false
            }
            let user = User(userId: key)
            user.location = location
            if(strongSelf.userIsValid(checkUser: user)){
                GeoManager.shared.userIdList.append(user)
                if(strongSelf.userLocDict[key] == nil){
                    strongSelf.userLocDict[key] = location
                }
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
          
    public func userIsValid(checkUser: User) -> Bool{
        for user in userIdList{
            if(user.userId == checkUser.userId){
                print("A user is duplicated")
                return false
            }
        }
        for user in alreadyReadySeen{
            if(user == checkUser.userId){
                print("A user is already seen")
                return false
            }
        }
        if(checkUser.userId == AppDelegate.userDefaults.value(forKey: "userId") as? String){
            return false
        }
        return true
    }
    
    public func forceAddUser(user: User){
        if (loadedUsers[user.userId] == nil){
            if(!alreadyReadySeen.contains(user.userId)){
                alreadyReadySeen.append(user.userId)
            }
            loadedUsers[user.userId] = user
            reloadFromForceChange = true
        }
    }
    
    public func addedOrBlockedUser(user: User){
        loadedUsers.removeValue(forKey: user.userId)
        if (!alreadyReadySeen.contains(user.userId)){
            alreadyReadySeen.append(user.userId)
        }
        limitUsers.append(user.userId)
        reloadFromForceChange = true
    }
    
    public func LoadUsers(size: Int, completion: @escaping (Result<String, Error>) -> Void, updateCompletion: @escaping (String) -> Void) {
        let userSize = GeoManager.shared.userIdList.count
        if(userSize > size){
            var dataholder: [User] = []
            for j in 0..<size{
                dataholder.append(userIdList[j])
            }
            for i in dataholder {
                let tmp = i
                DatabaseManager.shared.loadUserProfile(given: i, dataCompletion: {[weak self] res in
                    guard let strongSelf = self else {
                        return
                    }
                    switch res{
                    case .success(let u):
                        if(strongSelf.addUsersToLoadedIfFitModel(user: u)) {
                            completion(.success(u.userId))
                        }
                    case .failure(let err):
                        completion(.failure(err))
                    }
//                }, profilePictureCompletion: { _ in
//                    // nothing needed
                }, pictureCompletion: { [weak self] res in
                    guard let strongSelf = self else {
                        return
                    }
                    var temp = strongSelf.userIdList.firstIndex(of: i)
                    guard temp != nil else {
                        return
                    }
                    updateCompletion(strongSelf.userIdList[temp!].userId)
                })
            }
        } else {
            for i in userIdList {
                let tmp = userIdList.firstIndex(of: i)
                guard tmp != nil else {
                    return
                }
                let Uid = userIdList[tmp!].userId
                DatabaseManager.shared.loadUserProfile(given: i, dataCompletion: { [weak self] res in
                    guard let strongSelf = self else {
                        return
                    }
                    switch res{
                    case .success(let u):
                        if(strongSelf.addUsersToLoadedIfFitModel(user: u)) {
                            completion(.success(u.userId))
                        }
                    case .failure(let err):
                        completion(.failure(err))
                        
                    }
                }, pictureCompletion: { [weak self] res in
                    guard let strongSelf = self else {
                        return
                    }
                    updateCompletion(Uid)
                })
            }
        }
        print("have data, exiting LoadNextUsers")
        
//        print("before completion of load next users")
//        print(GeoManager.shared.loadedUsers)
//        completion()
    }
    
//    public func getPossiblePresentNumberOfCells() -> Int {
//        return loadedUsers.count + userIdList.count
//    }
    
    public func getNumberOfCells() -> Int {
        let temp = getFilteredData()
        return temp.count
    }
    
    public func needsReload(maxIndex: Int, isInfite: Bool) -> Bool{
        if(maxIndex >= getFilteredData().count && !isInfite){
            return true
        }
        if(reloadFromForceChange){
            reloadFromForceChange = false
//            return true
        }
        return false
    }
    
    public func needsReload(presIndex: Int, maxIndices: Int, Incompletion: Bool, isInfinite: Bool) -> Bool{
        if Incompletion {
            var a = userIdList.count
            if a > 5 {
                a = 5
            }
            if(presIndex+5 >= getFilteredData().count){
                if(isInfinite){
                    return false
                }
                return true
            }
//            else if (!isInfinite){
//                return true
//            }
        }
        if(reloadFromForceChange){
            reloadFromForceChange = false
//            return true
        }
        return false
    }
    
    public func needsNewUsers(maxIndex: Int, isConstant: Bool, completion: @escaping () -> Void) -> Bool{
        if (loadedUsers.count-5 > maxIndex) {
            if(userIdList.count < 10 && queryRunning == false){
                let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] ?? [31.2198,121.4870]
                if(moreUsersInQuery){
                    GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: presentRange, max: 100, completion: {
                        completion()
                    })
                } else if(presentRange < maxRange){
                    presentRange += 5*rangeMultiplier
                    GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: presentRange, max: 100, completion: {
                        completion()
                    })
                }
            }
            return true
        }
        return false
    }
    
    public func getFilteredData() -> [User]{
        var returns: [User] = []
        for (k,i) in loadedUsers {
            if(matchesFilters(user: i)){
                returns.append(i)
            }
        }
        return returns
    }
    
    public func setMaxRangeFilter(val: Double?){
        if(val != nil){
            maxRangeFilter = val!
        } else {
            guard let max = AppDelegate.userDefaults.value(forKey: "MaxRangeFilter") as? Double else {
                AppDelegate.userDefaults.set(Double(100), forKey: "MaxRangeFilter")
                print("Yianni this a placeholder patch fix it")
                maxRangeFilter = 100
                return
            }
            maxRangeFilter = max
        }
//        AppDelegate.userDefaults.set(val, forKey: "MaxRangeFilter")
//        maxRangeFilter = val
    }
    
    public func setRangeMultiplier(val: Double = 0){
        if(val == 0){
            if NSLocale.current.regionCode == "US" {
                rangeMultiplier = 1.6
            } else {
                rangeMultiplier = 1
            }
        } else {
            rangeMultiplier = val
        }
        
    }
    
    public func isLoadedUserMatchFilter(Id: String) -> Bool {
        if let load = loadedUsers[Id] {
            return matchesFilters(user: load)
        }
        return false
    }
//    public func LoadUsers(size: Int){
//        print("LoadUsers \(size) with array size \(userIdList.count)")
//        for _ in 0..<size{
//            DatabaseManager.shared.loadUserProfile(given: userIdList[0], dataCompletion: { [weak self] result in
//                switch result {
//                case .success(let user):
//                    if let userlocation = self?.userLocDict[user.userId] {
//                        user.location = userlocation
//                    }
//
//                    self?.loadedUsers.append(user)
//                    print("completed user profile copy for: ")
//                    print("copied \(user.username)")
//                case .failure(let error):
//                    print("error load in LoadUser -> LoadUserProfile \(error)")
//                }
//            }, pictureCompletion: { result in })
//            let temp = userIdList[0]
//            alreadyReadySeen.append(temp.userId)
//            userIdList.remove(at: 0)
//        }
//        print("exiting loadUsers with loadedUsers: \(loadedUsers.count) and ")
//
////         Query location by region
////        let span = MKCoordinateSpanMake(0.001, 0.001)
////        let region = MKCoordinateRegionMake(center.coordinate, span)
////        var regionQuery = geoFire.queryWithRegion(region)
//    }
//    public func circleQ(center: CLLocation, geoRange: Double) ->  GFCircleQuery {
//
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
    
    public func eventIsValid(event: Event) -> Bool{
        if(!alreadyReadySeenEvent.contains(event.eventId)){
            return true
                
        } else{
            return false
        }
    }
    
    public func GetPromoterEventByLocation(location: CLLocation, range: Double, max: Int = Int(UInt64.max), autoLoad: Bool = true, completion: @escaping (Event) -> Void){
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
                let event = Event(eventId: key)
                event.coordinates = location
                let valid = strongSelf.eventIsValid(event: event)
                if(valid){
                    if(autoLoad){
                        DatabaseManager.shared.loadEvent(event: event, completion: { [weak self] result in
                            guard let strongSelf = self else {
                                return
                            }
            //                guard strongSelf = self {
            //                    return
            //                }
                            switch result{
                            case .success(let eventfull):
//                                GeoManager.shared.loadedEvent.append(event)
                                strongSelf.alreadyReadySeenEvent.append(eventfull.eventId)
                                completion(eventfull)
                            case .failure(let error):
                                strongSelf.alreadyReadySeenEvent.removeAll(where: { $0 == event.eventId})
                                print(error)
                            }
                        })
                    } else {
                        completion(event)
                    }
                }
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
