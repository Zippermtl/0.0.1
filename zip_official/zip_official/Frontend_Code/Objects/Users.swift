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
    var gender: String
    var joinDate: Timestamp
    var picIndices: [Int]
    var profilePicIndex: [Int]
    
    init(user: User) {
        self.userId = user.userId
        self.username = user.username
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthday = Timestamp(date: user.birthday)
        self.picNum = user.picNum
        self.bio = user.bio
        self.interests = user.interests
        self.deviceId = [user.deviceId]
        self.notificationToken = [user.notificationToken]
        self.school = user.school
        self.gender = user.gender
        self.joinDate = Timestamp(date: user.joinDate)
        self.picIndices = user.picIndices
        self.profilePicIndex = user.profilePicIndex
    }
    
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
        case gender = "gender"
        case notificationToken = "notificationToken"
        case joinDate = "joinDate"
        case picIndices = "picIndices"
        case profilePicIndex = "profileIndex"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.username = try container.decode(String.self, forKey: .username)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.picNum = try container.decode(Int.self, forKey: .picNum)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.school = try container.decode(String.self, forKey: .school)
        self.interests = try container.decode([Interests].self, forKey: .interests)
        self.birthday = try container.decode(Timestamp.self, forKey: .birthday)
        self.school = try container.decode(String.self, forKey: .school)
        self.deviceId = try container.decode([String].self, forKey: .deviceId)
        self.notificationToken = try container.decode([String].self, forKey: .notificationToken)
        self.joinDate = try container.decode(Timestamp.self, forKey: .joinDate)
        self.picIndices = try container.decode([Int].self, forKey: .picIndices)
        self.profilePicIndex = try container.decode([Int].self, forKey: .profilePicIndex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(birthday, forKey: .birthday)
        try container.encode(bio, forKey: .bio)
        try container.encode(gender, forKey: .gender)
        try container.encode(picNum, forKey: .picNum)
        try container.encode(school, forKey: .school)
        try container.encode(interests, forKey: .interests)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(notificationToken, forKey: .notificationToken)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(picIndices, forKey: .picIndices)
        try container.encode(profilePicIndex, forKey: .profilePicIndex)
    }
    
    
    public func createUser() -> User{
        var nt = ""
        if notificationToken.count != 0 {
            nt = notificationToken[0]
        }
        return User(
            userId: userId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            birthday: birthday.dateValue(),
            picNum: picNum,
            bio: bio,
            school: school,
            interests: interests,
            notificationToken: nt,
            joinDate: joinDate.dateValue(),
            profilePicIndex: profilePicIndex,
            picIndices: picIndices
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
        user.joinDate = joinDate.dateValue()
        user.picIndices = picIndices
        user.profilePicIndex = profilePicIndex
    }
}

public class User : CustomStringConvertible, Equatable {
    func getEncoder() -> UserCoder {
        let encoder = UserCoder(user: self)
        return encoder
    }
    
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
    var gender: String = ""
    
    var email: String?
    var friendshipStatus: FriendshipStatus?
    
