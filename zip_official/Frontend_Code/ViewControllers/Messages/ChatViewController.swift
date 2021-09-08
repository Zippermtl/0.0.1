//
//  ChatViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/26/21.
//

import UIKit
//import Foundation
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController {
    let currentUser = Sender(senderId: "self",displayName: "Yianni Zavaliagkos")
    let otherUser = Sender(senderId: "other",displayName: "Ezra Taylor")
    
    var messages: [MessageType] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        
        messages.append(Message(sender: currentUser,
                                messageId: "1",
                                sentDate: Date().addingTimeInterval(-86400),
                                kind: .text("Hello World")))
        
        messages.append(Message(sender: otherUser,
                                messageId: "2",
                                sentDate: Date().addingTimeInterval(-70000),
                                kind: .text("How is it going")))
        
        messages.append(Message(sender: currentUser,
                                messageId: "3",
                                sentDate: Date().addingTimeInterval(-60000),
                                kind: .text("Here is a long reply. Here is a long reply. Here is a long reply. Here is a long reply. Here is a long reply.")))
        
        messages.append(Message(sender: otherUser,
                                messageId: "4",
                                sentDate: Date().addingTimeInterval(-50000),
                                kind: .text("Test test Test")))
        
        messages.append(Message(sender: currentUser,
                                messageId: "5",
                                sentDate: Date().addingTimeInterval(-40000),
                                kind: .text("yes")))
        
        messages.append(Message(sender: otherUser,
                                messageId: "6",
                                sentDate: Date().addingTimeInterval(-30000),
                                kind: .text("Lit")))
        
        
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//
//
//        messagesCollectionView.backgroundColor = .zipGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }


}


extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        print("current user is being returned")
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        print("message is coming")
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print(messages.count)
        return messages.count
    }
    
    func messageTopLabelAttributedText(
      for message: MessageType,
      at indexPath: IndexPath) -> NSAttributedString? {
      
      return NSAttributedString(
        string: message.sender.displayName,
        attributes: [.font: UIFont.zipBody])
    }
    
    
}

extension ChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
        at indexPath: IndexPath,
        with maxWidth: CGFloat,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.backgroundColor = .zipLightGray
    }
    
}

//extension ChatViewController: InputBarAccessoryViewDelegate {
//  func messageInputBar(
//    _ inputBar: InputBarAccessoryView,
//    didPressSendButtonWith text: String) {
//
//    let newMessage = Message(
//      member: member,
//      text: text,
//      messageId: UUID().uuidString)
//
//    messages.append(newMessage)
//    inputBar.inputTextView.text = ""
//    messagesCollectionView.reloadData()
//    messagesCollectionView.scrollToLastItem(animated: true)
//  }
//}

