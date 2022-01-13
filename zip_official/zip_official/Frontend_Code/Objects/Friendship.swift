
// MARK: Friendship status enum
public enum FriendshipStatus: Int {
    case REQUESTED_INCOMING = 0
    case REQUESTED_OUTGOING = 1
    case ACCEPTED = 2
}

// MARK: Friendship class
public class Friendship {
    var receiver: User = User()
    var status: FriendshipStatus
    
    init(to b: String, status c: FriendshipStatus) {
        status = c
        DatabaseManager.shared.loadUserProfile(given: b, completion: { [self] result in
            switch result {
                case.success(let user): self.receiver = user
                default: print("error loading user")
            }
        })
    }
}

// MARK: Utility functions
public func DecodeFriendships(_ value: [String]) -> [Friendship] {
    var friendships: [Friendship] = []
    for elem in value {
        let list = elem.split(separator: ":")
        if list.count == 2 {
            let userId = String(list[0])
            let rawStatus = String(list[1])
            if rawStatus == "0" {
                friendships.append(Friendship(to: userId, status: .REQUESTED_INCOMING))
            } else if rawStatus == "1" {
                friendships.append(Friendship(to: userId, status: .REQUESTED_OUTGOING))
            } else if rawStatus == "2" {
                friendships.append(Friendship(to: userId, status: .ACCEPTED))
            }
        }
    }
    
    return friendships
}

public func EncodeFriendships(_ friendships: [Friendship]) -> [String] {
    var encoded: [String] = []
    for friendship in friendships {
        if friendship.status == .REQUESTED_INCOMING {
            encoded.append(friendship.receiver.userId + ":0")
        } else if friendship.status == .REQUESTED_OUTGOING {
            encoded.append(friendship.receiver.userId + ":1")
        } else {
            encoded.append(friendship.receiver.userId + ":2")
        }
    }
    return encoded
}
