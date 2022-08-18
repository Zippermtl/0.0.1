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


class EventViewController: UIViewController {
    //MARK: Event Data
    var event: Event
    private var timer: Timer!
    private var isGoing: Bool
    private var isSaved: Bool
    private var isReapearing: Bool
    
    
    private let refreshControl: UIRefreshControl

    private let titleLabel: UILabel


    // MARK: - SubViews

    //    private var pictureCollectionView: UICollectionView!
    private let tableView: UITableView
    private let tableHeader: UIView
    private let tableFooter: UIView
    
    private let liveView: UIView
    
    private let eventBorder: UIView
    private let eventPhotoView: UIImageView
    private let spinner: JGProgressHUD
    
    // MARK: - Labels
    private let countDownLabel: UILabel
    let hostLabel: UILabel
    private let userCountLabel: UILabel
    private let eventTypeLabel: UILabel
    
    // MARK: - Buttons
    let goingButton: UIButton
    
    let saveButton: IconButton
    private let inviteButton: IconButton
    private let participantsButton: IconButton
    
    var tableCells : [UITableViewCell]
    var locationCell : UITableViewCell?
    var distanceCell : UITableViewCell?
    var dateCell : UITableViewCell?
    var timeCell : UITableViewCell?
    var descriptionCell : UITableViewCell?

