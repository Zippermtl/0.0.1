//
//  Users.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//
import Foundation
import MapKit
import FirebaseFirestore



public typealias NotificationPreference = [NotificationSubtype: Bool]

class UserCoder: Codable {
    var userId: String
    var username: String
    var firstName: String
    var lastName: String
    var birthday: Timestamp
    var picNum: Int
    var bio: String
    var interests: [Interests]
    var deviceId: [String]
    var notificationToken: [String]
    var school: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case username = "username"
        case firstName = "firstName"
        case lastName = "lastName"
        case birthday = "birthday"
        case picNum = "picNum"
        case bio = "bio"
        case school = "school"
        case interests = "interests"
        case deviceId = "deviceId"
        case notificationToken = "notificationToken"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.username = try container.decode(String.self, forKey: .username)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.picNum = try container.decode(Int.self, forKey: .picNum)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.school = try container.decode(String.self, forKey: .school)
        self.interests = try container.decode([Interests].self, forKey: .interests)
        self.birthday = try container.decode(Timestamp.self, forKey: .birthday)
        self.school = try container.decode(String.self, forKey: .school)
        self.deviceId = try container.decode([String].self, forKey: .deviceId)
        self.notificationToken = try container.decode([String].self, forKey: .notificationToken)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(birthday, forKey: .picNum)
        try container.encode(bio, forKey: .bio)
        try container.encode(picNum, forKey: .picNum)
        try container.encode(school, forKey: .school)
        try container.encode(interests, forKey: .interests)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(notificationToken, forKey: .notificationToken)
    }
    
    
    public func createUser() -> User{
        return User(
            userId: userId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            birthday: birthday.dateValue(),
            picNum: picNum,
            bio: bio,
            school: school,
            interests: interests,
            notifToken: notificationToken[0]
        )
    }
    
    public func updateUser(_ user: User) {
        user.userId = userId
        user.username = username
        user.firstName = firstName
        user.lastName = lastName
        user.birthday = birthday.dateValue()
        user.picNum = picNum
        user.bio = bio
        user.school = school
        user.interests = interests
    }

}

public class User : CustomStringConvertible, Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var userId: String = ""
    var username: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var birthday: Date = Date()
    var picNum: Int = 0
    var bio: String = ""
    var school: String?
    var interests: [Interests] = []
    var friendships: [Friendship] = []
    var notificationPreferences: NotificationPreference = [:]
    var deviceId: String = ""
    var notificationToken: String = ""
    
    var email: String?
    var friendshipStatus: FriendshipStatus?
    
    var location: CLLocation = CLLocation()
    var pictures: [UIImage] = []
    var pictureURLs: [URL] = []
    var previousEvents: [Event] = []
    var goingEvents: [Event] = []
    
    var tableViewCell: AbstractUserTableViewCell? 

    public var description : String {
        var out = ""
        out += "userId = \(userId) \n"
        out += "username = \(username) \n"
        out += "firstname = \(firstName) \n"
        out += "lastname = \(lastName) \n"
        out += "birthday = \(birthdayString) \n"
        out += "picnum = \(picNum) \n"
        out += "bio = \(bio) \n"
        out += "school = \(school ?? "") \n"
        out += "interests = \(interests) \n"
        return out

    }
    
    var joinDate = Date()
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
    }

    var profilePicUrl : URL {
        return pictureURLs[0]
    }
    
    var otherPictureUrls: [URL] {
        if pictureURLs.count > 1 {
            return Array(pictureURLs[1 ..< pictureURLs.count])
        }
        return []
    }
    
    var otherPicNum: Int {
        return picNum-1
    }

    func getDistance() -> Double {
        guard let coordinates = UserDefaults.standard.object(forKey: "userLoc") as? [Double] else {
            return -1.0
        }
        let userLoc = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        
        return userLoc.distance(from: location)
    }
    
    func getDistanceString() -> String {
        var distanceText = ""
        var unit = "km"
        var distance = Double(round(10*(getDistance())/1000))/10

        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
        }
        
        if distance > 10 {
            let intDistance = Int(distance)
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceText = "<1 \(unit)"
            } else if distance >= 500 {
                distanceText = ">500 \(unit)"
            } else {
                distanceText = String(intDistance) + " \(unit)"
            }
        } else {
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceText = "<1 \(unit)"
            } else if distance >= 500 {
                distanceText = ">500 \(unit)"
            } else {
                distanceText = String(distance) + " \(unit)"
            }
        }
        
        return distanceText
    }
    
    var safeId: String {
        var safeID = userId.replacingOccurrences(of: ".", with: "-")
        safeID = safeID.replacingOccurrences(of: "@", with: "-")
        return safeID
    }
    
    var picturesPath: String {
        return "images/\(safeId)/"
    }
    
    var profilePictureFileName: String {
        return "\(safeId)/profile_picture.png"
    }
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    var birthdayString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: birthday)
    }
    
    var interestsString: String {
        return interests.map{$0.description}.joined(separator: ", ")
    }
    
    var numTableviewCells: Int {
        var out = 0
        if bio != "" { out+=1 }
        if school != "" { out+=1 }
        if interests != [] { out+=1 }
        return out
    }
    
    var hasBio: Bool { return bio != ""}
    var hasSchool: Bool { return school != nil}
    var hasInterests: Bool { return interests != []}

    var isInivted: Bool = false

    init() {}
    
    init(userId id: String) {
        userId = id
    }

    // Gets you, magnificent and great user
    static func getCurrentUser() -> User {
        return AppDelegate.userDefaults.value(forKey: "userId") as! User
    }

