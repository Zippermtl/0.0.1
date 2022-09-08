//
//  ChatViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/26/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit

// EVENTUAL SEND LOCATION IMPLEMENTATION
// https://www.youtube.com/watch?v=uRVA4VCxtvc&ab_channel=iOSAcademy


struct Sender: SenderType {
    public var photoURL: URL?
    public var senderId: String
    public var displayName: String
}


struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case  .photo(_):
            return "photo"
        case  .video(_):
            return "video"
        case  .location(_):
            return "location"
        case  .emoji(_):
            return "emoji"
        case  .audio(_):
            return "audio"
        case  .contact(_):
            return "contact"
        case  .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale  = .current
        return formatter
    } ()
    
    public var isNewConversation = false
    public var otherUserId: String
    private var conversationId: String?

    private var senderPhotoURL: URL?
    private var otherPhotoURL: URL?
    
    private let sendButton: InputBarSendButton
    
    
    private var selfSender: Sender? = {
        guard let myId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
              let myName = AppDelegate.userDefaults.value(forKey: "name") as? String,
              let pfpString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String else {
            return nil
        }
        
        return Sender(photoURL: URL(string: pfpString),
                      senderId: myId,
                      displayName: myName)
    }()
    
    
    public let otherUser: Sender
    
    var messages: [MessageType] = []
    
    init(toUser otherUser: User, id: String?){
        conversationId = id
        otherUserId = otherUser.userId
        sendButton = InputBarSendButton()

        self.otherUser = Sender(photoURL: otherUser.profilePicUrl, senderId: otherUser.userId, displayName: otherUser.fullName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        view.backgroundColor = .zipGray
        messagesCollectionView.backgroundColor = .zipGray
        showMessageTimestampOnSwipeLeft = true
        messagesCollectionView.register(MessageDateReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)

        scrollsToLastItemOnKeyboardBeginsEditing = true
    
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        messageInputBar.delegate = self
        messageInputBar.tintColor = .white
        messageInputBar.contentView.backgroundColor = .zipLightGray
        messageInputBar.middleContentView?.tintColor = .zipVeryLightGray
        messageInputBar.backgroundView.backgroundColor = .zipGray
        
        sendButton.setup()
        sendButton.backgroundColor = .zipBlue
        sendButton.setSize(CGSize(width: 35, height: 35), animated: false)
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
        let img = UIImage(systemName: "arrow.up", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        sendButton.setImage(img, for: .normal)
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 35/2

        
        sendButton.onTouchUpInside({ [weak self] _ in
            self?.sendMessage()
        })

        let attatchmentButton = InputBarButtonItem()
        attatchmentButton.setSize(CGSize(width: 35, height: 35), animated: false)
        attatchmentButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attatchmentButton.onTouchUpInside({ [weak self] _ in
            self?.presentInputActionSheet()
        })
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([attatchmentButton], forStack: .left, animated: false)
        
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([sendButton], forStack: .right, animated: false)
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageInputBar.contentView.layer.cornerRadius = messageInputBar.contentView.frame.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attatch",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio",
                                            style: .default,
                                            handler: { _ in
             
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil ))
        
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attatch a photo from",
                                            preferredStyle: .actionSheet)
            
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        

        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attatch a Video from",
                                            preferredStyle: .actionSheet)
            
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        

        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
            
            
            
        })
    }



}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessage()
    }
    
    @objc private func sendMessage(){
       
        guard let text = messageInputBar.inputTextView.text,
              !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageID = createMessageId()
        else {
            print("error here \(messageInputBar.inputTextView.text)")
            return
        }
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        
        // Send Message
        if isNewConversation {
            //create convo in database
            DatabaseManager.shared.createNewConversation(with: otherUserId, name: otherUser.displayName, firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    
                    DispatchQueue.main.async {
                        self?.messageInputBar.inputTextView.text = nil
                    }
                } else {
                    print("failed to create new conversation")
                }
            })
        } else {
            guard let conversationId = self.conversationId else {
                print("Failed to find messageId")
                return
            }
            //append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserId: otherUserId, name: otherUser.displayName, newMessage: message) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.messageInputBar.inputTextView.text = nil
                    }
                    print("message sent")
                } else {
                    print("failed to send")
                }
            }
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, Senderemail, RandomInt
        guard let currentUserId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return ""
        }
        
        let dateString = Self.dateFormatter.string(from: Date())
 
        let newIdentifier = "\(otherUserId)_\(currentUserId)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cashed")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelAttributedText(
      for message: MessageType,
      at indexPath: IndexPath) -> NSAttributedString? {
      
      return NSAttributedString(
        string: message.sender.displayName,
        attributes: [.font: UIFont.zipTextFill])
    }
    
  
    func heightForLocation(message: MessageType,
        at indexPath: IndexPath,
        with maxWidth: CGFloat,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }

    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case.photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // user message
            return .link
        } else {
            // other message
            return .zipLightGray
        }
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        let sender = message.sender
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        var vc : UIViewController
        if sender.senderId != selfId { vc = OtherProfileViewController(id: sender.senderId) }
        else { vc = ProfileViewController(id: selfId) }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            // show our image
            if let pfpUrl = selfSender?.photoURL {
                avatarView.sd_setImage(with: pfpUrl, completed: nil)
            } else {
                avatarView.image = UIImage(named: "defaultProfilePic")
            }
        } else {
            //other image
            if let otherPfpUrl = otherUser.photoURL {
                avatarView.sd_setImage(with: otherPfpUrl, completed: nil)
            } else {
                avatarView.image = UIImage(named: "defaultProfilePic")
            }
        }
    }
    
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case.photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case.video(let media):
            guard let videoUrl = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            
            present(vc, animated: true)
            
        default:
            break
        }
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let messageDate = message.sentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.string(from: messageDate)
        return NSAttributedString(string: dateString, attributes: [.font: UIFont.zipTextDetail])
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        
        // get previous message
        let previousIndexPath = IndexPath(row: 0, section: indexPath.section - 1)
        let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        
        if message.sentDate.isInSameDay(as: previousMessage.sentDate) {
            return false
        }
        
        return true
    }
        
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        let size = CGSize(width: messagesCollectionView.frame.width, height: 50)
        if section == 0 {
            return size
        }
        
        let currentIndexPath = IndexPath(row: 0, section: section)
        let lastIndexPath = IndexPath(row: 0, section: section - 1)
        let lastMessage = messageForItem(at: lastIndexPath, in: messagesCollectionView)
        let currentMessage = messageForItem(at: currentIndexPath, in: messagesCollectionView)
        
        if currentMessage.sentDate.isInSameDay(as: lastMessage.sentDate) {
            return .zero
        }
        
        return size
    }
    
    func messageHeaderView(
        for indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageReusableView {
        let messsage = messageForItem(at: indexPath, in: messagesCollectionView)
        let header = messagesCollectionView.dequeueReusableHeaderView(MessageDateReusableView.self, for: indexPath)
        header.label.text = MessageKitDateFormatter.shared.string(from: messsage.sentDate)
        return header
    }


    
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        
        
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let name = title,
              let selfSender = selfSender else {
                  return
              }
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            //photo
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result{
                case .success(let urlString):
                    // Ready to send message
                    print("uploaded message photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserId: strongSelf.otherUserId, name: name, newMessage: message, completion: { success in
                        if success {
                            print("sent photo messaage")
                        } else {
                            print("failed to send photo messaage")
                        }
                        
                        
                    })
                case .failure(let error):
                    print("Message photo upload error: \(error)")
                }
                
            })
            //send message
        } else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            // Upload Video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result{
                case .success(let urlString):
                    // Ready to send message
                    print("uploaded message video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserId: strongSelf.otherUserId, name: name, newMessage: message, completion: { success in
                        if success {
                            print("sent video messaage")
                        } else {
                            print("failed to send video messaage")
                        }
                        
                        
                    })
                case .failure(let error):
                    print("Message video upload error: \(error)")
                }
            })
            
        }
    }
    
    
    
}