    init(event: Event) {
        self.event = event
        self.isGoing = false
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
        
        self.inviteButton = IconButton(text: "Invite",
                                       icon: UIImage(systemName: "calendar.badge.plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                       config: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large))
        self.saveButton = IconButton(text: "Save",
                                     icon: UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                     config: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large))
        
        self.participantsButton = IconButton.zipsIcon()
        participantsButton.setTextLabel(s: "Participants")

        self.liveView = UIView()
        
        self.tableCells = []
        super.init(nibName: nil, bundle: nil)
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
        if event.usersGoing.contains(User(userId: userId)) {
            goingUI()
        }
        let events = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String: Int] ?? [:]
        if events[event.eventId] != nil {
            savedUI()
        }
        
        goingButton.layer.borderWidth = 3
        goingButton.layer.borderColor = UIColor.zipBlue.cgColor
           
        goingButton.setTitle("Going", for: .normal)
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipSubtitle2
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
      
        
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
        
        liveView.backgroundColor = .red
        liveView.isHidden = true
        liveView.layer.masksToBounds = true
        

        configureNavBar()
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        print("Report tapped")
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc func didTapGoingButton(){
        if !isGoing {
            DatabaseManager.shared.markGoing(event: event, completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                
                strongSelf.goingUI()
                guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
                strongSelf.event.usersGoing.append(User(userId: userId))
                strongSelf.configureUserCountLabel()
            })
        } else {
            DatabaseManager.shared.markNotGoing(event: event, completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                
                strongSelf.notGoingUI()
                guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
                      let idx = strongSelf.event.usersGoing.firstIndex(of: User(userId: userId)) else { return }
                strongSelf.event.usersGoing.remove(at: idx)
                strongSelf.configureUserCountLabel()
            })
        }
    }
    
    private func goingUI(){
        isGoing = true
        goingButton.backgroundColor = .zipBlue
    }
    
    private func notGoingUI() {
        isGoing = false
        goingButton.backgroundColor = .zipGray
    }
    
    @objc private func didTapParticipantsButton(){
        navigationController!.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)

        let zipListView = UsersTableViewController(users: event.usersGoing)
        zipListView.title = "Participants"
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        view.layer.add(transition, forKey: nil)
        
        navigationController?.pushViewController(zipListView, animated: true)
        
    }
    
    @objc private func didTapInviteButton(){
        let vc = InviteMoreViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSaveButton(){
        if !isSaved {
            DatabaseManager.shared.markSaved(event: event, completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                strongSelf.savedUI()
            })
        } else {
            DatabaseManager.shared.markUnsaved(event: event, completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                strongSelf.notSavedUI()
            })
        }
    }
    
    private func savedUI() {
        isSaved = true
        saveButton.iconButton.backgroundColor = .zipBlue
    }
    
    private func notSavedUI() {
        isSaved = false
        saveButton.iconButton.backgroundColor = .zipLightGray
    }
    
    @objc private func didTapHost(){
        let vc = UsersTableViewController(users: event.hosts)
        vc.title = "Hosts"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        fetchEvent(completion: nil)
        
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame
        tableView.tableHeaderView = tableHeader
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
        
        liveView.layer.cornerRadius = liveView.frame.height/2
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("VIEW DISAPPEARING")
        isReapearing = true
        guard timer != nil else { return }
        timer.invalidate()
        timer = nil

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Date() < event.startTime {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    
    
    private func fetchEvent(completion: (() -> Void)? = nil) {
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
                print("LOADED EVENT: " , event.startTime)
                strongSelf.configureLabels()
                strongSelf.eventPhotoView.sd_setImage(with: event.imageUrl, completed: nil)
                strongSelf.updateTime()
                strongSelf.configureCells()
                strongSelf.tableView.reloadData()
                

                strongSelf.eventTypeLabel.textColor = event.getType().color
                strongSelf.eventBorder.layer.borderColor = event.getType().color.cgColor
                
                if let complete = completion {
                    complete()
                }
            case .failure(let error):
                print("error loading event: \(error)")
                if let complete = completion {
                    complete()
                }
            }
        })
    }
    
    private func configureRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                         NSAttributedString.Key.font: UIFont.zipBody])
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
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    //MARK: - Table Config
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "desc")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        configureTableHeaderLayout()
    }
    
    private func configureTableHeaderLayout() {
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
        goingButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        
        tableHeader.addSubview(userCountLabel)
        userCountLabel.translatesAutoresizingMaskIntoConstraints = false
        userCountLabel.topAnchor.constraint(equalTo: goingButton.bottomAnchor, constant: 5).isActive = true
        userCountLabel.centerXAnchor.constraint(equalTo: goingButton.centerXAnchor).isActive = true
        
        tableHeader.addSubview(participantsButton)
        participantsButton.translatesAutoresizingMaskIntoConstraints = false
        participantsButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        participantsButton.topAnchor.constraint(equalTo: userCountLabel.bottomAnchor, constant: 10).isActive = true

        participantsButton.setIconDimension(width: 60)

        tableHeader.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -35).isActive = true
        saveButton.topAnchor.constraint(equalTo: participantsButton.topAnchor).isActive = true
        saveButton.setIconDimension(width: 60)
        
        tableHeader.addSubview(inviteButton)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 35).isActive = true
        inviteButton.topAnchor.constraint(equalTo: participantsButton.topAnchor).isActive = true
        inviteButton.setIconDimension(width: 60)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
