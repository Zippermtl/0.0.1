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

class UserCoder: UserUpdateCoder {
    var picIndices: [Int]
    var profilePicIndex: [Int]
    var picNum: Int
    var userId: String
    var username: String
    var firstName: String
    var lastName: String
    var joinDate: Timestamp
    var deviceId: [String]
    var notificationToken: [String]
    var birthday: Timestamp
    var blockedUsers: [String]?
    var permissions: Int?
    var userTypeString: String?
    
    
    override init(user: User) {
        self.userId = user.userId
        self.username = user.username
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthday = Timestamp(date: user.birthday)
        self.picIndices = user.picIndices
        self.profilePicIndex = user.profilePicIndex
        self.picNum = user.picNum
        self.joinDate = Timestamp(date: user.joinDate)
        self.notificationToken = [user.notificationToken]
        self.deviceId = [user.deviceId]
        self.blockedUsers = user.blockedUsers
        self.userTypeString = user.userTypeString
        super.init(user: user)
        self.permissions = Self.encodePermissions(user.permissions)
    }
    
    static func decodePermissions(_ N: Int?) -> [User.Permissions:Bool] {
        guard var current = N else {
            return Dictionary(uniqueKeysWithValues: User.Permissions.allCases.map{ ($0, false) })
        }

        var values: [User.Permissions:Bool] = [:]
        var counter = 0 // Start index
        let NB_PREFS = User.Permissions.allCases.count
        let allPermissions = User.Permissions.allCases.sorted(by: { $0.rawValue > $1.rawValue})

        while (counter < NB_PREFS) {
            values[allPermissions[NB_PREFS-1-counter]] = current%2 > 0
            current /= 2
            counter += 1
        }
        return values
    }


    // Encode preferences into a integer
    static func encodePermissions(_ preferences: [User.Permissions:Bool]) -> Int? {
        var total = 0 // Total value
        var powerOfTwo = 1 // Start with 2^0
        let allPermissions = User.Permissions.allCases.sorted(by: { $0.rawValue > $1.rawValue})
        for i in (0..<User.Permissions.allCases.count).reversed() {
            
            if let perm = preferences[allPermissions[i]] {
                if perm {total += powerOfTwo} // If bit is on, add power of 2
            }
            powerOfTwo *= 2 // Multiply by 2 to get next power of 2
        }
        
        // Return total
        return total == 0 ? nil : total
    }
    
    enum CodingKeys: String, CodingKey {
        case picIndices = "picIndices"
        case profilePicIndex = "profileIndex"
        case picNum = "picNum"
        case userId = "id"
        case username = "username"
        case firstName = "firstName"
        case lastName = "lastName"
        case birthday = "birthday"
        case joinDate = "joinDate"
        case notificationToken = "notificationToken"
        case deviceId = "deviceId"
        case blockedUsers = "blockedUsers"
        case permissions = "permissions"
        case userTypeString = "userTypeString"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        birthday = try container.decode(Timestamp.self, forKey: .birthday)
        picIndices = try container.decode([Int].self, forKey: .picIndices)
        profilePicIndex = try container.decode([Int].self, forKey: .profilePicIndex)
        picNum = try container.decode(Int.self, forKey: .picNum)
        deviceId = try container.decode([String].self, forKey: .deviceId)
        notificationToken = try container.decode([String].self, forKey: .notificationToken)
        joinDate = try container.decode(Timestamp.self, forKey: .joinDate)
        blockedUsers = try? container.decode([String].self, forKey: .blockedUsers)
        permissions = try? container.decode(Int.self, forKey: .permissions)
        userTypeString = try? container.decode(String.self, forKey: .userTypeString)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(birthday, forKey: .birthday)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(notificationToken, forKey: .notificationToken)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(picIndices, forKey: .picIndices)
        try container.encode(profilePicIndex, forKey: .profilePicIndex)
        try container.encode(picNum, forKey: .picNum)
        try? container.encode(blockedUsers, forKey: .blockedUsers)
        try? container.encode(permissions, forKey: .permissions)
        try? container.encode(userTypeString, forKey: .userTypeString)
        try super.encode(to: encoder)
    }
    