//    init(userId id: String, username us: String, firstName fn: String, lastName ln: String) {
//        userId = id
//        username = us
//        firstName = fn
//        lastName = ln
//    }
//    init(email id: String, username us: String, firstName fn: String, lastName ln: String, birthday bd: Date, location pn: CLLocation, bio b: String, school sc: String?, interests inters: [Interests]) {
//        email = id
//        username = us
//        firstName = fn
//        lastName = ln
//        birthday = bd
//        location = pn
//        bio = b
//        school = sc
//        interests = inters
//    }
//
//    init(userId id: String, username us: String, firstName fn: String, lastName ln: String, birthday bd: Date, picNum pn: Int, bio b: String, school sc: String?, interests inters: [Interests]) {
//        userId = id
//        username = us
//        firstName = fn
//        lastName = ln
//        birthday = bd
//        picNum = pn
//        bio = b
//        school = sc
//        interests = inters
//    }

    init(userId id: String, username us: String, firstName fn: String, lastName ln: String, birthday bd: Date, picNum pn: Int, bio b: String, school sc: String?, interests inters: [Interests], notificationPreferences np: Int?) {
        userId = id
        username = us
        firstName = fn
        lastName = ln
        birthday = bd
        picNum = pn
        bio = b
        school = sc
        interests = inters
        notificationPreferences = DecodePreferences(np)
    }

    init(userId id: String = "", email em: String = "", username us: String = "", firstName fn: String = "", lastName ln: String = "", birthday bd: Date = Date(), location loc: CLLocation = CLLocation(latitude: 0, longitude: 0), picNum pn: Int = 0, pictures pics: [UIImage] = [], pictureURLs picurls: [URL] = [], bio b: String = "", school sc: String? = "", interests inters: [Interests] = [], previousEvents preve: [Event] = [], goingEvents goinge: [Event] = [], notificationPreferences np: NotificationPreference = [:], encodedNotifPref enp: Int? = 0, deviceId devId: String = "", notifToken: String = "") {
        userId = id
        email = em
        username = us
        firstName = fn
        lastName = ln
        birthday = bd
        location = loc
        picNum = pn
        pictures = pics
        pictureURLs = picurls
        bio = b
        school = sc
        interests = inters
        previousEvents = preve
        goingEvents = goinge
        if (enp == 0){
            notificationPreferences = np
        } else {
            notificationPreferences = DecodePreferences(enp)
        }
        deviceId = devId
        notificationToken = notifToken
    }

    // Load someone's friendships
    func loadFriendships(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.loadUserFriendships(given: userId, completion: { result in
            switch result {
                case .success(let f):
                    self.friendships.removeAll()
                    for friendship in f {
                        self.friendships.append(friendship)
                    }
                    completion(nil)

                case .failure(let error):
                    completion(error)
                    print("Error loading friends")
            }
        })
    }
    
    func report(reason: String) {
//        let smtpSession = MCOSMTPSession()
//        smtpSession.hostname = "smtp.gmail.com"
//        smtpSession.username = "contact.zippermtl@gmail.com"
//        smtpSession.password = "PASSWORD_INSERT_HERE"
//        smtpSession.port = 465
//        smtpSession.authType = MCOAuthType.saslPlain
//        smtpSession.connectionType = MCOConnectionType.TLS
//        smtpSession.connectionLogger = {(connectionID, type, data) in
//            if data != nil {
//                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
//                    NSLog("Connectionlogger: \(string)")
//                }
//            }
//        }
//
//        let builder = MCOMessageBuilder()
//        builder.header.to = [MCOAddress(displayName: "Zipper MTL", mailbox: "contact.zippermtl@gmail.com")!]
//        builder.header.from = MCOAddress(displayName: "Zipper App", mailbox: "contact.zippermtl@gmail.com")
//        builder.header.subject = "User Report"
//        builder.htmlBody = "<p><b>\(userId)</b> was reported!</p><p>Reason: \(reason).</p>"
//
//        let rfc822Data = builder.data()
//        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
//        sendOperation!.start {(error) -> Void in
//            if (error != nil) {
//                NSLog("Error sending email: \(String(describing: error))")
//            } else {
//                NSLog("Successfully sent email!")
//            }
//        }
    }

    // Load your own friendships
    static func loadFriendships(completion: @escaping (Error?) -> Void) {
        User.getCurrentUser().loadFriendships(completion: {result in completion(result)})
    }
    
    /* UN NEEDED FUNCTIONS - SHOULD BE UDPATING FOR EVERY FRIENDSHIP CHANGE ANYWAY
    // Update someone's friendships
    func updateFriendships(completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.updateUserFriendships(of: self, completion: {result in completion(result)})
    }
    
    // Update your own friendships
    static func updateFriendships(completion: @escaping (Bool) -> Void) {
        User.getCurrentUser().updateFriendships(completion: {result in completion(result)})
    }
     */
    
    // Get someone's friend's list
    func getFriendsList(completion: @escaping (Result<[User],Error>) -> Void) {
        loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard let strongSelf = self else {
                return
            }

            var friends: [User] = []
            for friendship in strongSelf.friendships {
                switch friendship.status {
                    case.ACCEPTED: friends.append(friendship.receiver)
                    default: continue
                }
            }
            completion(.success(friends))
        })
    }

    // Get your own friends list
    static func getFriendsList(completion: @escaping (Result<[User],Error>) -> Void) {
        return User.getCurrentUser().getFriendsList(completion: {result in completion(result)})
    }

    // Get someone's incoming requests
    func getIncomingRequests(completion: @escaping (Result<[ZipRequest],Error>) -> Void) {
        loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let strongSelf = self else {
                return
            }

            var requests: [ZipRequest] = []
            for friendship in strongSelf.friendships {
                switch friendship.status {
                case .REQUESTED_INCOMING:
                    print("Friendship receiver = \(friendship.receiver)")
                    let notif = ZipRequest(fromUser: friendship.receiver, time: 10)
                    requests.append(notif)
                default: continue
                }
            }

            completion(.success(requests))
        })
    }
    
    // Get your own incoming requests
    static func getIncomingRequests(completion: @escaping (Result<[ZipRequest],Error>) -> Void) {
        User.getCurrentUser().getIncomingRequests(completion: {result in completion(result)})
    }
    
    // Get someone's outgoing requests
    func getOutgoingRequests(completion: @escaping (Result<[User],Error>) -> Void) {
        loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            var friends: [User] = []
            for friendship in strongSelf.friendships {
                switch friendship.status {
                    case.REQUESTED_OUTGOING: friends.append(friendship.receiver)
                    default: continue
                }
            }

            completion(.success(friends))
        })
    }

    // Get your own outgoing requests
    static func getOutgoingRequests(completion: @escaping (Result<[User],Error>) -> Void) {
        User.getCurrentUser().getOutgoingRequests(completion: {result in completion(result)})
    }

    func unsendRequest(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.unsendRequest(user: self) {  [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = nil
            selfFriendships.removeValue(forKey: strongSelf.userId)
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)
        }
    }
    
    // Requests a friend
    func sendRequest(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.sendRequest(user: self) {  [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = .REQUESTED_OUTGOING
            selfFriendships[strongSelf.userId] = strongSelf.friendshipStatus!.rawValue
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)

        }
    }

    // Accepts a friend (who made a friend request)
    func acceptRequest(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.acceptRequest(user: self) { [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = .ACCEPTED
            selfFriendships[strongSelf.userId] = strongSelf.friendshipStatus!.rawValue
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)
        }
    
    }

    // Rejects a friend (who made a friend request)
    func rejectRequest(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.rejectRequest(user: self) { [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = nil
            selfFriendships.removeValue(forKey: strongSelf.userId)
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)

        }
    }
    
    func unfriend(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.unfriend(user: self) {  [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = nil
            selfFriendships.removeValue(forKey: strongSelf.userId)
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)

        }
    }
    

   
    
    func updateUser(email em: String = "",
                    username us: String = "",
                    firstName fn: String = "",
                    lastName ln: String = "",
                    distance dis: Double = 0,
                    birthday bd: Date = Date(),
                    picNum pn: Int = 0, pictures pics: [UIImage] = [],
                    pictureURLs picurls: [URL] = [],
                    bio b: String = "",
                    school sc: String? = "",
                    interests inters: [Interests] = [],
                    previousEvents preve: [Event] = [],
                    goingEvents goinge: [Event] = [],
                    notificationPreferences np: NotificationPreference = [:],
                    encodedNotifPref enp: Int? = 0){
        
        if (em != "") {
            email = em
        }
        if (us != "") {
            username = us
        }
        if (fn != "") {
            firstName = fn
        }
        if (ln != "") {
            lastName = ln
        }
        if (bd != Date()) {
            birthday = bd
        }
        if (pn != 0) {
            picNum = pn
        }
        if (pics != []) {
            pictures = pics
        }
        if (picurls != []) {
            pictureURLs = picurls
        }
        if (b != "") {
            bio = b
        }
        if (sc != "") {
            school = sc
        }
        if (inters != []) {
            interests = inters
        }
        if (preve.count != 0) {
            previousEvents = preve
        }
        if (goinge.count != 0) {
            goingEvents = goinge
        }
        if (enp != 0 && np != [:]) {
            notificationPreferences = np
        } else if (enp == 0) {
            notificationPreferences = np
        } else {
            notificationPreferences = DecodePreferences(enp)
        }
    }

    // Load someone's profile
    //MARK: case 1: zipFinder, case 2: Subview With Location, case 3: Subview without Location
    func load(status: Int, completion: @escaping (Bool) -> Void) {
        switch status{
        case 1:
            DatabaseManager.shared.loadUserProfile(given: self, completion: { results in
                switch results {
                case .success(let user):
                    print("completed user profile copy for: ")
                    print("copied \(user.username)")
                    completion(true)
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                    completion(false)
                }
            })
        case 2:
            DatabaseManager.shared.loadUserProfileSubView(given: userId, completion: { results in
                switch results {
                case .success(let user):
                    print("completed user profile copy for: ")
                    print("copied \(user.username)")
                    completion(true)
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                    completion(false)
                }
            })
        case 3:
            DatabaseManager.shared.loadUserProfileSubView(given: userId, completion: { results in
                switch results {
                case .success(let user):
                    print("completed user profile copy for: ")
                    print("copied \(user.username)")
                    completion(true)
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                    completion(false)
                }
            })
        case 4:
            print("add this later for expansion")
        default:
            DatabaseManager.shared.loadUserProfile(given: self, completion: { results in
                switch results {
                case .success(let user):
                    print("completed user profile copy for: ")
                    print("copied \(user.username)")
                    completion(true)
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                    completion(false)
                }
            })
        }
    }

    // Load your own profile
    //MARK: case 1: zipFinder, case 2: Subview With Location, case 3: Subview without Location
    static func load(status: Int, completion: @escaping (Bool) -> Void) {
        User.getCurrentUser().load(status: status, completion: {result in completion(result)})
    }
    
    
    
    func getMyZips() -> [User]{
        guard let friendsips = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int] else {
            return []
        }
        let zipsDict = friendsips.filter({ $0.value == 2 })
        let userIds = Array(zipsDict.keys)
        let zips = userIds.map({ User(userId: $0) })
        return zips
    }
    
}
