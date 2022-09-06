//
//  DatabaseManagerMessage.swift
//  zip_official
//
//  Created by user on 7/27/22.
//

import Foundation
import FirebaseDatabase
import MessageKit
import FirebaseAuth
import CoreLocation
import FirebaseFirestore

//MARK: - Sending messages / conversations
extension DatabaseManager {
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserId: String, name: String,  firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        guard let currentId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
              let currentName = AppDelegate.userDefaults.value(forKey: "name") as? String else {
                  print("failed before starting")
                  return
              }
        
        
        
        
        let messageSentDate = firstMessage.sentDate
        let dateInt = messageSentDate.timeIntervalSince1970
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
                "date" : dateInt,
                "message" : message,
                "isRead": false
            ]
        ]
        
        let recipient_newConversationData: [String: Any] = [
            "id": conversationId,
            "other_user_id" : currentId,
            "name" : currentName,
            "latest_message" : [
                "date" : dateInt,
                "message" : message,
                "isRead": false
            ]
        ]
        
        
        //update recipient conversation entry
        database.child("userConvos/\(otherUserId)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                // append
                conversations.append(recipient_newConversationData)
                self?.database.child("userConvos/\(otherUserId)").setValue(conversations)
                
            } else {
                // create
                self?.database.child("userConvos/\(otherUserId)").setValue([recipient_newConversationData])
            }
        })
        
        database.child("userConvos/\(currentId)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                // append
                conversations.append(newConversationData)
                self?.database.child("userConvos/\(currentId)").setValue(conversations, withCompletionBlock: { [weak self] error , _ in
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
                // create
                self?.database.child("userConvos/\(currentId)").setValue([newConversationData], withCompletionBlock: { [weak self] error , _ in
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
        let messageDate = firstMessage.sentDate
        let dateInt = messageDate.timeIntervalSince1970
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
            "date": dateInt,
            "sender_email": myId,
            "isRead": false,
            "name" : name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        
        database.child("allConversations/\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
            
        })
    }
    
    /// Fetches and retunrs all conversations for the user with passed in email
    public func getAllConversations(for id: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        
        database.child("userConvos/\(id)").observe(.value, with: { snapshot in
            print("value = \(snapshot.value!)")
//            print("id = \(snapshot.value!["id"])")

            print("value type = \(type(of:snapshot.value))")

            guard let value = snapshot.value as? [[String: Any]] else {
                print("failed to fetch conversations")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            var conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let dateInt = latestMessage["date"] as? Double,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool else {
                          return nil
                      }
                let date = Date(timeIntervalSince1970: dateInt)
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                let otherUser = User(userId: otherUserId)
                let components = name.split(separator: " ")
                otherUser.firstName = String(components[0])
                otherUser.lastName = String(components[1])
                return Conversation(id: conversationID,
                                    otherUser: otherUser,
                                    latestMessage: latestMessageObject)
                
            })
            conversations.sort(by: { $0.latestMessage.date >= $1.latestMessage.date })
            completion(.success(conversations))
        })
    }
    
    /// Gets all Messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("allConversations/\(id)/messages").observe(.value , with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateInt = dictionary["date"] as? Double else {
                          return nil
                      }
                let date = Date(timeIntervalSince1970: dateInt)
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
                          let placeHolder = UIImage(systemName: "play") else {
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
                
                let sender = Sender(photoURL: nil, senderId: senderEmail, displayName: name)
                
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
        
        let conversationPath = "allConversations/\(conversation)/messages"
        
        database.child("\(conversationPath)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }

            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateInt = messageDate.timeIntervalSince1970
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
                "date": dateInt,
                "sender_email": currentUserId,
                "isRead": false,
                "name" : name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversationPath)").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("error2")
                    completion(false)
                    return
                }
                
                strongSelf.database.child("userConvos/\(currentUserId)").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateInt,
                        "message": messageContent,
                        "isRead": true
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
                    
                    
                    
                    strongSelf.database.child("userConvos/\(currentUserId)").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("error3")

                            completion(false)
                            return
                        }
                        completion(true)
                        
                    })
                    
                })
                
                // Update latest messafge for recipient user
                strongSelf.database.child("userConvos/\(otherUserId)").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()

                    let updatedValue: [String: Any] = [
                        "date": dateInt,
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
                            
                    strongSelf.database.child("userConvos/\(otherUserId)").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
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
        
        let ref = database.child("userConvos/\(myId)")
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
                
        database.child("userConvos/\(targetRecipientId)").observeSingleEvent(of: .value, with: { snapshot in
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