class MessageDateReusableView: MessageReusableView {
    var label: PaddingLabel!

    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = .none

        label = PaddingLabel()
        label.backgroundColor = .clear
        label.textColor = .zipVeryLightGray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .zipTextDetail
        label.paddingLeft = 5
        label.paddingRight = 5
        self.addSubview(label)

        label.clipsToBounds = true
        label.layer.cornerRadius = 3
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaddingLabel: UILabel {

    var textEdgeInsets = UIEdgeInsets.zero {
         didSet { invalidateIntrinsicContentSize() }
     }
     
     open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
         let insetRect = bounds.inset(by: textEdgeInsets)
         let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
         let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
         return textRect.inset(by: invertedInsets)
     }
     
     override func drawText(in rect: CGRect) {
         super.drawText(in: rect.inset(by: textEdgeInsets))
     }
     
     
     var paddingLeft: CGFloat {
         set { textEdgeInsets.left = newValue }
         get { return textEdgeInsets.left }
     }
     
     var paddingRight: CGFloat {
         set { textEdgeInsets.right = newValue }
         get { return textEdgeInsets.right }
     }
     
     var paddingTop: CGFloat {
         set { textEdgeInsets.top = newValue }
         get { return textEdgeInsets.top }
     }
     
     var paddingBottom: CGFloat {
         set { textEdgeInsets.bottom = newValue }
         get { return textEdgeInsets.bottom }
     }
 }
