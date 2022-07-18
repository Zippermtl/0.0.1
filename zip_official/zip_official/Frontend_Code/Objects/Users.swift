//
//  Users.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//
import Foundation
import MapKit


public class User {
    var userId: String = ""
    var email: String = ""
    var username: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var zipped: Bool = false
    var distance: Double = 0
    var birthday: Date = Date()
    var age: Int = 18
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var picNum: Int = 0
    var pictures: [UIImage] = []
    var pictureURLs: [URL] = []
    var bio: String = ""
    var school: String?
    var interests: [Interests] = []
    var previousEvents: [Event] = []
    var goingEvents: [Event] = []
    var interestedEvents: [Event] = []
    var notificationPreferences: [String: Bool] = [:] // Notification Preferences
    var friendships: [Friendship] = [] // Friendship Preferences
    var friendshipStatus: FriendshipStatus = .ACCEPTED
    
    
    var joinDate = Date()

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
            return 0
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

    init(userId id: String = "", email em: String = "", username us: String = "", firstName fn: String = "", lastName ln: String = "", zipped zip: Bool = false, distance dis: Double = 0, birthday bd: Date = Date(), age a: Int = 18, location loc: CLLocation = CLLocation(latitude: 0, longitude: 0), picNum pn: Int = 0, pictures pics: [UIImage] = [], pictureURLs picurls: [URL] = [], bio b: String = "", school sc: String? = "", interests inters: [Interests] = [], previousEvents preve: [Event] = [], goingEvents goinge: [Event] = [], interestedEvents intere: [Event] = [], notificationPreferences np: [String: Bool] = [:], encodedNotifPref enp: Int? = 0) {
        userId = id
        email = em
        username = us
        firstName = fn
        lastName = ln
        zipped = zip
        distance = dis
        birthday = bd
        age = a
        location = loc
        picNum = pn
        pictures = pics
        pictureURLs = picurls
        bio = b
        school = sc
        interests = inters
        previousEvents = preve
        goingEvents = goinge
        interestedEvents = intere
        if (enp == 0){
            notificationPreferences = np
        } else {
            notificationPreferences = DecodePreferences(enp)
        }
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
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "contact.zippermtl@gmail.com"
        smtpSession.password = "PASSWORD_INSERT_HERE"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }

        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "Zipper MTL", mailbox: "contact.zippermtl@gmail.com")!]
        builder.header.from = MCOAddress(displayName: "Zipper App", mailbox: "contact.zippermtl@gmail.com")
        builder.header.subject = "User Report"
        builder.htmlBody = "<p><b>\(userId)</b> was reported!</p><p>Reason: \(reason).</p>"

        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation!.start {(error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(String(describing: error))")
            } else {
                NSLog("Successfully sent email!")
            }
        }
    }

    // Load your own friendships
    static func loadFriendships(completion: @escaping (Error?) -> Void) {
        User.getCurrentUser().loadFriendships(completion: {result in completion(result)})
    }
    
    // Update someone's friendships
    func updateFriendships(completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.updateUserFriendships(of: self, completion: {result in completion(result)})
    }
    
    // Update your own friendships
    static func updateFriendships(completion: @escaping (Bool) -> Void) {
        User.getCurrentUser().updateFriendships(completion: {result in completion(result)})
    }
    
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

    // Private helper function
    private func makeFriend(with user: User, status: FriendshipStatus = .ACCEPTED, completion: @escaping (Bool) -> Void) {
        for friendship in friendships {
            if friendship.receiver.userId == user.userId {
                if (friendship.status != status) {
                    friendship.status = status
                    updateFriendships(completion: {result in completion(result)})
                }
                return
            }
        }
        friendships.append(Friendship(to: user, status: status))
        updateFriendships(completion: {result in completion(result)})
    }

    // Requests a friend
    func requestFriend(completion: @escaping (Bool) -> Void) {
        let current = User.getCurrentUser()
        current.loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(false)
                return
            }

            self?.loadFriendships(completion: { [weak self] error in
                guard error == nil else {
                    completion(false)
                    return
                }

                for friendship in current.friendships {
                    if friendship.receiver.userId == self?.userId {
                        switch (friendship.status) {
                            // Recipient has already made a friend request
                            case.REQUESTED_INCOMING:
                                friendship.status = .ACCEPTED
                                current.updateFriendships(completion: {result in completion(result)})
                                self?.makeFriend(with: current, completion: {result in completion(result)})
                            // Don't do anything
                            default: return
                        }
                        return
                    }
                }

                // If friendship not found in list, add it
                current.friendships.append(Friendship(to: self!, status: .REQUESTED_OUTGOING))
                current.updateFriendships(completion: {result in completion(result)})
                self?.makeFriend(with: current, status: .REQUESTED_INCOMING, completion: {result in completion(result)})
            })
        })
    }

    // Accepts a friend (who made a friend request)
    func acceptFriend(completion: @escaping (Bool) -> Void) {
        let current = User.getCurrentUser()
        current.loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(false)
                return
            }

            self?.loadFriendships(completion: { [weak self] error in
                guard error == nil else {
                    completion(false)
                    return
                }

                for friendship in current.friendships {
                    if friendship.receiver.userId == self?.userId {
                        switch (friendship.status) {
                            // Recipient has already made a friend request
                            case.REQUESTED_INCOMING:
                                friendship.status = .ACCEPTED
                                current.updateFriendships(completion: {result in completion(result)})
                                self?.makeFriend(with: current, completion: {result in completion(result)})
                            // Don't do anything
                            default: return
                        }
                        return
                    }
                }
            })
        })
    
    }

    // Private helper function
    private func popFriend(_ user: User, completion: @escaping (Bool) -> Void) {
        var index = 0
        for friendship in friendships {
            if friendship.receiver.userId == user.userId {
                friendships.remove(at: index)
                updateFriendships(completion: {result in completion(result)})
                return
            }
            index += 1
        }
    }

    // Rejects a friend (who made a friend request)
    func rejectFriend(completion: @escaping (Bool) -> Void) {
        let current = User.getCurrentUser()
        current.loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(false)
                return
            }
            
            self?.loadFriendships(completion: { [weak self] error in
                guard error == nil else {
                    completion(false)
                    return
                }
        
                var index = 0
                for friendship in current.friendships {
                    if friendship.receiver.userId == self?.userId {
                        switch (friendship.status) {
                            // Recipient has already made a friend request
                            case.REQUESTED_INCOMING:
                                current.friendships.remove(at: index)
                                current.updateFriendships(completion: {result in completion(result)})
                                self?.popFriend(current, completion: {result in completion(result)})
                            // People are already friends
                            case.ACCEPTED:
                                current.friendships.remove(at: index)
                                current.updateFriendships(completion: {result in completion(result)})
                                self?.popFriend(current, completion: {result in completion(result)})
                            // Don't do anything
                            default: return
                        }
                        return
                    }
                    index += 1
                }
                
            })
        })
    }

   
    
    func updateUser(email em: String = "",
                    username us: String = "",
                    firstName fn: String = "",
                    lastName ln: String = "",
                    distance dis: Double = 0,
                    birthday bd: Date = Date(),
                    age a: Int = 0,
                    location loc: CLLocation = CLLocation(latitude: 0, longitude: 0),
                    picNum pn: Int = 0, pictures pics: [UIImage] = [],
                    pictureURLs picurls: [URL] = [],
                    bio b: String = "",
                    school sc: String? = "",
                    interests inters: [Interests] = [],
                    previousEvents preve: [Event] = [],
                    goingEvents goinge: [Event] = [],
                    interestedEvents intere: [Event] = [],
                    notificationPreferences np: [String: Bool] = [:],
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
        if (dis != 0) {
            distance = dis
        }
        if (bd != Date()) {
            birthday = bd
        }
        if (a != 0) {
            age = a
        }
        if (loc != CLLocation(latitude: 0, longitude: 0)) {
            location = loc
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
        if (intere.count != 0) {
            interestedEvents = intere
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
            DatabaseManager.shared.loadUserProfileZipFinder(given: self, completion: { results in
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
            DatabaseManager.shared.loadUserProfileSubViewNoLoc(given: userId, completion: { results in
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
            DatabaseManager.shared.loadUserProfile(given: userId, completion: { results in
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
    
    // Cancels a friend request
    func cancelFriendRequest(completion: @escaping (Bool) -> Void) {
        let current = User.getCurrentUser()
        current.loadFriendships(completion: { [weak self] error in
            guard error == nil else {
                completion(false)
                return
            }
            
            self?.loadFriendships(completion: { [weak self] error in
                guard error == nil else {
                    completion(false)
                    return
                }
        
                var index = 0
                for friendship in current.friendships {
                    if friendship.receiver.userId == self?.userId {
                        switch (friendship.status) {
                            // User has made a friend request
                            case.REQUESTED_OUTGOING:
                                current.friendships.remove(at: index)
                                current.updateFriendships(completion: {result in completion(result)})
                                self?.popFriend(current, completion: {result in completion(result)})
                            // Don't do anything
                            default: return
                        }
                        return
                    }
                    index += 1
                }
            })
        })
    }
}
