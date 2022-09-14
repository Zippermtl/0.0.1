//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


import UIKit
import MapKit
import CoreLocation
import SDWebImage
import JGProgressHUD


class OtherProfileViewController: AbstractProfileViewController  {
    private var messageButton: IconButton
    
    init(id: String) {
        self.messageButton = IconButton.messageIcon()
        let actionButtonInfo = ("Zipped", UIColor.zipBlue)
        let reportIcon = UIImage(systemName: "ellipsis")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        
        super.init(id: id,
                   B1: IconButton.eventsIcon(),
                   B2: IconButton.zipsIcon(),
                   B3: IconButton.inviteIcon(),
                   rightBarButtonIcon: reportIcon,
                   centerActionInfo: actionButtonInfo
        )
        
        
       
        
        configureMessageButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didTapRightBarButton() {
        let vc = ReportViewController(user: user)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerActionButton.layer.borderColor = UIColor.zipBlue.cgColor
    }

    override func initUser() {
        fetchUser(completion: { [weak self] in
            guard let strongSelf = self else { return }
            switch strongSelf.user.friendshipStatus {
            case .ACCEPTED:
                strongSelf.setZippedState()
            case .REQUESTED_OUTGOING:
                strongSelf.setRequestedState()
            case .REQUESTED_INCOMING:
                strongSelf.setIncomingRequestState()
            default:
                strongSelf.setNoRelationState()
            }
        })
    }
    
    
    
    override func didTapCenterActionButton() {
        switch user.friendshipStatus {
        case .ACCEPTED:
            let actionSheet = UIAlertController(title: "Are you sure you would like to unzip \(user.fullName)",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Yes",
                                                style: .default,
                                                handler: { [weak self] _ in
                                                    
                self?.user.unfriend(completion: { [weak self] err in
                    guard err == nil else {
                        return
                    }
                    self?.setNoRelationState()
                })
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "No",
                                                style: .cancel,
                                                handler: nil))
            
            present(actionSheet, animated: true)
        case .REQUESTED_OUTGOING:
            user.unsendRequest(completion: { [weak self] err in
                guard err == nil else {
                    return
                }
                self?.setNoRelationState()
            })
        case .REQUESTED_INCOMING: // You have now accepted the follow request
            user.acceptRequest(completion: { [weak self] err in
                guard err == nil else {
                    return
                }
                self?.setZippedState()
            })
        case .none:
            user.sendRequest(completion: { [weak self] err in
                guard err == nil else {
                    return
                }
                self?.setRequestedState()
            })
            
        }
    }
    
    private func setRequestedState(){
        centerActionButton.setTitle("Requested", for: .normal)
        centerActionButton.backgroundColor = .zipLightGray
        centerActionButton.layer.borderWidth = 0
    }
    
    private func setNoRelationState(){
        centerActionButton.setTitle("Zip", for: .normal)
        centerActionButton.backgroundColor = .zipBlue
        centerActionButton.layer.borderWidth = 0
    }
    
    private func setZippedState(){
        centerActionButton.setTitle("Zipped", for: .normal)
        centerActionButton.backgroundColor = .zipLightGray
        centerActionButton.layer.borderWidth = 0
    }
    
    private func setIncomingRequestState() {
        centerActionButton.setTitle("Zip Back", for: .normal)
        centerActionButton.backgroundColor = .zipBlue
        centerActionButton.layer.borderWidth = 0
    }
    

    
    override func didTapB1Button() {
        DatabaseManager.shared.getMutualEvents(userId: user.userId, completion: {[weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                let vc = MasterTableViewController(multiSectionData: data)
                vc.title = "\(strongSelf.user.firstName)'s Events"
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_): break
            }
        })
    }
    
    override func didTapB2Button() {
  
        let vc = MasterTableViewController(cellData: [], cellType: CellType(userType: .zipList))

        DatabaseManager.shared.loadUserZipsIds(given: user.userId, completion: { result in
            switch result {
            case .success(let users):
                print("loading ezras friends \(users)")
                vc.reload(cellItems: users)
            case .failure(let error):
                print("failure loading other users ids, Error: \(error)")
            }
        })
        vc.title = "\(user.firstName)'s Zips"
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
    override func didTapB3Button() {
        
        let vc = InviteTableViewController(items: User.getUDEvents(toKey: .hostedEvents))
        vc.saveFunc = { [weak self] items in
            guard let strongSelf = self else { return }
            let events = items.map({ $0 as! Event })
            var idx = 0
            for event in events {
                DatabaseManager.shared.inviteUsers(event: event, users: [strongSelf.user], completion: { [weak self] error in
                    guard let strongSelf = self,
                          error == nil else {
                        idx+=1
                        return
                    }
                    idx+=1
                    if idx == events.count {
                        DispatchQueue.main.async {
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
        
        vc.title = "Invite \(user.firstName)"

        navigationController?.pushViewController(vc, animated: true)
    }
 
    
    override func didTapPhotos() {
        let vc = UserPhotosViewController()
        vc.configure(user: user)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    private func configureMessageButton(){
        messageButton.iconAddTarget(self, action: #selector(didTapMessage), for: .touchUpInside)
        messageButton.setIconDimension(width: 60)
        messageButton.iconLabel.isHidden = true
        messageButton.iconButton.backgroundColor = .zipBlue
        messageButton.iconButton.layer.shadowColor = UIColor.black.cgColor
        messageButton.iconButton.layer.shadowOpacity = 0.5
        messageButton.iconButton.layer.shadowOffset = CGSize(width: 1, height: 4)
        messageButton.iconButton.layer.shadowRadius = 2
        messageButton.iconButton.layer.masksToBounds = false
        view.addSubview(messageButton)
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -10).isActive = true
        messageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
    }
    
    @objc private func didTapMessage(){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        DatabaseManager.shared.getAllConversations(for: selfId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversations):
                if let targetConversation = conversations.first(where: {
                    $0.otherUser.userId == strongSelf.user.userId
                }) {
                    let vc = ChatViewController(toUser: targetConversation.otherUser, id: targetConversation.id)
                    vc.isNewConversation = false
                    vc.title = targetConversation.otherUser.firstName
                    vc.modalPresentationStyle = .overCurrentContext
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                } else {
                    strongSelf.createNewConversation(result: strongSelf.user)
                }
            case .failure(_):
                strongSelf.createNewConversation(result: strongSelf.user)
            }
        })
    }
    
    private func createNewConversation(result otherUser: User){
        // check in database if conversation with these two uses exists
        // if it does, reuse conversation id
        // otherwise use existing code
        DatabaseManager.shared.conversationExists(with: otherUser.userId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result{
            case.success(let conversationId):
                let vc = ChatViewController(toUser: otherUser, id: conversationId)
                vc.isNewConversation = false
                vc.title = otherUser.firstName
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.modalPresentationStyle = .overCurrentContext
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(toUser: otherUser, id: nil)
                vc.isNewConversation = true
                vc.title = otherUser.firstName
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.modalPresentationStyle = .overCurrentContext
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
   
    

}
