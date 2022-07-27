//
//  DatabaseManager.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/5/21.
//

import Foundation
import FirebaseDatabase
import MessageKit
import FirebaseAuth
import CoreLocation
import FirebaseFirestore




/// Manager object to read and write to firebase
class DatabaseManager {
    /// Shared instance of  the  class
    static let shared = DatabaseManager()
    
    internal let database = Database.database().reference()
    internal let firestore = Firestore.firestore()

    internal var verificationId: String?
    
    
    init(){}

    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}

extension DatabaseManager {
    
    /// returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
}
