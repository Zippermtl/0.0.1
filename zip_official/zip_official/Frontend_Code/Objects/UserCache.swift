//
//  UserCache.swift
//  zip_official
//
//  Created by Nicolas Almerge

import Foundation


public class UserCache {
    private let USER_SIZE = class_getInstanceSize(User.self)
    private static let instance = UserCache()

    private var cache = Dictionary<String, User>()
    private var byteSize = 0
    private var maxByteSize = 1_000_000 // 1 MB cache data max
    
    private init() {}
    
    static func get() -> UserCache {
        return instance
    }
    
    func getUsersCached() -> Dictionary<String, User> {
        return cache
    }
    
    public func load(user: User, status: User.UserLoadType,
                     dataCompletion: @escaping (Result<User, Error>) -> Void,
//                     completionProfilePicture: @escaping (Result<[URL], Error>) -> Void,
                     completionUpdates: @escaping (Result<[URL],Error>) -> Void) {
        switch status{
        case .UserProfile:
            DatabaseManager.shared.loadUserProfile(given: user, completion: { results in
                switch results {
                case .success(let u):
                    user.updateSelfHard(user: u)
                    dataCompletion(.success(u))
                case .failure(let error):
                    print("error load in LoadUser -> LoadUserProfile \(error)")
                    dataCompletion(.failure(error))
                }
            })
        case .UserProfileUpdates:
            DatabaseManager.shared.loadUserProfile(given: user, dataCompletion: { res in
                switch res{
                case .success(let u):
                    user.updateSelfHard(user: u)
                    dataCompletion(.success(u))
                case .failure(let error):
                    dataCompletion(.failure(error))
                }
//            }, profilePictureCompletion: { res in
//                switch res{
//                case .success(let url):
//                    if(url.count > 0){
//                        user.profilePicUrl = url[0]
//                    }
//                    completionProfilePicture(.success(url))
//                case .failure(let error):
//                    completionUpdates(.failure(error))
//                }
            }, pictureCompletion: { res in
                switch res{
                case .success(let url):
                    if(url.count > 0){
                        user.pictureURLs = url
                    }
                    completionUpdates(.success(url))
                case .failure(let error):
                    completionUpdates(.failure(error))
                }
            })
        case .UserProfileNoPic:
            DatabaseManager.shared.loadUserProfileNoPic(given: user, completion: { res in
                switch res{
                case .success(let u):
                    user.updateSelfHard(user: u)
                    dataCompletion(.success(u))
                case .failure(let err):
                    dataCompletion(.failure(err))
                }
            })
        case .SubView:
            DatabaseManager.shared.loadUserProfileSubView(given: user.userId, completion: { results in
                switch results {
                case .success(let u):
                    user.updateSelfHard(user: u)
                    dataCompletion(.success(u))
                case .failure(let err):
                    dataCompletion(.failure(err))
                }
            })
        case .ProfilePicUrl:
            if (user.profilePicIndex) != [] {
                DatabaseManager.shared.getImages(Id: user.userId, indices: user.profilePicIndex, event: false, completion: { res in
                    switch res {
                    case .success(let urls):
                        if(urls.count > 0){
                            user.profilePicUrl = urls[0]
                        }
                        completionUpdates(.success(urls))
                    case .failure(let err):
                        completionUpdates(.failure(err))
                    }
                })
            }
        case .PicUrls:
            DatabaseManager.shared.getImages(Id: user.userId, indices: user.picIndices, event: false, completion: { res in
                switch res {
                case .success(let urls):
                    user.pictureURLs = urls
                    completionUpdates(.success(urls))
                case .failure(let err):
                    completionUpdates(.failure(err))
                }
            })
        case .Unloaded: break
//        case 4:
//            print("add this later for expansion")
//        default:
//            DatabaseManager.shared.loadUserProfile(given: self, completion: { results in
//                switch results {
//                case .success(let user):
//                    print("completed user profile copy for: ")
//                    print("copied \(user.username)")
//                    completion(true)
//                case .failure(let error):
//                    print("error load in LoadUser -> LoadUserProfile \(error)")
//                    completion(false)
//                }
//            })
        }
    }
    func loadUser(us: User, loadLevel: User.UserLoadType, loadFriends: Bool = false,
                  completion: @escaping (Result<User, Error>) -> Void,
//                  completionProfilePic: @escaping (Result<[URL], Error>) -> Void,
                  completionUpdates: @escaping (Result<[URL], Error>) -> Void) {
        if let cachedUser = cache[us.userId] {
            // Use the cached version
            us.updateSelfHard(user: cachedUser)
            completion(.success(cachedUser))
            return
        }

        // Create object and store it in the cache
//        let u = User(userId: us.userId)
        //MARK: COME BACK TOO
        // does .loadfriendships update user passed in
        load(user: us, status: loadLevel) { [weak self] res in
            switch res {
            case .success(let user):
                if (loadFriends){
                    us.loadFriendships(completion: { [weak self] res in
                        if let err = res {
                            completion(.failure(err))
                        } else {
                            self?.cache[us.userId] = us
                            self?.increaseSize()
                            self?.checkBounds()
                            completion(.success(us))
                        }
                    })
                } else {
                    self?.cache[us.userId] = us
                    self?.increaseSize()
                    self?.checkBounds()
                    completion(.success(user))
                }
//                us.updateSelf(user: user)
            case .failure(let err):
                completion(.failure(err))
            }
//        }, completionProfilePicture: { res in
//            switch res2{
//            case .success(let urls):
//                completionUpdates(.success(urls))
//            case .failure(let err):
//                completionUpdates(.failure(err))
//            }
        } completionUpdates: { res2 in
            switch res2{
            case .success(let urls):
                completionUpdates(.success(urls))
            case .failure(let err):
                completionUpdates(.failure(err))
            }
        }

//        if (loadFriends) {
//            u.loadFriendships(completion: {result in u.load(status: loadLevel, dataCompletion: { [weak self] result in
//                switch result {
//                case .success(let user):
//                    self?.cache[us.userId] = u
//                    self?.increaseSize()
//                    self?.checkBounds()
//                    completion(.success(u))
//                    return
//                case.failure(let err):
//                    completion(.failure(DatabaseManager.DatabaseError.failedToFetch))
//                    return
//                }
//            }, completionUpdates: { res in })})
//        } else {
//            u.load(status: loadLevel, dataCompletion: { [weak self] result in
//                switch result {
//                case .success(let user):
//                    self?.cache[us.userI] = u
//                        self?.increaseSize()
//                        self?.checkBounds()
//                        completion(.success(u))
//                        return
//                case .failure(let err):
//                        completion(.failure(DatabaseManager.DatabaseError.failedToFetch))
//                        return
//                }
//            }, completionUpdates: { _ in})
//        }
    }
    
