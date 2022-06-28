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
    var event: Event = Event()
    private var timer: Timer!
    private var isGoing: Bool
    private var isSaved: Bool
    
    private let refreshControl: UIRefreshControl

    private let titleLabel: UILabel


    // MARK: - SubViews

    //    private var pictureCollectionView: UICollectionView!
    private let tableView: UITableView
    private let tableHeader: UIView
    private let tableFooter: UIView
    
    private let eventPhotoView: UIImageView
    private let spinner: JGProgressHUD
    
    // MARK: - Labels
    private let countDownLabel: UILabel
    private let hostLabel: UILabel
    private let userCountLabel: UILabel
    private let distanceLabel: DistanceLabel
    
    // MARK: - Buttons
    private let goingButton: UIButton
    
    private let saveButton: IconButton
    private let inviteButton: IconButton
    private let participantsButton: IconButton
    
    
   
    
    private let zipListButton: UIButton
    
    
    init(event: Event) {
        self.event = event
        self.isGoing = false
        self.isSaved = false
        self.refreshControl = UIRefreshControl()
        self.tableView = UITableView()
        self.tableFooter = UIView()
        self.tableHeader = UIView()
        self.eventPhotoView = UIImageView()
        self.spinner = JGProgressHUD(style: .light)
        self.countDownLabel = UILabel.zipTitle()
        self.hostLabel = UILabel.zipTextPrompt()
        self.titleLabel = UILabel.zipHeader()
        self.distanceLabel = DistanceLabel()
        self.userCountLabel = UILabel.zipTextPrompt()
        userCountLabel.textColor = .zipVeryLightGray

        self.goingButton = UIButton()
        self.zipListButton = UIButton()
        
        self.inviteButton = IconButton(text: "Invite",
                                       icon: UIImage(systemName: "calendar.badge.plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                       config: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large))
        self.saveButton = IconButton(text: "Save",
                                     icon: UIImage(systemName: "square.and.arrow.down.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                     config: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large))
        
        self.participantsButton = IconButton.zipsIcon()
        participantsButton.setTextLabel(s: "Participants")

        
        super.init(nibName: nil, bundle: nil)
        
        
        goingButton.backgroundColor = .zipLightGray
        goingButton.layer.borderWidth = 1
        goingButton.layer.borderColor = UIColor.white.cgColor
           
        goingButton.setTitle("GOING", for: .normal)
        goingButton.titleLabel?.textColor = .zipVeryLightGray
        goingButton.titleLabel?.font = .zipBodyBold
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
      
        
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let img = UIImage(systemName: "chevron.compact.up", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        zipListButton.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: zipListButton.topAnchor).isActive = true
        icon.centerXAnchor.constraint(equalTo: zipListButton.centerXAnchor).isActive = true
        
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .zipVeryLightGray
        label.text = "Zip List"
        
        zipListButton.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: zipListButton.centerXAnchor).isActive = true

        zipListButton.layer.masksToBounds = true
        
        
        eventPhotoView.layer.borderWidth = 3
        eventPhotoView.layer.borderColor = UIColor.zipYellow.cgColor
        
        hostLabel.isUserInteractionEnabled = true
        let hostTap = UITapGestureRecognizer(target: self, action: #selector(didTapHost))
        hostLabel.addGestureRecognizer(hostTap)
        
        userCountLabel.isUserInteractionEnabled = true
        let userTap = UITapGestureRecognizer(target: self, action: #selector(didTapZipListButton))
        userCountLabel.addGestureRecognizer(userTap)
        
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
    @objc private func didTapReportButton(){
        print("Report tapped")
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapGoingButton(){
        if !isGoing {
            isGoing = true
            goingButton.layer.borderWidth = 0
            goingButton.backgroundColor = .zipBlue
        } else {
            isGoing = false
            goingButton.layer.borderWidth = 1
            goingButton.backgroundColor = .zipLightGray
        }
    }
    
    @objc private func didTapParticipantsButton(){
        print("Buy Tickets tapped")
    }
    
    @objc private func didTapInviteButton(){

    }
    
    @objc private func didTapSaveButton(){
        if !isSaved {
            isSaved = true
            saveButton.backgroundColor = .zipGreen
        } else {
            isSaved = false
            saveButton.backgroundColor = .zipLightGray
        }
    }
    
    @objc private func didTapZipListButton(){
        navigationController!.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)

        let zipListView = ZipListViewController()
        zipListView.configure(event: event)
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        view.layer.add(transition, forKey: nil)
        
        navigationController?.pushViewController(zipListView, animated: true)
    }
    
    @objc private func didTapHost(){
        navigationController!.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)

        let hostsVC = HostsViewController()
        hostsVC.configure(event.hosts)
        navigationController?.pushViewController(hostsVC, animated: true)
    }
    
    //MARK: - Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        fetchEvent(completion: nil)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer.invalidate()
    }
    
    private func fetchEvent(completion: (() -> Void)? = nil) {
        DatabaseManager.shared.loadEvent(key: event.eventId, completion: { [weak self] result in
            switch result {
            case .success(let event):
                guard let strongSelf = self else {
                    if let complete = completion {
                        complete()
                    }
                    return
                }
                strongSelf.event = event
                strongSelf.configureLabels()
                strongSelf.eventPhotoView.sd_setImage(with: event.imageUrl, completed: nil)
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 0.1, target: strongSelf, selector: #selector(strongSelf.updateTime), userInfo: nil, repeats: true)
                print("EVENT TITLE = \(event.title)")
                strongSelf.tableView.reloadData()
                
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
        configureTableFooterLayout()

    }
    
    private func configureTableHeaderLayout() {
        tableHeader.addSubview(eventPhotoView)
        eventPhotoView.translatesAutoresizingMaskIntoConstraints = false
        eventPhotoView.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 10).isActive = true
        eventPhotoView.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        eventPhotoView.heightAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        eventPhotoView.widthAnchor.constraint(equalTo: eventPhotoView.heightAnchor).isActive = true
        
        eventPhotoView.layer.masksToBounds = true
        eventPhotoView.layer.cornerRadius = view.frame.width/6
        
        tableHeader.addSubview(countDownLabel)
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: eventPhotoView.bottomAnchor, constant: 5).isActive = true

        tableHeader.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.topAnchor.constraint(equalTo: countDownLabel.bottomAnchor).isActive = true
        distanceLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true

        tableHeader.addSubview(hostLabel)
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        hostLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor).isActive = true
        
        tableHeader.addSubview(goingButton)
        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        goingButton.topAnchor.constraint(equalTo: hostLabel.bottomAnchor, constant: 10).isActive = true
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
        tableHeader.topAnchor.constraint(equalTo: eventPhotoView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 30).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true

        goingButton.layer.cornerRadius = 5
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
    
    private func configureTableFooterLayout() {
        tableFooter.addSubview(zipListButton)
        zipListButton.translatesAutoresizingMaskIntoConstraints = false
        zipListButton.centerXAnchor.constraint(equalTo: tableFooter.centerXAnchor).isActive = true
        zipListButton.topAnchor.constraint(equalTo: tableFooter.topAnchor).isActive = true
        zipListButton.bottomAnchor.constraint(equalTo: tableFooter.bottomAnchor).isActive = true
        zipListButton.widthAnchor.constraint(equalTo: tableFooter.widthAnchor).isActive = true

        
        tableView.tableFooterView = tableFooter
        zipListButton.addTarget(self, action: #selector(didTapZipListButton), for: .touchUpInside)

        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableFooter.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableFooter.frame
        frame.size.height = height
        tableFooter.frame = frame

        tableView.tableFooterView = tableFooter
    }
    

    //MARK: - Label Config
    private func configureLabels(){
        userCountLabel.text = String(event.usersGoing.count) + "/" + String(event.maxGuests) + " participants"
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        hostLabel.attributedText = NSAttributedString(string: "Hosted by " + event.hosts[0].fullName, attributes: attributes)
        
        distanceLabel.update(location: event.coordinates)
        
        titleLabel.text = event.title
        navigationItem.titleView = titleLabel

    }
    

    @objc func updateTime() {
        let userCalendar = Calendar.current
        // Set Current Date
        let date = Date()
        let components = userCalendar.dateComponents([.hour, .minute, .month, .year, .day, .second], from: date)
        let currentDate = userCalendar.date(from: components)!
        
        // Change the seconds to days, hours, minutes and seconds
        
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
        
        if currentDate >= event.startTime {
            countDownLabel.text = "LIVE"
            // Stop Timer
            timer.invalidate()
        }
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 { // description
            let cell = tableView.dequeueReusableCell(withIdentifier: "desc", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipBody
            content.text = event.description
            cell.contentConfiguration = content
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipBody
            

            switch indexPath.row {
            case 0: // address
                content.image = UIImage(systemName: "map.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
                content.text = event.address
                
            case 1: // Date
                content.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
                
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEEE, MMMM d"
                
                content.text = startDateFormatter.string(from: event.startTime)
 
            default: // Time
                content.image = UIImage(systemName: "clock.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

                let startTimeFormatter = DateFormatter()
                startTimeFormatter.dateStyle = .none
                startTimeFormatter.timeStyle = .short
                
                let endTimeFormatter = DateFormatter()
                endTimeFormatter.dateStyle = .none
                endTimeFormatter.timeStyle = .short
                
                content.text = startTimeFormatter.string(from: event.startTime) + " - " +
                endTimeFormatter.string(from: Date(timeInterval: event.duration, since: event.startTime))
            }
            
            cell.contentConfiguration = content
            
            return cell
        }
    }
}
