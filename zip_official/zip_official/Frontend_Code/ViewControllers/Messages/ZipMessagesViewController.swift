//
//  MessagesViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//


/*
 
 Fix Double message thingy
 different message types
 push up texts with keyboard
 make the send button better
 audio / other types of messages
 forces picture to crop
 photoview needs to be better - zooming in
 report functionality for message
 see what characters can and cannot be used in messages
 inset space on top and bottom
 liking messages
 group chats
 press and hold preview
 
 */



import UIKit
import JGProgressHUD

class Conversation {
    let id: String
    let otherUser: User
    var latestMessage: LatestMessage
    
    init(id: String, otherUser : User, latestMessage: LatestMessage) {
        self.id = id
        self.otherUser = otherUser
        self.latestMessage = latestMessage
    }
    
    public func markAsRead() {
        self.latestMessage.isRead = true
    }
    
    public func toDict() -> [String: Any] {
        var dict = [String:Any]()
        dict["id"] = id
        dict["name"] = otherUser.fullName
        dict["other_user_id"] = otherUser.userId
        dict["latest_message"] = latestMessage.toDict()
        return dict
    }
}

class LatestMessage {
    let date: Date
    let text: String
    var isRead: Bool
    
    init(date: Date, text: String, isRead: Bool) {
        self.date = date
        self.text = text
        self.isRead = isRead
    }
    
    public func toDict() -> [String:Any] {
        var dict = [String:Any]()
        dict["date"] = date.timeIntervalSince1970
        dict["isRead"] = isRead
        dict["message"] = text
        return dict
    }
}

class ZipMessagesViewController: UIViewController {
    static let title = "MessagesVC"
    
    private let spinner = JGProgressHUD(style: .dark)
    private var loginObserver: NSObjectProtocol?
    private var conversations = [Conversation]()
    var tableView = UITableView()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.font = .zipSubtitle
        label.textColor = .zipLightGray
        return label
    }()
    
    
    @objc private func didTapComposeButton(){
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            let currentConversations = strongSelf.conversations
            
            if let targetConversation = currentConversations.first(where: {
                $0.otherUser.userId == result.userId
            }) {
                let vc = ChatViewController(toUser: targetConversation.otherUser, id: targetConversation.id)
                vc.isNewConversation = true
                vc.title = targetConversation.otherUser.firstName
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            } else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
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
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(toUser: otherUser, id: nil)
                vc.isNewConversation = true
                vc.title = otherUser.firstName
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }    
        })
    }
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        startListeningForConversations()
        configureNavigation()
        configureTable()
        addSubviews()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: self, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversations()
        })
        
    }
    
    private func startListeningForConversations(){
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        guard let myId = UserDefaults.standard.value(forKey: "userId") as? String else {
            return
        }
        
        
        DatabaseManager.shared.getAllConversations(for: myId, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print(conversations)
                guard !conversations.isEmpty else {
                    DispatchQueue.main.async {
                        self?.tableView.isHidden = true
                        self?.noConversationsLabel.isHidden = false
                    }
                    return
                }
                
                self?.conversations = conversations

                DispatchQueue.main.async {
                    self?.tableView.isHidden = false
                    self?.noConversationsLabel.isHidden = true
                    self?.loadCells()
                    self?.tableView.reloadData()
                }
                
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                }
            
                print("failed to get conversations: \(error)")
            }
        })
    }
    
    private func loadCells(){
        for conversation in conversations {
            DatabaseManager.shared.userLoadTableView(user: conversation.otherUser, completion: { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    guard let strongSelf = self else { break }
                    strongSelf.conversations.removeAll(where: { $0.otherUser == conversation.otherUser })
                    print("error loading user in convo Error: \(error)")
                }
            })
            
        }
    }
    
    
    //MARK: - Configure Navigation
    private func configureNavigation(){
        navigationItem.title = "Messages"
        navigationController?.navigationBar.barTintColor = .zipGray
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.zipTitle.withSize(27),
             NSAttributedString.Key.foregroundColor: UIColor.white]
    }
  

    
    

    //MARK: - AddSubviews
    private func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
    }

    
    
    //MARK: Table Config
    private func configureTable(){
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        noConversationsLabel.translatesAutoresizingMaskIntoConstraints = false
        noConversationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noConversationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}


extension ZipMessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension ZipMessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier ,for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        model.otherUser.tableViewCell = cell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        if !model.latestMessage.isRead {
            guard let cell = tableView.cellForRow(at: indexPath) as? ConversationTableViewCell else {
                return
            }
            model.markAsRead()
            cell.markAsRead()
            DatabaseManager.shared.updateConversations(conversations: conversations)
        }
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation){
        //show chat messages
        let vc = ChatViewController(toUser: model.otherUser, id: model.id)
        vc.title = model.otherUser.firstName
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            
            let conversationId = conversations[indexPath.row].id

            tableView.beginUpdates()
            conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                    // add model and row back and show error alert
                    print("failed to delete conversation")
                }
            })
            
            tableView.endUpdates()
        }
    }
    
}
