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

/// Manager object to read and write to firebase
final class DatabaseManager {
    /// Shared instance of  the  class
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private var verificationId: String?
    
    static func safeId(id: String) -> String {
        var safeID = id.replacingOccurrences(of: ".", with: "-")
        safeID = safeID.replacingOccurrences(of: "@", with: "-")
        return safeID
    }
    
    private init(){}

    
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

//MARK: - Account Management
extension DatabaseManager {
    
    /// checks if user exists for given email
    /// parameters
    /// - `email`: Target email to be checked
    ///  - `completion`: async clusire to return with result
    public func userExists(with userId: String, completion: @escaping ((Bool) -> Void)) {
        database.child(userId).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    /// Inserts new user to database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void){
        database.child(user.safeId).setValue([
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "birthday": user.birthdayString
        ], withCompletionBlock: { [weak self] error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            self?.database.child("users").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //append to user dictionary
                    let newElement = [
                        "id": user.safeId,
                        "username": user.username,
                        "name": user.fullName,
                    ]
                    
                    usersCollection.append(newElement)


                    self?.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                    
                } else {
                    //create that array
                    let newCollection: [[String: String]] = [
                        [
                            "id": user.safeId,
                            "username": user.username,
                            "name": user.fullName,
                        ]
                    ]
                    
                    self?.database.child("users").setValue(newCollection, withCompletionBlock: {  error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                        completion(true)
                    })
                }
                
            })
        })
    }
    
    /// Updates the full user profile
    public func updateUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.safeId).updateChildValues([
            "id": user.userId,
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "bio": user.bio,
            "school": user.school ?? "",
            "interests": user.interests.map{ $0.rawValue }
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Gets all users from Firebase
    ///  Parameters
    ///   `completion`: async closure to deal with return result
    public func getAllusers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}

//MARK: - User Data Retreival
extension DatabaseManager {
    public func loadUserProfile(given id: String, completion: @escaping (Result<User, Error>) -> Void) {
        database.child("\(id)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("failed to fetch user profile")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            guard let firstName = value["firstName"] as? String,
                  let lastName = value["lastName"] as? String,
                  let username = value["username"] as? String,
                  let school = value["school"] as? String,
                  let bio = value["bio"] as? String,
                  let interestsInt = value["interests"] as? [Int],
                  let birthdayString = value["birthday"] as? String else {
                      print("retuning here")
                      return
                  }
            
            
            
            let interests = interestsInt.map({Interests(rawValue: $0)!})
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yy"
            let birthday = dateFormatter.date(from: birthdayString)!
            
            let user = User(userId: id,
                            username: username,
                            firstName: firstName,
                            lastName: lastName,
                            birthday: birthday,
                            bio: bio,
                            school: school,
                            interests: interests
            )
                 

            completion(.success(user))

        })
    }
     
    
}


//MARK: - phone auth
extension DatabaseManager {
    public func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: { [weak self] verificationId, error in
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            self?.verificationId = verificationId
            completion(true)
        })
    }
    
    public func verifyCode(smsCode : String, completion: @escaping (Bool) -> Void) {
        guard let verificationId = verificationId else {
            print("verif id dont even work")

            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: smsCode
        )
        
        print("Credential = \(credential)")
        print("verif id = \(verificationId)")
        print("sms code = \(smsCode)")

        
        Auth.auth().signIn(with: credential) { result, error in
            guard result != nil, error == nil else {
                print("completion = false")
                completion(false)
                return
            }
            print("completion = true")

            completion(true)
        }
        
    }
    
    
}

//MARK: - Sending messages / conversations
extension DatabaseManager {
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserId: String, name: String,  firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
              let currentName = AppDelegate.userDefaults.value(forKey: "name") as? String else {
            return
        }
        
        let safeId = DatabaseManager.safeId(id: currentId)

        let ref = database.child("\(safeId)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
        }
            
