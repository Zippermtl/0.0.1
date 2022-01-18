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
    
    
    var isInivted: Bool = false
    
    
    init() {}
    
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
        if(enp == 0){
            notificationPreferences = np
        } else {
            notificationPreferences = DecodePreferences(enp)
        }
    }
    
    func loadFriendships() {
        DatabaseManager.shared.loadUserFriendships(given: userId, completion: { [self] result in
            switch result {
                case.success(let f):
                    friendships.removeAll()
                    for friendship in f {
                        friendships.append(friendship)
                    }
                default: print("error loading friends")
            }
        })
    }
    
    func updateFriendships() {
        DatabaseManager.shared.updateUserFriendships(of: self, completion: { result in
            switch result {
                case true: print("success")
                default: print("error updating friends")
            }
        })
    }
    
    func getFriendsList() -> [User] {
        loadFriendships()
        var friends: [User] = []
        for friendship in friendships {
            switch friendship.status {
                case.ACCEPTED: friends.append(friendship.receiver)
                default: continue
            }
        }
        
        return friends
    }
    
    func getIncomingRequests() -> [User] {
        loadFriendships()
        var friends: [User] = []
        for friendship in friendships {
            switch friendship.status {
                case.REQUESTED_INCOMING: friends.append(friendship.receiver)
                default: continue
            }
        }
        
        return friends
    }
    
    func getOutgoingRequests() -> [User] {
        loadFriendships()
        var friends: [User] = []
        for friendship in friendships {
            switch friendship.status {
                case.REQUESTED_OUTGOING: friends.append(friendship.receiver)
                default: continue
            }
        }
        
        return friends
    }
    
    private func makeFriend(with user: User, status: FriendshipStatus = .ACCEPTED) {
        for friendship in friendships {
            if friendship.receiver.userId == user.userId {
                if (friendship.status != status) {
                    friendship.status = status
                    updateFriendships()
                }
                return
            }
        }
        friendships.append(Friendship(to: user, status: status))
        updateFriendships()
    }
    
    func requestFriend(to recipient: User) {
        loadFriendships()
        recipient.loadFriendships()
        for friendship in friendships {
            if friendship.receiver.userId == recipient.userId {
                switch (friendship.status) {
                    // Recipient has already made a friend request
                    case.REQUESTED_INCOMING:
                        friendship.status = .ACCEPTED
                        updateFriendships()
                        recipient.makeFriend(with: self)
                    // Don't do anything
                    default: return
                }
                return
            }
        }
        
        // If friendship not found in list, add it
        friendships.append(Friendship(to: recipient, status: .REQUESTED_OUTGOING))
        updateFriendships()
        recipient.makeFriend(with: self, status: .REQUESTED_INCOMING)
    }
    
    func acceptFriend(_ recipient: User) {
        loadFriendships()
        recipient.loadFriendships()
        for friendship in friendships {
            if friendship.receiver.userId == recipient.userId {
                switch (friendship.status) {
                    // Recipient has already made a friend request
                    case.REQUESTED_INCOMING:
                        friendship.status = .ACCEPTED
                        updateFriendships()
                        recipient.makeFriend(with: self)
                    // Don't do anything
                    default: return
                }
                return
            }
        }
    }
    
    private func popFriend(_ user: User) {
        var index = 0
        for friendship in friendships {
            if friendship.receiver.userId == user.userId {
                friendships.remove(at: index)
                updateFriendships()
                return
            }
            index += 1
        }
    }
    
    func rejectFriend(_ recipient: User) {
        loadFriendships()
        recipient.loadFriendships()
        var index = 0
        for friendship in friendships {
            if friendship.receiver.userId == recipient.userId {
                switch (friendship.status) {
                    // Recipient has already made a friend request
                    case.REQUESTED_INCOMING:
                        friendships.remove(at: index)
                        updateFriendships()
                        recipient.popFriend(self)
                    // People are already friends
                    case.ACCEPTED:
                        friendships.remove(at: index)
                        updateFriendships()
                        recipient.popFriend(self)
                    // Don't do anything
                    default: return
                }
                return
            }
            index += 1
        }
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
        return "Interests: " + interests.map{$0.description}.joined(separator: ", ")
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
        
        if(em != ""){
            email = em
        }
        if(us != ""){
            username = us
        }
        if(fn != ""){
            firstName = fn
        }
        if(ln != ""){
            lastName = ln
        }
        if(dis != 0){
            distance = dis
        }
        if(bd != Date()){
            birthday = bd
        }
        if(a != 0){
            age = a
        }
        if(loc != CLLocation(latitude: 0, longitude: 0)){
            location = loc
        }
        if(pn != 0){
            picNum = pn
        }
        if(pics != []){
            pictures = pics
        }
        if(picurls != []){
            pictureURLs = picurls
        }
        if (b != ""){
            bio = b
        }
        if(sc != ""){
            school = sc
        }
        if(inters != []){
            interests = inters
        }
        if(preve.count != 0){
            previousEvents = preve
        }
        if(goinge.count != 0){
            goingEvents = goinge
        }
        if(intere.count != 0){
            interestedEvents = intere
        }
        if(enp != 0 && np != [:]){
            notificationPreferences = np
        } else if (enp == 0){
            notificationPreferences = np
        } else {
            notificationPreferences = DecodePreferences(enp)
        }
    }
    //MARK: case 1: zipFinder, case 2: Subview With Location, case 3: Subview without Location
    func load(status: Int, completion: @escaping (Bool) -> Void){
        switch status{
        
        case 1:
            DatabaseManager.shared.loadUserProfileZipFinder(given: self, completion: { [weak self] result in
                switch result {
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
            DatabaseManager.shared.loadUserProfileSubView(given: userId, completion: { [weak self] result in
                switch result {
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
            DatabaseManager.shared.loadUserProfileSubViewNoLoc(given: userId, completion: { [weak self] result in
                switch result {
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
            DatabaseManager.shared.loadUserProfile(given: userId, completion: { [weak self] result in
                switch result {
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
}
