//
//  EventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import UIKit
import MapKit
import CoreLocation
import JGProgressHUD
import DropDown


class EventViewController: UIViewController {
    //MARK: Event Data
    var event: Event
    private var timer: Timer!
    private var isGoing: Bool
    private var isNotGoing : Bool
    private var isSaved: Bool
    private var isReapearing: Bool
    
    
    private let refreshControl: UIRefreshControl

    let titleLabel: UILabel


    // MARK: - SubViews

    //    private var pictureCollectionView: UICollectionView!
    let tableView: UITableView
    let tableHeader: UIView
    private let tableFooter: UIView
    
    private let liveView: UIView
    
    let eventBorder: UIView
    let eventPhotoView: UIImageView
    private let spinner: JGProgressHUD
    
    // MARK: - Labels
    let countDownLabel: UILabel
    let hostLabel: UILabel
    let userCountLabel: UILabel
    let eventTypeLabel: UILabel
    
    // MARK: - Buttons
    let goingButton: UIButton
    var goingDD: DropDown
    var inviteButton: UIButton?
    
    let saveButton: IconButton
    let messageButton: IconButton
    let participantsButton: IconButton
    
    var cellConfigurations : [(NSMutableAttributedString, UIImage?)]
    var locationCell : UITableViewCell?
    var distanceCell : UITableViewCell?
    var dateCell : UITableViewCell?
    var timeCell : UITableViewCell?
    var descriptionCell : UITableViewCell?
    var priceCell: UITableViewCell?
    var linkCell: UITableViewCell?
    
    private var reportView : ReportMessageView


