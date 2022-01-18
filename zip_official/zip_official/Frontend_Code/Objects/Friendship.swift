
// MARK: Friendship status enum
public enum FriendshipStatus: Int {
    case REQUESTED_INCOMING = 0
    case REQUESTED_OUTGOING = 1
    case ACCEPTED = 2
}

// MARK: Friendship class
public class Friendship {
    var receiver: User
    var status: FriendshipStatus
    
    init(to b: String, status c: FriendshipStatus) {
        status = c
        receiver = User(userId: b)
        DatabaseManager.shared.loadUserProfile(given: b, completion: { [self] result in
            switch result {
                case.success(let user): self.receiver = user
            default: print("Fuck")
            }
        })
    }
    
    init(to b: User, status c: FriendshipStatus) {
        receiver = b
        status = c
    }
}

// MARK: Utility functions
public func DecodeFriendships(_ values: [String: Int]) -> [Friendship] {
    var friendships: [Friendship] = []
    for code in values {
        if code.value == 0 {
            friendships.append(Friendship(to: "\(code.key)", status: .REQUESTED_INCOMING))
        } else if code.value == 1 {
            friendships.append(Friendship(to: "\(code.key)", status: .REQUESTED_OUTGOING))
        } else if code.value == 2 {
            friendships.append(Friendship(to: "\(code.key)", status: .ACCEPTED))
        }
    }
    
    return friendships
}

public func EncodeFriendships(_ friendships: [Friendship]) -> [String: Int] {
    var encoded: [String: Int] = [:]
    for friendship in friendships {
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