    override func updateUser(_ user: User) {
        super.updateUser(user)
        user.picNum = picNum
        user.profilePicIndex = profilePicIndex
        user.picIndices = picIndices
        user.userId = userId
        user.username = username
        user.firstName = firstName
        user.lastName = lastName
        user.birthday = birthday.dateValue()
        user.joinDate = joinDate.dateValue()
        var nt = ""
        if notificationToken.count != 0 {
            nt = notificationToken[0]
        }
        user.notificationToken = nt
        
        if let blockedUsers = blockedUsers {
            user.blockedUsers = blockedUsers
        }
        
        user.userTypeString = self.userTypeString
        user.permissions = Self.decodePermissions(self.permissions)
    }
    
    override func createUser() -> User {
        let user = super.createUser()
        updateUser(user)
        return user
    }
}
 
class UserUpdateCoder: Codable {
    var bio: String
    var interests: [Interests]
    var school: String?
    var gender: String
    
    init(user: User) {
        self.bio = user.bio
        self.interests = user.interests
        self.school = user.school
        self.gender = user.gender
    }
    
    enum CodingKeys: String, CodingKey {
        case school = "school"
        case interests = "interests"
        case gender = "gender"
        case bio = "bio"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.interests = try container.decode([Interests].self, forKey: .interests)
        self.school = try? container.decode(String.self, forKey: .school)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bio, forKey: .bio)
        try container.encode(gender, forKey: .gender)
        try? container.encode(school, forKey: .school)
        try container.encode(interests, forKey: .interests)
    }
    
    
    public func createUser() -> User{
        return User(
            gender: gender,
            bio: bio,
            school: school,
            interests: interests
        )
    }
    
    public func updateUser(_ user: User) {
        user.bio = bio
        user.school = school
        user.interests = interests
        user.gender = gender
    }
}

public class User : CustomStringConvertible, Equatable, Comparable, CellItem {
    public var isUser: Bool = true
    
    public var isEvent: Bool = false
    
    public func getId() -> String {
        return userId
    }
    
    public var loadStatus: UserLoadType = .Unloaded
    
    public static func < (lhs: User, rhs: User) -> Bool {
        return lhs.firstName < rhs.firstName
    }
    
    func getEncoder() -> UserCoder {
        let encoder = UserCoder(user: self)
        return encoder
    }
    
    func getUpdateEncoder() -> UserUpdateCoder {
        let encoder = UserUpdateCoder(user: self)
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
    var Zfpref: ZipfinderPreference = .Default
    
    var email: String?
    var friendshipStatus: FriendshipStatus?
    
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var pictures: [UIImage] = []
    var pictureURLs: [URL] = []
    var profilePicIndex: [Int] = []
    var profilePicUrl: URL?
    var picIndices: [Int] = []
    var blockedUsers: [String] = []
    var previousEvents: [Event] = []
    var goingEvents: [Event] = []
    weak var tableViewCell: AbstractUserTableViewCell?
    weak var ZFCell : ZipFinderCollectionViewCell?
    
    public enum Permissions : Int, CaseIterable{
        case developer = 0
        case promoter = 1
        case ambassador = 2
        
        
        var color : UIColor {
            switch self {
            case .developer: return .zipBlue
            case .promoter: return .zipYellow
            case .ambassador: return .zipGreen
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .developer: return .white
            case .promoter: return .black
            case .ambassador: return .white
            }
        }
    }
    
    var userTypeString: String?
    var permissions : [User.Permissions : Bool] = {
        return Dictionary(uniqueKeysWithValues: User.Permissions.allCases.map{ ($0, false) })
    }()
    
    var promoterApp: PromoterApplication? = nil
    
    func getHighestPermission() -> User.Permissions? {
        if permissions[.developer] == true {
            return .developer
        } else if permissions[.promoter] == true {
            return .promoter
        } else if permissions[.ambassador] == true {
            return .ambassador
        } else {
            return nil
        }
    }
    
    struct PromoterApplication {
        let receiveTexts: Bool
        let reason: String?
        let accountType: String?
    }
    
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
            return 999999999.99
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
        case Unloaded = 6
    }
    