    init(event: Event) {
        self.event = event
        self.isGoing = false
        self.isNotGoing = false
        self.isSaved = false
        self.isReapearing = false
        self.refreshControl = UIRefreshControl()
        self.tableView = UITableView()
        self.tableFooter = UIView()
        self.tableHeader = UIView()
        self.eventPhotoView = UIImageView()
        self.spinner = JGProgressHUD(style: .light)
        self.countDownLabel = UILabel.zipTitle()
        self.hostLabel = UILabel.zipTextPrompt()
        self.titleLabel = UILabel.zipHeader()
        self.eventTypeLabel = UILabel.zipSubtitle2()
        self.userCountLabel = UILabel.zipTextPrompt()
        self.eventBorder = UIView()
        userCountLabel.textColor = .zipVeryLightGray
        self.goingButton = UIButton()
        self.goingDD = DropDown()
        self.messageButton = IconButton.messageIcon()
        self.messageButton.setTextLabel(s: "Contact")
        let saveConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        self.saveButton = IconButton(text: "Save",
                                     icon: UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                     config: saveConfig)
        
        
        saveButton.iconButton.setImage(UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
            .withConfiguration(saveConfig), for: .selected)
        
        self.participantsButton = IconButton.participantsIcon()
        self.liveView = UIView()
        self.cellConfigurations = []
        self.inviteButton = nil
        reportView = ReportMessageView()
        reportView.isHidden = true
        super.init(nibName: nil, bundle: nil)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
        if event.usersGoing.contains(User(userId: userId)) {
            goingUI()
        } else if event.usersNotGoing.contains(User(userId: userId)) {
            notGoingUI()
        }
        
        let savedEvents = User.getUDEvents(toKey: .savedEvents)
        if savedEvents.contains(event) {
            savedUI()
        }
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let img = UIImage(systemName: "chevron.compact.up", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        
        hostLabel.isUserInteractionEnabled = true
        let hostTap = UITapGestureRecognizer(target: self, action: #selector(didTapHost))
        hostLabel.addGestureRecognizer(hostTap)
        
        userCountLabel.isUserInteractionEnabled = true
        let userTap = UITapGestureRecognizer(target: self, action: #selector(didTapParticipantsButton))
        userCountLabel.addGestureRecognizer(userTap)
        
        eventBorder.layer.borderWidth = 6
        eventBorder.backgroundColor = .clear
        eventBorder.layer.borderColor = UIColor.clear.cgColor

        
        liveView.backgroundColor = .red
        liveView.isHidden = true
        liveView.layer.masksToBounds = true
        
        let dismissReportTap = UITapGestureRecognizer(target: self, action: #selector(dismissReport))
        tableView.addGestureRecognizer(dismissReportTap)
        dismissReportTap.cancelsTouchesInView = false
        
        countDownLabel.textAlignment = .center
        
        configureGoingButton()
        configureNavBar()
        configureTable()
        configureRefresh()
        fetchEvent(completion: { [weak self] in
            guard let refreshControl = self?.refreshControl else {
                return
            }
            refreshControl.endRefreshing()
        })
    }
    
    public func configureGoingButton(){
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }

        
        goingButton.backgroundColor = .zipLightGray
        goingButton.setTitle("RSVP", for: .normal)
        goingButton.titleLabel?.font = .zipSubtitle2
        if event.usersGoing.contains(User(userId: userId)) {
            goingUI()
        }
        if event.usersNotGoing.contains(User(userId: userId)) {
           notGoingUI()
        }
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipSubtitle2
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
        
        goingDD.anchorView = goingButton
        goingDD.dismissMode = .onTap
        goingDD.direction = .bottom
        goingDD.textFont = .zipSubtitle2
        goingDD.dataSource = ["Going", "Not Going"]
        goingDD.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Going" {
                self.markGoing()
            } else {
                self.markNotGoing()
            }
            
            guard let cell = event.tableViewCell else {
                return
            }
            
            cell.configure(event)
        }
    }
    
    public func configureInviteButton() {
        
        if event.allowUserInvites {
            inviteButton = UIButton()
            
            inviteButton!.backgroundColor = .zipLightGray
            inviteButton!.setTitle("Invite", for: .normal)
            inviteButton!.titleLabel?.textColor = .white
            inviteButton!.titleLabel?.font = .zipSubtitle2
            inviteButton!.titleLabel?.textAlignment = .center
            inviteButton!.contentVerticalAlignment = .center

            tableHeader.addSubview(inviteButton!)
            inviteButton!.translatesAutoresizingMaskIntoConstraints = false
            inviteButton!.widthAnchor.constraint(equalToConstant: 100).isActive = true
            inviteButton!.heightAnchor.constraint(equalToConstant: 30).isActive = true
            inviteButton!.topAnchor.constraint(equalTo: goingButton.topAnchor).isActive = true
            inviteButton!.leftAnchor.constraint(equalTo: tableHeader.centerXAnchor, constant: 5).isActive = true
            
            goingButton.rightAnchor.constraint(equalTo: tableHeader.centerXAnchor, constant: -5).isActive = true
            
            inviteButton!.layer.cornerRadius = 8
            inviteButton!.addTarget(self, action: #selector(didTapInviteButton), for: .touchUpInside)
            tableHeader.bringSubviewToFront(inviteButton!)

        } else {
            if  let inviteButton = inviteButton,
                let _ = inviteButton.superview {
                inviteButton.removeFromSuperview()
            }
            inviteButton = nil
            goingButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissReport(){
        slideDown(view: reportView, completion: { b in })
    }

    @objc private func refresh(){        
        fetchEvent(completion: { [weak self] in
            guard let refreshControl = self?.refreshControl else {
                return
            }
            refreshControl.endRefreshing()
        })
    }
    
    //MARK: - Button Actions
    @objc func didTapReportButton(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { [weak self] _ in
            
            let reportAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            for context in ReportContext.allCases {
                reportAlert.addAction(UIAlertAction(title: context.description, style: .default, handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.reportView.update(context: context)
                    strongSelf.slideUp(view: strongSelf.reportView, completion: { b in })
                }))
            }
            
            
            reportAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                
            }))
            
            self?.present(reportAlert, animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        
        present(alert, animated: true)
    }
    

    
    private func markGoing(){
        if event.endTime <= Date() {
            let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot RSVP to expired events", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let selfUser = User(userId: userId)
        if !event.usersGoing.contains(selfUser) {
            event.markGoing(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                
                guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
                
                if let idx = strongSelf.event.usersNotGoing.firstIndex(of: User(userId: userId)) {
                    strongSelf.event.usersNotGoing.remove(at: idx)
                }
                strongSelf.event.usersGoing.append(User(userId: userId))
                
                DispatchQueue.main.async {
                    strongSelf.goingUI()
                    strongSelf.userCountLabel.text = String(strongSelf.event.usersGoing.count) + " participants"
                }
            })
        }
    }
    
    private func markNotGoing() {
        if event.endTime <= Date() {
            let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot RSVP to expired events", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let selfUser = User(userId: userId)

        if !event.usersNotGoing.contains(selfUser) {
            event.markNotGoing(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                
                guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
                
                if let idx = strongSelf.event.usersGoing.firstIndex(of: User(userId: userId)) {
                    strongSelf.event.usersGoing.remove(at: idx)
                }
                strongSelf.event.usersNotGoing.append(User(userId: userId))
                
                DispatchQueue.main.async {
                    strongSelf.notGoingUI()
                    strongSelf.userCountLabel.text = String(strongSelf.event.usersGoing.count) + " participants"
                }
            })
        }
    }
    
    @objc func didTapGoingButton(){
        goingDD.show()
    }
    
    private func goingUI(){
        goingButton.setTitle("Going", for: .normal)
        isGoing = true
        isNotGoing = false
        goingButton.backgroundColor = .zipGoingGreen
    }
    
    private func notGoingUI() {
        goingButton.setTitle("Not Going", for: .normal)
        isGoing = false
        isNotGoing = true
        goingButton.backgroundColor = .zipGray
    }
    
    @objc func didTapParticipantsButton(){
        let vc = MasterTableViewController(sectionData: event.getParticipants())
        
        vc.title = "Participants"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapInviteButton(){
        if event.endTime <= Date() {
            let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot invite people to expired events", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let vc = InviteTableViewController(items: User.getMyZips().filter({ user in
            return !(event.usersInvite.contains(user) || event.usersGoing.contains(user) || event.usersNotGoing.contains(user))
        }))
        vc.dispearingRightButton = true
        vc.saveFunc = { [weak self] items in
            guard let event = self?.event else { return }
            let users = items.map({ $0 as! User })
            event.usersInvite += users
            DatabaseManager.shared.inviteUsers(event: event, users: users, completion: { [weak self] error in
                guard error == nil else {
                    let alert = UIAlertController(title: "Error Inviting Users",
                                                  message: "\(error!.localizedDescription)",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok",
                                                  style: .cancel,
                                                  handler: { _ in }))
                    DispatchQueue.main.async {
                        self?.present(alert, animated: true)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        }
        vc.title = "Invite"
        navigationController?.pushViewController(vc, animated: true)
    }
    
  
    
    
    @objc func didTapMessageButton(){
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        DatabaseManager.shared.getAllConversationsInstance(for: selfId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            let components = strongSelf.event.ownerName.split(separator: " ")
            let ownerFirst = String(components[0])
            let ownerLast = String(components[1])
            let owner = User(userId: strongSelf.event.ownerId,firstName: ownerFirst, lastName: ownerLast)
            switch result {
            case .success(let conversations):
                if let targetConversation = conversations.first(where: {
                    $0.otherUser.userId == strongSelf.event.ownerId
                }) {
                    let vc = ChatViewController(toUser: targetConversation.otherUser, id: targetConversation.id)
                    vc.isNewConversation = false
                    vc.title = targetConversation.otherUser.firstName
                    vc.modalPresentationStyle = .overCurrentContext
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                } else {
                    strongSelf.createNewConversation(result: owner)
                }
            case .failure(_):
                strongSelf.createNewConversation(result: owner)
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
    
    @objc func didTapSaveButton(){
        if !isSaved {
            event.markSaved(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.savedUI()
                }
                
            })
        } else {
            event.markUnsaved(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.notSavedUI()
                }
            })
        }
    }
    
    private func savedUI() {
        isSaved = true
        saveButton.iconButton.isSelected = !saveButton.iconButton.isSelected
    }
    
    private func notSavedUI() {
        isSaved = false
        saveButton.iconButton.isSelected = !saveButton.iconButton.isSelected
    }
    
    @objc func didTapHost(){
        let vc = MasterTableViewController(sectionData: [event.hostingSection])
        vc.title = "Hosts"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame
        tableView.tableHeaderView = tableHeader
        
        view.addSubview(reportView)
        reportView.delegate = self
        reportView.isHidden = true
        reportView.translatesAutoresizingMaskIntoConstraints = false
        reportView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        reportView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reportView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        reportView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func reloadEvent() {
        configureCells()
        configureLabels()
        eventPhotoView.sd_setImage(with: event.imageUrl)
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
        liveView.layer.cornerRadius = liveView.frame.height/2
        view.bringSubviewToFront(reportView)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isReapearing = true
        guard timer != nil else { return }
        timer.invalidate()
        timer = nil
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("VIEW APPEARING \(Date() < event.startTime)")
        if Date() < event.startTime {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        } else {
            updateTime()
        }
    }
    
    func fetchEvent(completion: (() -> Void)? = nil) {
        if event.endTime <= Date() {
            configureLoadedEvent() // expired events have already been loaded and cannot change so no need to reload
            if let complete = completion {
                complete()
            }
        } else {
            DatabaseManager.shared.loadEvent(event: event, completion: { [weak self] result in
                switch result {
                case .success(let event):
                    guard let strongSelf = self else {
                        if let complete = completion {
                            complete()
                        }
                        return
                    }
                    strongSelf.event = event
                    DispatchQueue.main.async {
                        strongSelf.configureLoadedEvent()
                    }
                   
                    if let complete = completion {
                        complete()
                    }
                case .failure(_):
                    if let complete = completion {
                        complete()
                    }
                }
            })
        }
    }
    
    func configureLoadedEvent() {
        configureInviteButton()
        configureLabels()
        eventPhotoView.sd_setImage(with: event.imageUrl, completed: nil)
        updateTime()
        configureCells()
        tableView.reloadData()
    
        eventTypeLabel.textColor = event.getType().color
        eventBorder.layer.borderColor = event.getType().color.cgColor
    }
    
    private func configureRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                         NSAttributedString.Key.font: UIFont.zipSubtitle2])
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        
        let reportButton = UIButton(type: .system)
        reportButton.setImage(UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        reportButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton)
        
    
    }
    
    //MARK: - Table Config
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "desc")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "buytickets")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        
        configureTableHeaderLayout()
    }
    
    func configureTableHeaderLayout() {
        tableHeader.addSubview(eventPhotoView)
        eventPhotoView.translatesAutoresizingMaskIntoConstraints = false
        eventPhotoView.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 20).isActive = true
        eventPhotoView.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        eventPhotoView.heightAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        eventPhotoView.widthAnchor.constraint(equalTo: eventPhotoView.heightAnchor).isActive = true
        
        eventPhotoView.layer.masksToBounds = true
        eventPhotoView.layer.cornerRadius = view.frame.width/6
        
        eventBorder.layer.cornerRadius = view.frame.width/6+12
        
        tableHeader.addSubview(eventBorder)
        eventBorder.translatesAutoresizingMaskIntoConstraints = false
        eventBorder.centerXAnchor.constraint(equalTo: eventPhotoView.centerXAnchor).isActive = true
        eventBorder.centerYAnchor.constraint(equalTo: eventPhotoView.centerYAnchor).isActive = true
        eventBorder.widthAnchor.constraint(equalTo: eventPhotoView.widthAnchor, constant: 24).isActive = true
        eventBorder.heightAnchor.constraint(equalTo: eventBorder.widthAnchor).isActive = true

        tableHeader.addSubview(countDownLabel)
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: eventBorder.bottomAnchor, constant: 5).isActive = true
        
        tableHeader.addSubview(liveView)
        liveView.translatesAutoresizingMaskIntoConstraints = false
        liveView.centerYAnchor.constraint(equalTo: countDownLabel.centerYAnchor).isActive = true
        liveView.rightAnchor.constraint(equalTo: countDownLabel.leftAnchor, constant: -5).isActive = true
        liveView.heightAnchor.constraint(equalTo: countDownLabel.heightAnchor, multiplier: 0.5).isActive = true
        liveView.widthAnchor.constraint(equalTo: liveView.heightAnchor).isActive = true

        tableHeader.addSubview(eventTypeLabel)
        eventTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        eventTypeLabel.topAnchor.constraint(equalTo: countDownLabel.bottomAnchor).isActive = true
        eventTypeLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true

        tableHeader.addSubview(hostLabel)
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        hostLabel.topAnchor.constraint(equalTo: eventTypeLabel.bottomAnchor,constant: 5).isActive = true
        
        tableHeader.addSubview(goingButton)
        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        goingButton.topAnchor.constraint(equalTo: hostLabel.bottomAnchor, constant: 15).isActive = true
                
        tableHeader.addSubview(userCountLabel)
        userCountLabel.translatesAutoresizingMaskIntoConstraints = false
        userCountLabel.topAnchor.constraint(equalTo: goingButton.bottomAnchor, constant: 5).isActive = true
        userCountLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        
        tableHeader.addSubview(participantsButton)
        participantsButton.translatesAutoresizingMaskIntoConstraints = false
        participantsButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        participantsButton.topAnchor.constraint(equalTo: userCountLabel.bottomAnchor, constant: 10).isActive = true

        participantsButton.setIconDimension(width: 60)

        tableHeader.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -55).isActive = true
        saveButton.topAnchor.constraint(equalTo: participantsButton.topAnchor).isActive = true
        saveButton.setIconDimension(width: 60)
        
        tableHeader.addSubview(messageButton)
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 55).isActive = true
        messageButton.topAnchor.constraint(equalTo: participantsButton.topAnchor).isActive = true
        messageButton.setIconDimension(width: 60)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