    var location: CLLocation = CLLocation()
    var pictures: [UIImage] = []
    var pictureURLs: [URL] = []
    var profilePicIndex: [Int] = []
    var profilePicUrl: URL?
    var picIndices: [Int] = []
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
        out += "picNum = \(picNum) \n"
        out += "bio = \(bio) \n"
        out += "school = \(school ?? "") \n"
        out += "interests = \(interests) \n"
        return out
    }
    
    var joinDate = Date()
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
    }

    func setProfilePicUrl(url: URL) {
        profilePicUrl = url
    }
    
    var otherPictureUrls: [URL] {
        return pictureURLs
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
    var hasSchool: Bool { return school != "" && school != nil}
    var hasInterests: Bool {
        return interests != []
        
    }

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

    init(userId id: String = "", email em: String = "", username us: String = "", firstName fn: String = "", lastName ln: String = "", gender: String = "", birthday bd: Date = Date(), location loc: CLLocation = CLLocation(latitude: 0, longitude: 0), picNum pn: Int = 0, pictures pics: [UIImage] = [], pictureURLs picurls: [URL] = [], bio b: String = "", school sc: String? = "", interests inters: [Interests] = [], previousEvents preve: [Event] = [], goingEvents goinge: [Event] = [], notificationPreferences np: NotificationPreference = [:], encodedNotifPref enp: Int? = 0, deviceId devId: String = "", notificationToken nt: String = "", joinDate jd: Date = Date(), profilePicUrl pUrl: URL? = URL(string: ""), profilePicIndex pInd: [Int] = [], picIndices picInds: [Int] = []) {
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
        notificationToken = nt
        joinDate = jd
        profilePicUrl = pUrl
        profilePicIndex = pInd
        picIndices = picInds
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
//        smtpSession.username = "zipper.reports@gmail.com"
//        smtpSession.password = "sher900W!"
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
//        builder.header.to = [MCOAddress(displayName: "Zipper MTL", mailbox: "zipper.reports@gmail.com")!]
//        builder.header.from = MCOAddress(displayName: "Zipper App", mailbox: "zipper.reports@gmail.com")
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
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]],
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
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = .REQUESTED_OUTGOING
            selfFriendships[strongSelf.userId] = ["status" : strongSelf.friendshipStatus!.rawValue.description, "name" : strongSelf.fullName, "username" : strongSelf.username]
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)

        }
    }

    // Accepts a friend (who made a friend request)
    func acceptRequest(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.acceptRequest(user: self) { [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]],
                  let strongSelf = self,
                    error == nil else {
                completion(error)
                return
            }
            strongSelf.friendshipStatus = .ACCEPTED
            selfFriendships[strongSelf.userId] = ["status" : strongSelf.friendshipStatus!.rawValue.description, "name" : strongSelf.fullName, "username" : strongSelf.username]
            AppDelegate.userDefaults.set(selfFriendships, forKey: "friendships")
            completion(nil)
        }
    }

    // Rejects a friend (who made a friend request)
    func rejectRequest(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.rejectRequest(user: self) { [weak self] error in
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String:String]],
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
            guard var selfFriendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]],
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

    //MARK: case 1: zipFinder, case 2: Subview With Location, case 3: Subview without Location
    public enum UserLoadType: Int {
        case UserProfile = 0
        case UserProfileUpdates = 1
        case UserProfileNoPic = 2
        case SubView = 3
        case ProfilePicUrl = 4
        case PicUrls = 5
    }
    
    public func updateSelf(user: User){
        if (user.userId == self.userId){
            print("BIG ERROR")
            return
        } else {
            self.username = user.username
            self.firstName = user.firstName
            self.lastName = user.lastName
            self.birthday = user.birthday
            self.picNum = user.picNum
            self.bio = user.bio
            self.school = user.school
            self.interests = user.interests
            self.friendships = user.friendships
            self.notificationPreferences = user.notificationPreferences
            self.deviceId = user.deviceId
            self.notificationToken = user.notificationToken
            self.gender = user.gender
            self.email = user.email
            self.friendshipStatus = user.friendshipStatus
            self.location = user.location
            self.pictures = user.pictures
            self.pictureURLs = user.pictureURLs
            self.profilePicIndex = user.profilePicIndex
            self.profilePicUrl = user.profilePicUrl
            self.picIndices = user.picIndices
            self.previousEvents = user.previousEvents
            self.goingEvents = user.goingEvents            
        }
    }
    
    //load someone's profile
    public func load(status: UserLoadType, dataCompletion: @escaping (Result<User, Error>) -> Void, completionUpdates: @escaping (Result<[URL],Error>) -> Void) {
        let a = UserCache.get()
        a.loadUser(us: self, loadLevel: status, loadFriends: false, completion: { res in
            switch res {
            case .success(let user):
                dataCompletion(.success(user))
            case .failure(let err):
                dataCompletion(.failure(err))
            }
        }, completionUpdates: { res in
            switch res {
            case .success(let url):
                completionUpdates(.success(url))
            case .failure(let err):
                completionUpdates(.failure(err))
            }
        })
    }
