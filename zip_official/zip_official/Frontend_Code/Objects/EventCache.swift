//
//  EventCache.swift
//  zip_official
//
//  Created by Nicolas Almerge

import Foundation


public class EventCache {
    private let EVENT_SIZE = MemoryLayout.size(ofValue: Event.self)
    private static let instance = EventCache()

    private var cache = Dictionary<String, Event>()
    private var byteSize = 0
    private var maxByteSize = 1_000_000 // 1 MB cache data max
    
    private init() {}
    
    static func get() -> EventCache {
        return instance
    }
    
    func getEventsCached() -> Dictionary<String, Event> {
        return cache
    }
    
    func runOnStart() {
        let date = Date()
        for id in cache.keys {
            if let endtime = cache[id]?.endTime {
                switch endtime.compare(date) {
                case .orderedAscending: cache.removeValue(forKey: id)
                default: break
                }
            }
        }
    }
    
    func loadEvent(id: String, completion: @escaping (Result<Event, Error>) -> Void) {
        if let cachedEvent = cache[id] {
            // Use the cached version
            completion(.success(cachedEvent))
            return
        }

        // Create object and store it in the cache
        DatabaseManager.shared.loadEvent(key: id, completion: {result in completion(result)})
    }
    
    func putInCache(newEvent: Event) {
        if (!isInCache(eventId: newEvent.eventId)) {
            increaseSize()
        }
        cache[newEvent.eventId] = newEvent
        checkBounds()
    }
    
    func deleteUser(eventId id: String) {
        if (isInCache(eventId: id)) {
            cache.removeValue(forKey: id)
            decreaseSize()
        }
    }
    
    func isInCache(eventId id: String) -> Bool {
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
            print("Warning: event cache limit set to 0 since values below 0 not allowed.")
            maxByteSize = 0
        } else {
            maxByteSize = newLimit
        }
        if (maxByteSize == 0) {
            print("Warning: event cache limit set to 0 (infinite capacity).")
        }
        checkBounds() // Potential clean up
    }
    
    func getNumberOfUsersInCache() -> Int {
        return cache.count
    }
    
    private func increaseSize() {
        byteSize += EVENT_SIZE
    }
    
    private func decreaseSize() {
        byteSize -= EVENT_SIZE
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

