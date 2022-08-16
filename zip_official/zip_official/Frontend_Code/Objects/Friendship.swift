
// MARK: Friendship status enum
public enum FriendshipStatus: Int {
    case REQUESTED_INCOMING = 0
    case REQUESTED_OUTGOING = 1
    case ACCEPTED = 2
}

// MARK: Friendship class
public typealias Friendship = (receiver: User, status: FriendshipStatus)

// MARK: Utility functions
public func DecodeFriendships(_ values: [String: Any]) -> [Friendship] {
    var friendships: [Friendship] = []
    for (id,val) in values {
        guard let dict = val as? [String: Any] else {
            return []
        }
        let status = (dict["status"] as? Int) ?? 0
        let fullname = (dict["name"] as? String) ?? ""
        let username = (dict["username"] as? String) ?? ""
        let components = fullname.split(separator: " ")
        let user = User(userId: id, username: username, firstName: String(components[0]), lastName: String(components[1]))
        user.friendshipStatus = FriendshipStatus(rawValue: status)!
        let friendship = Friendship(user, FriendshipStatus(rawValue: status)!)
        friendships.append(friendship)
    }
    return friendships
}

public func EncodeFriendships(_ friendships: [Friendship]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: friendships.map { ($0.receiver.userId , ["status" : $0.status.rawValue,
                                                                                     "name" : $0.receiver.fullName,
                                                                                     "username" : $0.receiver.username] ) } )
}

public func EncodeFriendsUserDefaults(_ friendships: [Friendship]) -> [String: [String: String]] {
    return Dictionary(uniqueKeysWithValues: friendships.map { ($0.receiver.userId , ["status" : String($0.status.rawValue),
                                                                                     "name" : $0.receiver.fullName,
                                                                                     "username" : $0.receiver.username] ) } )
}

public func DecodeFriendsUserDefaults(_ values: [String: [String: String]]) -> [Friendship]{
    var friendships: [Friendship] = []
    for (id,dict) in values {
        let statusString = dict["status"] ?? "0"
        let status = Int(statusString) ?? 0
        let fullname = dict["name"] ?? ""
        let username = dict["username"] ?? ""
        let components = fullname.split(separator: " ")
        let user = User(userId: id, username: username, firstName: String(components[0]), lastName: String(components[1]))
        user.friendshipStatus = FriendshipStatus(rawValue: status)!
        let friendship = Friendship(user, FriendshipStatus(rawValue: status)!)
        friendships.append(friendship)
    }
    return friendships
}

