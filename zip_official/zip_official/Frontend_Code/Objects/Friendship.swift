
// MARK: Friendship status enum
public enum FriendshipStatus: Int {
    case REQUESTED_INCOMING = 0
    case REQUESTED_OUTGOING = 1
    case ACCEPTED = 2
}

// MARK: Friendship class
public typealias Friendship = (receiver: User, status: FriendshipStatus)

// MARK: Utility functions
public func DecodeFriendships(_ values: [String: Int]) -> [Friendship] {
    var friendships: [Friendship] = []
    for (id,status) in values {
        let friendship = Friendship(User(userId: id), FriendshipStatus(rawValue: status)!)
        friendships.append(friendship)
    }
    return friendships
}

public func EncodeFriendships(_ friendships: [Friendship]) -> [String: Int] {
    return Dictionary(uniqueKeysWithValues: friendships.map { ($0.receiver.userId , $0.status.rawValue) } )
}