    func putInCache(newUser: User) {
        if (!isInCache(userId: newUser.userId)) {
            increaseSize()
        }
        cache[newUser.userId] = newUser
        checkBounds()
    }
    
    func deleteUser(userId id: String) {
        if (isInCache(userId: id)) {
            cache.removeValue(forKey: id)
            decreaseSize()
        }
    }
    
    func isInCache(userId id: String) -> Bool {
        if let _ = cache[id] {
            return true
        }
        return false
    }

    func clear() {
        cache.removeAll()
        byteSize = 0
    }
    
    func getByteSize() -> Int {
        return byteSize
    }

    func getMaxByteSize() -> Int {
        return maxByteSize
    }
    
    func setMaxByteSize(newLimit: Int) {
        if (newLimit < 0) {
            print("Warning: user cache limit set to 0 since values below 0 not allowed.")
            maxByteSize = 0
        } else {
            maxByteSize = newLimit
        }
        if (maxByteSize == 0) {
            print("Warning: user cache limit set to 0 (infinite capacity).")
        }
        checkBounds() // Potential clean up
    }
    
    func getNumberOfUsersInCache() -> Int {
        return cache.count
    }
    
    private func increaseSize() {
        byteSize += USER_SIZE
    }
    
    private func decreaseSize() {
        byteSize -= USER_SIZE
        if (byteSize < 0) {
            byteSize = 0
        }
    }
    
    private func checkBounds() {
        if (maxByteSize > 0) {
            while (byteSize > maxByteSize) {
                // Remove a random element from the cache
                cache.removeValue(forKey: cache.keys.randomElement()!)
                decreaseSize()
            }
        }
    }
}