            let messageData = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageData)
            var message = ""
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
                
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_id" : otherUserId,
                "name" : name,
                "latest_message" : [
                    "date" : dateString,
                    "message" : message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_id" : safeId,
                "name" : currentName,
                "latest_message" : [
                    "date" : dateString,
                    "message" : message,
                    "is_read": false
                ]
            ]
            //update recipient conversation entry
            self?.database.child("\(otherUserId)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserId)/conversations").setValue([conversations])

                } else {
                    // create
                    self?.database.child("\(otherUserId)/conversations").setValue([recipient_newConversationData])
                }
                
                
            })
            
            
            // Update urrent user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode,  withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)

                })
                
               
            } else {
                // conversation array does not exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode,  withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageData = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageData)
        var messageContent = ""
        switch firstMessage.kind {
            
        case .text(let messageText):
            messageContent = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
            
        }
        
        guard let myId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            completion(false)
            return
        }
        

        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": messageContent,
            "date": dateString,
            "sender_email": myId,
            "is_read": false,
            "name" : name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        
        database.child("userConversations/\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
            
        })
    }
    
    /// Fetches and retunrs all conversations for the user with passed in email
    public func getAllConversations(for id: String, completion: @escaping (Result<[Conversation], Error>) -> Void){

        database.child("\(id)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                print("failed to fetch conversations")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool else {
                          return nil
                      }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationID,
                                    name: name,
                                    otherUserId: otherUserId,
                                    latestMessage: latestMessageObject)
                
            })

            completion(.success(conversations))
            
            
        })
    }
    
    /// Gets all Messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        let conversationPath = "userConversations/" + id
        database.child("\(conversationPath)/messages").observe(.value , with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                          return nil
                      }
                
                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "play.fill") else {
                        return nil
                    }
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                } else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
                
            })
            
            completion(.success(messages))
            
            
        })
    }
    
    ///Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserId: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void){
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        guard let currentUserId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            completion(false)
            return
        }
        
        
        let conversationPath = "userConversations/" + conversation
        
        database.child("\(conversationPath)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }

            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageData = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageData)
            var messageContent = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                messageContent = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageContent = targetUrlString
                }
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageContent = targetUrlString
                }
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
                
            }

            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": messageContent,
                "date": dateString,
                "sender_email": currentUserId,
                "is_read": false,
                "name" : name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversationPath)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("error2")

                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentUserId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "message": messageContent,
                        "isRead": false
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String: Any]]  {
                        //shitty code
                        var targetConversation: [String: Any]?
                        var position = 0
                        for conversationDict in currentUserConversations {
                            if let currentId = conversationDict["id"] as? String, currentId == conversation {
                                targetConversation = conversationDict
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        } else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_id" : otherUserId,
                                "name" : name,
                                "latest_message" : updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                        
                        
                    } else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_id" : otherUserId,
                            "name" : name,
                            "latest_message" : messageContent
                        ]
                        
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    
                    
                    strongSelf.database.child("\(currentUserId)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("error3")

                            completion(false)
                            return
                        }
                        completion(true)
                        
                    })
                    
                })
                
                // Update latest messafge for recipient user
                strongSelf.database.child("\(otherUserId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()

                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "message": messageContent,
                        "isRead": false
                    ]
                    
                    guard let currentName = AppDelegate.userDefaults.value(forKey: "name") as? String else {
                        return
                    }
                    
                    if var otherUserConversations = snapshot.value as? [[String: Any]]  {
                        //shitty code
                        var targetConversation: [String: Any]?
                        var position = 0
                        for conversationDict in otherUserConversations {
                            if let currentId = conversationDict["id"] as? String, currentId == conversation {
                                targetConversation = conversationDict
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            otherUserConversations[position] = targetConversation
                            databaseEntryConversations = otherUserConversations
                        } else {
                            // failed to find in current collection
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_id" : otherUserId,
                                "name" : currentName,
                                "latest_message" : updatedValue
                            ]
                            otherUserConversations.append(newConversationData)
                            databaseEntryConversations = otherUserConversations
                        }
                        
                    } else {
                        //current conversation does not exist
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_id" : currentUserId,
                            "name" : currentName,
                            "latest_message" : updatedValue
                        ]
                        
                        databaseEntryConversations = [
                            newConversationData
                        ]

                    }
                            
                    strongSelf.database.child("\(otherUserId)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                        
                    })
                })
            })
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let myId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
                
        print("Deleting conversation with id: \(conversationId)...")
        
        // get all conversations for a current user
        // delete conversations in collection with target id
        // reset those conversations for the user in database
        
        let ref = database.child("\(myId)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to write new conversation array")
                        return
                    }
                    print("deleted conversation")
                    completion(true)
                })
            }
        })
    }
    
    public func conversationExists(with targetRecipientId: String, completion: @escaping (Result<String,Error>) -> Void) {
        guard let senderId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
                
        database.child("\(targetRecipientId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderId = $0["other_user_id"] as? String else {
                    return false
                }
                return senderId == targetSenderId
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
            return
            
        })
        
    }
    
}