    public enum ZipfinderPreference: Int {
        case Default = 0
        case HideLocation = 1
        case HideProfile = 2
    }
    
    public func updateSelfHard(user: User){
            if (user.userId != self.userId){
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
    
    public func FillSelf(user: User){
        if (user.userId != self.userId){
            print("BIG ERROR")
            return
        } else {
            if self.username != "" {
                self.username = user.username
            }
            if self.firstName != "" {
                self.firstName = user.firstName
            }
            if self.lastName != "" {
                self.lastName = user.lastName
            }
            if self.birthday != Date() {
                self.birthday = user.birthday
            }
            if self.picNum != 0 {
                self.picNum = user.picNum
            }
            if self.bio != "" {
                self.bio = user.bio
            }
            if self.school != "" {
                self.school = user.school
            }
            if self.interests != [] {
                self.interests = user.interests
            }
            if self.friendships.count > 0 {
                self.friendships = user.friendships
            }
            if self.notificationPreferences != [:] {
                self.notificationPreferences = user.notificationPreferences
            }
            if self.deviceId != "" {
                self.deviceId = user.deviceId
            }
            if self.notificationToken != "" {
                self.notificationToken = user.notificationToken
            }
            if self.gender != "" {
                self.gender = user.gender
            }
            if self.email != "" {
                self.email = user.email
            }
            if self.friendshipStatus != nil {
                self.friendshipStatus = user.friendshipStatus
            }
            if self.location != CLLocation() {
                self.location = user.location
            }
            if self.pictures != [] {
                self.pictures = user.pictures
            }
            if self.pictureURLs != [] {
                self.pictureURLs = user.pictureURLs
            }
            if self.profilePicIndex != [] {
                self.profilePicIndex = user.profilePicIndex
            }
            if self.profilePicUrl != nil {
                self.profilePicUrl = user.profilePicUrl
            }
            if self.picIndices != [] {
                self.picIndices = user.picIndices
            }
            if self.previousEvents != [] {
                self.previousEvents = user.previousEvents
            }
            if self.goingEvents != [] {
                self.goingEvents = user.goingEvents
            }
        }
    }
    
    public func updateSelfSoft(user: User){
        if (user.userId != self.userId){
            print("BIG ERROR")
            return
        } else {
            if user.username != "" {
                self.username = user.username
            }
            if user.firstName != "" {
                self.firstName = user.firstName
            }
            if user.lastName != "" {
                self.lastName = user.lastName
            }
            if user.birthday != Date() {
                self.birthday = user.birthday
            }
            if user.picNum != 0 {
                self.picNum = user.picNum
            }
            if user.bio != "" {
                self.bio = user.bio
            }
            if user.school != "" {
                self.school = user.school
            }
            if user.interests != [] {
                self.interests = user.interests
            }
            if user.friendships.count > 0 {
                self.friendships = user.friendships
            }
            if user.notificationPreferences != [:] {
                self.notificationPreferences = user.notificationPreferences
            }
            if user.deviceId != "" {
                self.deviceId = user.deviceId
            }
            if user.notificationToken != "" {
                self.notificationToken = user.notificationToken
            }
            if user.gender != "" {
                self.gender = user.gender
            }
            if user.email != "" {
                self.email = user.email
            }
            if user.friendshipStatus != nil {
                self.friendshipStatus = user.friendshipStatus
            }
            if user.location != CLLocation() {
                self.location = user.location
            }
            if user.pictures != [] {
                self.pictures = user.pictures
            }
            if user.pictureURLs != [] {
                self.pictureURLs = user.pictureURLs
            }
            if user.profilePicIndex != [] {
                self.profilePicIndex = user.profilePicIndex
            }
            if user.profilePicUrl != nil {
                self.profilePicUrl = user.profilePicUrl
            }
            if user.picIndices != [] {
                self.picIndices = user.picIndices
            }
            if user.previousEvents != [] {
                self.previousEvents = user.previousEvents
            }
            if user.goingEvents != [] {
                self.goingEvents = user.goingEvents
            }
        }
    }
    
    //load someone's profile
    public func load(status: UserLoadType, loadFriends: Bool = false, dataCompletion: @escaping (Result<User, Error>) -> Void, completionUpdates: @escaping (Result<[URL],Error>) -> Void) {
        let a = UserCache.get()
        a.loadUser(us: self, loadLevel: status, loadFriends: loadFriends, completion: { res in
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
    
//    public func upload(completion: (Error?) -> Void){
//
//    }
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
    
    static func getHighestPermission() -> User.Permissions? {
        guard let intPerms = AppDelegate.userDefaults.value(forKey: "permissions") as? Int else {
            return nil
        }
        let permissions = UserCoder.decodePermissions(intPerms)
        if permissions[.developer] == true {
            return .developer
        } else if permissions[.promoter] == true {
            return .promoter
        } else if permissions[.ambassador] == true {
            return .ambassador
        } else {
            return nil
        }
    }
    
    static func getMyZips() -> [User]{
        guard let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]] else {
            return []
        }
        let friendships = DecodeFriendsUserDefaults(raw_friendships)
        let requestsArr = friendships.filter({ $0.status == .ACCEPTED })
       
        return requestsArr.map({ $0.receiver })
    }
    
    static func getMyRequests() -> [User]{
        guard let raw_friendships = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: [String: String]] else {
            return []
        }
        let friendships = DecodeFriendsUserDefaults(raw_friendships)
        let requestsArr = friendships.filter({ $0.status == .REQUESTED_INCOMING })
       
        return requestsArr.map({ $0.receiver })
    }
    
    static func removeUDEvent(event: Event, toKey key: UserDefaultEventKeys) {
        guard var dataDict = AppDelegate.userDefaults.value(forKey: key.rawValue) as? [String: Data] else {
            return
        }
        dataDict.removeValue(forKey: event.eventId)

    }
    
    static func appendUDEvent(event: Event, toKey key: UserDefaultEventKeys) {
        guard var dataDict = AppDelegate.userDefaults.value(forKey: key.rawValue) as? [String: Data] else {
            Self.setUDEvents(events: [event], toKey: key)
            return
        }
        do {
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(event.getLocalizedEncoder())
            dataDict[event.eventId] = data
            AppDelegate.userDefaults.set(dataDict, forKey: key.rawValue)
        } catch {
            
        }        
    }
    
    static func setUDEvents(events: [Event], toKey key : UserDefaultEventKeys) {
        var UDEvents = [String:Data]()
        for event in events {
            do {
                let jsonEncoder = JSONEncoder()
                let data = try jsonEncoder.encode(event.getLocalizedEncoder())
                UDEvents[event.eventId] = data
            } catch {
                print("unable to decode \(key.rawValue)")
            }
        }
        AppDelegate.userDefaults.set(UDEvents, forKey: key.rawValue)
    }
    
    static func getUDEvents(toKey key : UserDefaultEventKeys) -> [Event] {
        guard let dataDict = AppDelegate.userDefaults.value(forKey: key.rawValue) as? [String: Data] else {
            return []
        }
        
        var events = [Event]()
        for (id,data) in dataDict {
            do {
                let decoder = JSONDecoder()
                let localEvent = try decoder.decode(LocalEventCoder.self, from: data).createEvent()
                events.append(localEvent)
            } catch {
                print("unable to decode \(id) in \(key.rawValue)")
            }
        }
        return events
    }
    

}

public enum UserDefaultEventKeys : String {
    case hostedEvents = "hostedEvents"
    case goingEvents = "goingEvents"
    case savedEvents = "savedEvents"
    case invitedEvents = "invitedEvents"
    case notGoingEvents = "notGoingEvents"
    case pastHostEvents = "pastHostEvents"
    case pastGoingEvents = "pastGoingEvents"
    case happenings = "happenings"
}
