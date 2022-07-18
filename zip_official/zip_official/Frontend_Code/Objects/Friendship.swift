
// MARK: Friendship status enum
public enum FriendshipStatus: Int {
    case REQUESTED_INCOMING = 0
    case REQUESTED_OUTGOING = 1
    case ACCEPTED = 2
    case NO_RELATION = 3
    
}

// MARK: Friendship class
public class Friendship {
    var receiver = User()
    var status: FriendshipStatus
    
    init(to b: String, status c: FriendshipStatus) {
        status = c
        receiver = User(userId: b)
    }
    
    init(to b: User, status c: FriendshipStatus) {
        receiver = b
        status = c
    }
}

// MARK: Utility functions
public func DecodeFriendships(_ values: [String: Any]) -> [Friendship] {
    var friendships: [Friendship] = []
    for elem in values {
        let code = String(describing: elem.value)
        print("String: \(code)")
        print("elem.key = \(elem.key)")
        if code == "0" {
            friendships.append(Friendship(to: elem.key, status: .REQUESTED_INCOMING))
        } else if code == "1" {
            friendships.append(Friendship(to: elem.key, status: .REQUESTED_OUTGOING))
        } else if code == "2" {
            friendships.append(Friendship(to: elem.key, status: .ACCEPTED))
        }
    }
    
    return friendships
}

public func EncodeFriendships(_ friendships: [Friendship]) -> [String: Int] {
    var encoded: [String: Int] = [:]
    for friendship in friendships {
        print(friendship.receiver.userId)
        if friendship.status == .REQUESTED_INCOMING {
            encoded[friendship.receiver.userId] = 0
        } else if friendship.status == .REQUESTED_OUTGOING {
            encoded[friendship.receiver.userId] = 1
        } else {
            encoded[friendship.receiver.userId] = 2
        }
    }
    return encoded
}
