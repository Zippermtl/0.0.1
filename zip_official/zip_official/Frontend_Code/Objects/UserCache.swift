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
    
    func loadUser(id: String, loadLevel: User.UserLoadType, loadFriends: Bool = false, completion: @escaping (Result<User, Error>) -> Void) {
        if let cachedUser = cache[id] {
            // Use the cached version
            completion(.success(cachedUser))
            return
        }

        // Create object and store it in the cache
        let u = User(userId: id)
        if (loadFriends) {
            u.loadFriendships(completion: {result in u.load(status: loadLevel, dataCompletion: { [weak self] result in
                switch result {
                case .success(let user):
                    self?.cache[id] = u
                    self?.increaseSize()
                    self?.checkBounds()
                    completion(.success(u))
                    return
                case.failure(let err):
                    completion(.failure(DatabaseManager.DatabaseError.failedToFetch))
                    return
                }
            }, completionUpdates: { res in })})
        } else {
            u.load(status: loadLevel, dataCompletion: { [weak self] result in
                switch result {
                case .success(let user):
                        self?.cache[id] = u
                        self?.increaseSize()
                        self?.checkBounds()
                        completion(.success(u))
                        return
                case .failure(let err):
                        completion(.failure(DatabaseManager.DatabaseError.failedToFetch))
                        return
                }
            }, completionUpdates: { _ in})
        }
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
