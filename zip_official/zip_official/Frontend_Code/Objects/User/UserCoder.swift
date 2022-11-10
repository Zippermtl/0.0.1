//
//  UserCoder.swift
//  zip_official
//
//  Created by user on 10/28/22.
//

import Foundation
import MapKit
import FirebaseFirestore

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
    var groups: [String] = []
    
    
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
        self.groups = user.groups.map({$0.id})
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
        case groups = "Groups"
    }
    
    public required init(from decoder: Decoder) throws {
        var needToFixGroups = false
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
        do {
            print("trying to get groups")
            groups = try container.decode([String].self, forKey: .groups)
            print("groups == \(groups), \(userId)")
        } catch {
            groups = []
            needToFixGroups = true
        }
        try super.init(from: decoder)
        if needToFixGroups {
            Task {
                await DatabaseManager.shared.fixUserGroups(userId: userId)
                print("fixed User: \(userId)")
            }
        }
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
        try container.encode(groups, forKey: .groups)
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
        user.groups = groups.map( { Group(groupId: $0 )} )
        
    }
    
    override func createUser() -> User {
        let user = super.createUser()
        updateUser(user)
        return user
    }
}