//        switch status{
//        case .UserProfile:
//            DatabaseManager.shared.loadUserProfile(given: self, completion: { results in
//                switch results {
//                case .success(let user):
//                    dataCompletion(.success(user))
//                case .failure(let error):
//                    print("error load in LoadUser -> LoadUserProfile \(error)")
//                    dataCompletion(.failure(error))
//                }
//            })
//        case .UserProfileUpdates:
//            DatabaseManager.shared.loadUserProfile(given: self, dataCompletion: { res in
//                switch res{
//                case .success(let user):
//                    dataCompletion(.success(user))
//                case .failure(let error):
//                    dataCompletion(.failure(error))
//                }
//            }, pictureCompletion: { res in
//                switch res{
//                case .success(let url):
//                    completionUpdates(.success(url))
//                case .failure(let error):
//                    completionUpdates(.failure(error))
//                }
//            })
//        case .UserProfileNoPic:
//            DatabaseManager.shared.loadUserProfileNoPic(given: self, completion: { res in
//                switch res{
//                case .success(let user):
//                    dataCompletion(.success(user))
//                case .failure(let err):
//                    dataCompletion(.failure(err))
//                }
//            })
//        case .SubView:
//            DatabaseManager.shared.loadUserProfileSubView(given: userId, completion: { results in
//                switch results {
//                case .success(let user):
//                    dataCompletion(.success(user))
//                case .failure(let err):
//                    dataCompletion(.failure(err))
//                }
//            })
//        case .ProfilePicUrl:
//            if (self.profilePicIndex) != [] {
//                DatabaseManager.shared.getImages(Id: self.userId, indices: self.profilePicIndex, event: false, completion: { res in
//                    switch res {
//                    case .success(let urls):
//                        completionUpdates(.success(urls))
//                    case .failure(let err):
//                        completionUpdates(.failure(err))
//                    }
//                })
//            }
//        case .PicUrls:
//            DatabaseManager.shared.getImages(Id: self.userId, indices: self.picIndices, event: false, completion: { res in
//                switch res {
//                case .success(let urls):
//                    completionUpdates(.success(urls))
//                case .failure(let err):
//                    completionUpdates(.failure(err))
//                }
//            })
////        case 4:
////            print("add this later for expansion")
////        default:
////            DatabaseManager.shared.loadUserProfile(given: self, completion: { results in
////                switch results {
////                case .success(let user):
////                    print("completed user profile copy for: ")
////                    print("copied \(user.username)")
////                    completion(true)
////                case .failure(let error):
////                    print("error load in LoadUser -> LoadUserProfile \(error)")
////                    completion(false)
////                }
////            })
//        }
    
    
    
    static func getMyZips() -> [User]{
        guard let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]] else {
            return []
        }
        let friendships = DecodeFriendsUserDefaults(raw_friendships)
        let requestsArr = friendships.filter({ $0.status == .ACCEPTED })
       
        return requestsArr.map({ $0.receiver })
    }
    
    static func getInvitedEvents() -> [Event]{
        guard let raw_events = AppDelegate.userDefaults.value(forKey: "myInvitedEvents") as? [String] else {
            return []
        }
        let events = raw_events.map({ Event(eventId: $0)})
        return events
    }
    
    static func getHostedEvents() -> [Event]{
        guard let raw_events = AppDelegate.userDefaults.value(forKey: "myHostedEvents") as? [String] else {
            return []
        }
        let events = raw_events.map({ Event(eventId: $0)})
        return events
    }
    
    static func getSavedEvents() -> [Event]{
        guard let raw_events = AppDelegate.userDefaults.value(forKey: "mySavedEvents") as? [String] else {
            return []
        }
        let events = raw_events.map({ Event(eventId: $0)})
        return events
    }
    
    static func getMyRequests() -> [User]{
        guard let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]] else {
            return []
        }
        let friendships = DecodeFriendsUserDefaults(raw_friendships)
        let requestsArr = friendships.filter({ $0.status == .REQUESTED_INCOMING })
       
        return requestsArr.map({ $0.receiver })
    }
    
}