//        tableHeader.topAnchor.constraint(equalTo: eventPhotoView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: participantsButton.bottomAnchor, constant: 20).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        
        goingButton.layer.cornerRadius = 8
        participantsButton.layer.cornerRadius = 30
        saveButton.layer.cornerRadius = 30
        messageButton.layer.cornerRadius = 30
        
        goingButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        
        saveButton.iconAddTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        messageButton.iconAddTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        participantsButton.iconAddTarget(self, action: #selector(didTapParticipantsButton), for: .touchUpInside)
        
        tableView.tableHeaderView = tableHeader
        
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame

        tableView.tableHeaderView = tableHeader
    }

    

    //MARK: - Label Config
    func configureLabels(){
        userCountLabel.text = String(event.usersGoing.count) + " participants"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextNoti,
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        if event.hosts.count > 1 {
            hostLabel.attributedText = NSAttributedString(string: "Hosted by \(event.ownerName) + \(event.hosts.count-1) more", attributes: attributes)
        } else {
            hostLabel.attributedText = NSAttributedString(string: "Hosted by " + event.ownerName, attributes: attributes)

        }
        
        eventTypeLabel.text = event.getType().description
        
        titleLabel.text = event.title
        navigationItem.titleView = titleLabel

    }
    


    @objc func updateTime() {
        let currentDate = Date()

        if currentDate >= event.endTime {
            countDownLabel.text = "This event has ended."
        } else if currentDate >= event.startTime {
            animateLiveView()
            guard timer != nil else { return }
            timer.invalidate()
            timer = nil
        } else {
            let userCalendar = Calendar.current
            let timeLeft = userCalendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: event.startTime)
            
            // Display Countdown
            
            if timeLeft.day == 0 && timeLeft.hour == 0 && timeLeft.minute == 0 {
                countDownLabel.text = "\(timeLeft.second!)s"
            } else if timeLeft.day == 0 && timeLeft.hour == 0 {
                countDownLabel.text = "\(timeLeft.minute!)m \(timeLeft.second!)s"
            } else if timeLeft.day == 0 {
                countDownLabel.text = "\(timeLeft.hour!)h \(timeLeft.minute!)m \(timeLeft.second!)s"
            } else {
                countDownLabel.text = "\(timeLeft.day!)d \(timeLeft.hour!)h \(timeLeft.minute!)m \(timeLeft.second!)s"
            }
        }
    }
    
    private func animateLiveView() {
        liveView.isHidden = false
        countDownLabel.text = "Live"

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.6
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false   //Set this property to false.
        liveView.layer.add(animation, forKey: "pulsating")
    }
    
    func configureCells() {
        cellConfigurations.removeAll()
        let addressString = NSMutableAttributedString(string: event.address)
        let distanceString = NSMutableAttributedString(string: event.getDistanceString())
        
        let startTimeFormatter = DateFormatter()
        startTimeFormatter.dateStyle = .none
        startTimeFormatter.timeStyle = .short
        let endTimeFormatter = DateFormatter()
        endTimeFormatter.dateStyle = .none
        endTimeFormatter.timeStyle = .short
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d"
        
        var dateString: NSMutableAttributedString
        if event.endTime.timeIntervalSince(event.startTime) <= 60 * 60 * 24 {
            dateString = NSMutableAttributedString(string: (df.string(from: event.startTime)) + "\n" + startTimeFormatter.string(from: event.startTime) + " - " + startTimeFormatter.string(from: event.endTime))
        } else {
            dateString = NSMutableAttributedString(string: (df.string(from: event.startTime)) + " at " + startTimeFormatter.string(from: event.startTime) + "\n"
                                                         + (df.string(from: event.endTime)) + " at " + startTimeFormatter.string(from: event.endTime))
        }
        
//        let dateString = NSMutableAttributedString(string: (df.string(from: event.startTime)))
//        let timeString = NSMutableAttributedString(string: (startTimeFormatter.string(from: event.startTime) + " - " + startTimeFormatter.string(from: event.endTime)))
        
        cellConfigurations.append((addressString,
                                    UIImage(systemName: "map")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)))
        
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        cellConfigurations.append((distanceString,
                                    UIImage(named: "zip.mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.white).withConfiguration(pinConfig)))
       
        cellConfigurations.append((dateString,
                                    UIImage(systemName: "clock")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)))

        
        if let event = event as? PromoterEvent,
           let price = event.price,
           let link = event.buyTicketsLink {

            let priceString = NSMutableAttributedString(string:("$\(String(format: "%.2f", price))"))
            let linkString = NSMutableAttributedString(string:("Buy Tickets Here"))
            print("link = ", link)
            linkString.setAttributes([.foregroundColor : UIColor.zipBlue,
                                      .strikethroughColor: UIColor.zipBlue,
                                      .underlineColor : UIColor.zipBlue,
                                      .strokeColor : UIColor.zipBlue,
                                      .underlineStyle: 1

            ], range: NSMakeRange(0, "Buy Tickets Here".count))
            
            cellConfigurations.append((priceString,
                                        UIImage(systemName: "dollarsign.square")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)))
            
            let ticketConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .large)
            cellConfigurations.append((linkString,
                                        UIImage(named: "zip.ticket")?.withRenderingMode(.alwaysOriginal).withTintColor(.white).withConfiguration(ticketConfig)
                                       ))
        }
        cellConfigurations.append((NSMutableAttributedString(string: event.bio), nil))
    }
}