//        tableHeader.topAnchor.constraint(equalTo: eventPhotoView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: participantsButton.bottomAnchor, constant: 20).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        goingButton.layer.cornerRadius = 8
        participantsButton.layer.cornerRadius = 30
        saveButton.layer.cornerRadius = 30
        inviteButton.layer.cornerRadius = 30
        
        goingButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        
        saveButton.iconAddTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        inviteButton.iconAddTarget(self, action: #selector(didTapInviteButton), for: .touchUpInside)
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
    
        configureUserCountLabel()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        hostLabel.attributedText = NSAttributedString(string: "Hosted by " + event.hosts[0].fullName, attributes: attributes)
        
        eventTypeLabel.text = event.getType().description
        
        titleLabel.text = event.title
        navigationItem.titleView = titleLabel

    }
    
    func configureUserCountLabel(){
        if event.maxGuests == -1 {
            userCountLabel.text = String(event.usersGoing.count) + " participants"
        } else {
            userCountLabel.text = String(event.usersGoing.count) + "/" + String(event.maxGuests) + " participants"
        }
    }
    

    @objc func updateTime() {
//        print("start time = \(event.startTime)")
//        print("currentdate = \(Date())")
        let currentDate = Date()

        if currentDate >= event.startTime {
            if currentDate >= event.endTime {
                countDownLabel.text = "Sorry! This event has ended."
            } else {
                animateLiveView()
                guard timer != nil else { return }
                timer.invalidate()
                timer = nil
                
                return
            }
           
        }
        
        let userCalendar = Calendar.current
        let timeLeft = userCalendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: event.startTime)
        
        // Display Countdown
        countDownLabel.text = "\(timeLeft.day!)d \(timeLeft.hour!)h \(timeLeft.minute!)m \(timeLeft.second!)s"
        
        if timeLeft.minute == 0 {
            countDownLabel.text = "\(timeLeft.second!)s"
        } else if timeLeft.hour == 0 {
            countDownLabel.text = "\(timeLeft.minute!)m \(timeLeft.second!)s"
        } else if timeLeft.day == 0{
            countDownLabel.text = "\(timeLeft.hour!)h \(timeLeft.minute!)m \(timeLeft.second!)s"
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
        tableCells.removeAll()
        locationCell = UITableViewCell()
        locationCell?.backgroundColor = .zipGray
        locationCell?.selectionStyle = .none
        var locationContent = locationCell!.defaultContentConfiguration()
        locationContent.textProperties.color = .white
        locationContent.textProperties.font = .zipTextFill
        locationContent.image = UIImage(systemName: "map.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        locationContent.text = event.address
        locationCell?.contentConfiguration = locationContent
        tableCells.append(locationCell!)
        
        distanceCell = UITableViewCell()
        distanceCell?.backgroundColor = .zipGray
        distanceCell?.selectionStyle = .none
        var distanceContent = distanceCell!.defaultContentConfiguration()
        distanceContent.textProperties.color = .white
        distanceContent.textProperties.font = .zipTextFill
        distanceContent.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        distanceContent.text = event.getDistanceString()
        distanceCell?.contentConfiguration = distanceContent
        tableCells.append(distanceCell!)
        
        dateCell = UITableViewCell()
        dateCell?.backgroundColor = .zipGray
        dateCell?.selectionStyle = .none
        var dateContent = dateCell!.defaultContentConfiguration()
        dateContent.textProperties.color = .white
        dateContent.textProperties.font = .zipTextFill
        dateContent.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d"
        dateContent.text = df.string(from: event.startTime)
        dateCell?.contentConfiguration = dateContent
        tableCells.append(dateCell!)
        
        timeCell = UITableViewCell()
        timeCell?.backgroundColor = .zipGray
        timeCell?.selectionStyle = .none
        var timeContent = timeCell!.defaultContentConfiguration()
        timeContent.textProperties.color = .white
        timeContent.textProperties.font = .zipTextFill
        timeContent.image = UIImage(systemName: "clock.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let startTimeFormatter = DateFormatter()
        startTimeFormatter.dateStyle = .none
        startTimeFormatter.timeStyle = .short
        let endTimeFormatter = DateFormatter()
        endTimeFormatter.dateStyle = .none
        endTimeFormatter.timeStyle = .short
        timeContent.text = startTimeFormatter.string(from: event.startTime) + " - " + endTimeFormatter.string(from: Date(timeInterval: event.duration, since: event.startTime))
        timeCell?.contentConfiguration = timeContent
        tableCells.append(timeCell!)
        
        descriptionCell = UITableViewCell()
        descriptionCell?.backgroundColor = .zipGray
        descriptionCell?.selectionStyle = .none
        var descContent = descriptionCell!.defaultContentConfiguration()
        descContent.textProperties.color = .white
        descContent.textProperties.font = .zipTextFill
        descContent.text = event.description
        descriptionCell?.contentConfiguration = descContent
        tableCells.append(descriptionCell!)
    }
}


//MARK: - TableDelegate
extension EventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension EventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableCells[indexPath.row]
    }
}
