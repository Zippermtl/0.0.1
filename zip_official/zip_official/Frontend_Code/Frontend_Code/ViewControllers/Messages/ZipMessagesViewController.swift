//
//  MessagesViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//

import UIKit
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserId: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
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
        label.font = .zipBody
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
                $0.otherUserId == DatabaseManager.safeId(id: result.id)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserId, id: targetConversation.id)
                vc.isNewConversation = true
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            } else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: SearchResult){
        let name = result.name
        let userId = result.id
        
        // check in database if conversation with these two uses exists
        // if it does, reuse conversation id
        // otherwise use existing code
        DatabaseManager.shared.conversationExists(with: userId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result{
            case.success(let conversationId):
                let vc = ChatViewController(with: userId, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: userId, id: nil)
                vc.isNewConversation = true
                vc.title = name
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

                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.tableView.isHidden = false
                self?.noConversationsLabel.isHidden = true
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get conversations: \(error)")
            }
            
            
        })
    }
    
    //MARK: - Configure Navigation
    private func configureNavigation(){
        navigationItem.title = "MESSAGES"
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
        return 120
    }
}

extension ZipMessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier ,for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]

        openConversation(model)
    }
    
    func openConversation(_ model: Conversation){
        //show chat messages
        let vc = ChatViewController(with: model.otherUserId, id: model.id)
        vc.title = model.name
        print("title = \(model.name)")
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