//MARK: - TableDelegate
extension EventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == cellConfigurations.count - 1 {
            return UITableView.automaticDimension
        } else if indexPath.row == 2 {
            return UITableView.automaticDimension
        } else {
            return 52
        }
    }
}


extension EventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellConfigurations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if indexPath.row == 5,
           let event = event as? PromoterEvent,
           let url = event.buyTicketsLink
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "buytickets", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        var config = cell.defaultContentConfiguration()
        config.textProperties.color = .white
        config.textProperties.font = .zipTextFill
        config.attributedText = cellConfigurations[indexPath.row].0
        config.image = cellConfigurations[indexPath.row].1
        
        
        cell.contentConfiguration = config
        cell.contentView.backgroundColor = .zipGray
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if indexPath.row == 4 {
            print("did select")
            guard let event = event as? PromoterEvent,
                  let url = event.buyTicketsLink else {
                print("Failing url")
                return
            }
            print("OPEN URL")
                UIApplication.shared.open(url)
            
        }
    }
}


extension EventViewController : ReportMessageDelegate {
    func dismissVC() {
        slideDown(view: reportView, completion: { b in

        })
    }
    
    private func slideDown(view: UIView, completion: ((Bool) -> Void)?)  {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            view.isHidden = true
            view.frame = CGRect(x: 0,
                                y: strongSelf.view.frame.height,
                                width: strongSelf.view.frame.width,
                                height: strongSelf.view.frame.height)
        }, completion: completion)
    }
    
    func sendReport(reason: String) {
        slideDown(view: reportView, completion: { [weak self] b in
//            event.report(reason: reson)
            guard let strongSelf = self else { return }
            sendMail(type: .Danger, target: SearchObject(strongSelf.event), descriptor: reason)
        })
    }
    
    private func slideUp(view: UIView, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            view.isHidden = false
            view.frame = CGRect(x: 0,
                                y: strongSelf.view.frame.height - view.frame.width,
                                width: strongSelf.view.frame.width,
                                height: view.frame.height)
        }, completion: completion)
    }
    
 
    
    
    internal enum ReportContext: CustomStringConvertible, CaseIterable {
        case Spam
        case FakeEvent
        case InappropriatePic
        case InappropriateBio
        case Danger


        var description: String {
            switch self {
            case .Spam: return "Spam"
            case .FakeEvent: return "Fake Event/Spam"
            case .InappropriatePic: return "Inappropriate Photo"
            case .InappropriateBio: return "Inappropriate Description"
            case .Danger: return "Someone is in Danger"
            }
        }
    }
    
    private class ReportMessageView : UIView, UITextViewDelegate{
        let textView: UITextView
        var context: ReportContext!
        let sendButton: UIButton
        let cancelButton: UIButton
        let contextLabel: UILabel
        
        weak var delegate: ReportMessageDelegate?
        
        
        init() {
            textView = UITextView()
            sendButton = UIButton()
            contextLabel = UILabel.zipSubtitle()
            cancelButton = UIButton()
            
            super.init(frame: .zero)
            
            backgroundColor = .zipLightGray
            layer.masksToBounds = true
            layer.cornerRadius = 15
            
            sendButton.setTitle("Report", for: .normal)
            sendButton.backgroundColor = .zipVeryLightGray
            sendButton.setTitleColor(.white, for: .normal)
            sendButton.titleLabel?.font = .zipSubtitle2
            
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(.white, for: .normal)
            cancelButton.titleLabel?.font = .zipSubtitle2
            
            sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
            cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

            textView.font = .zipTextFill
            textView.layer.cornerRadius = 8
            textView.layer.masksToBounds = true
            textView.delegate = self
            textView.text = "Tell us a little about your report..."
            textView.textColor = .zipVeryLightGray
            textView.backgroundColor = .zipGray
        
            addSubviews()
            configureSubviewLayout()
        }
        
        @objc private func didTapSend() {
            delegate?.sendReport(reason: context.description + ": " + textView.text)
            delegate?.dismissVC()
        }
        
        @objc private func didTapCancel() {
            delegate?.dismissVC()
        }
        
        public func update(context: ReportContext) {
            self.context = context
            contextLabel.text = "Report: " + context.description
        }
        
        private func addSubviews() {
            addSubview(textView)
            addSubview(sendButton)
            addSubview(contextLabel)
            addSubview(cancelButton)
        }
        
        private func configureSubviewLayout() {
            contextLabel.translatesAutoresizingMaskIntoConstraints = false
            contextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            contextLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            textView.widthAnchor.constraint(equalTo: widthAnchor, constant: -10).isActive = true
            textView.topAnchor.constraint(equalTo: contextLabel.bottomAnchor, constant: 10).isActive = true
            textView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -10).isActive = true


            sendButton.translatesAutoresizingMaskIntoConstraints = false
            sendButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -5).isActive = true
            sendButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -5).isActive = true
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            cancelButton.heightAnchor.constraint(equalTo: sendButton.heightAnchor).isActive = true
            cancelButton.widthAnchor.constraint(equalTo: sendButton.widthAnchor).isActive = true
            
            sendButton.layer.masksToBounds = true
            sendButton.layer.cornerRadius = 15
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .zipVeryLightGray {
                textView.textColor = .white
                textView.text = ""
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "Tell us a little about your report..."
                textView.textColor = .zipVeryLightGray
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
