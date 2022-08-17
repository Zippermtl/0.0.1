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
        case failedToSyncStorage
    }
    
}

extension DatabaseManager {
    ///  writes error to database log
    public func writeError(note: String, error: Error) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = dateFormatter.string(from: Date())
        print(dateString)
        let errorString: String = "\(error)"
        
        let userId = (AppDelegate.userDefaults.value(forKey: "userId") as? String) ?? "AuthError"
        let errorData: [String:[String:Any]] = [dateString.description : [
            "error" : errorString,
            "localizedDescription" : error.localizedDescription,
            "note" : note
        ]]
        firestore.collection("ErrorLog").document(userId).setData(errorData, merge: true)
    }
    
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


//MARK: - phone auth
extension DatabaseManager {
    public func startAuth(phoneNumber: String, completion: @escaping (Error?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
            guard error == nil else {
                print("error verifying phone numer, Error: \(error!)")
                self?.writeError(note: "auth error", error: error!)
                completion(error!)
                return
            }
            self?.verificationId = verificationId
            completion(nil)
        }
    }
    
    public func verifyCode(smsCode : String, completion: @escaping (Error?) -> Void) {
        guard let verificationId = verificationId else {
            print("verif id dont even work")
            let error = VerificationCodeError.incorrectCodeError
            completion(error)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: smsCode
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard error == nil else {
                self?.writeError(note: "verification error", error: error!)
                completion(error)
                return
            }
            
            guard result != nil else {
                completion(nil)
                return
            }

            completion(nil)
        }
        
    }
    
    
}


public enum VerificationCodeError: Error, LocalizedError {
    case incorrectCodeError
    
    public var errorDescription: String? {
        switch self {
        case .incorrectCodeError:
            return NSLocalizedString("Incorrect Verification Code", comment: "Incorrect Verification Code")
        }
    }
}
