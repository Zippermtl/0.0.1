
// MARK: Friendship status enum
public enum FriendshipStatus: Int {
    case REQUESTED_INCOMING = 0
    case REQUESTED_OUTGOING = 1
    case ACCEPTED = 2
}

// MARK: Friendship class
public class Friendship {
    var from: User = User()
    var to: User = User()
    var status: FriendshipStatus
    
    init(from a: User, to b: String, status c: FriendshipStatus) {
        from = a
        status = c
        DatabaseManager.shared.loadUserProfile(given: b, completion: { [self] result in
            switch result {
                case.success(let user): self.to = user
                default: print("error loading user")
            }
        })
    }
}

// MARK: Utility functions
public func DecodeFriendships(of user: User, given value: String?) -> [Friendship] {
    var friendships: [Friendship] = []
    let string = value ?? ""
    for elem in string.split(separator: ",") {
        let list = elem.split(separator: ":")
        if list.count == 2 {
            let userId = String(list[0])
            let rawStatus = String(list[1])
            if rawStatus == "0" {
                friendships.append(Friendship(from: user, to: userId, status: .REQUESTED_INCOMING))
            } else if rawStatus == "1" {
                friendships.append(Friendship(from: user, to: userId, status: .REQUESTED_OUTGOING))
            } else if rawStatus == "2" {
                friendships.append(Friendship(from: user, to: userId, status: .ACCEPTED))
            }
        }
    }
    
    return friendships
}

public func EncodeFriendships(of user: User) -> String {
    var encoded: [String] = []
    for friendship in user.friendships {
        if friendship.status == .REQUESTED_INCOMING {
            encoded.append(friendship.to.userId + ":0")
        } else if friendship.status == .REQUESTED_OUTGOING {
            encoded.append(friendship.to.userId + ":1")
        } else {
            encoded.append(friendship.to.userId + ":2")
        }
    }
    return encoded.joined(separator: ",")
}
