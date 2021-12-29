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
    var timer: Timer!
    var isGoing = false
    var isSaved = false

    // MARK: - SubViews

    //    private var pictureCollectionView: UICollectionView!
    private let tableView = UITableView()
    private let tableHeader = UIView()
    private let tableFooter = UIView()
    
    private let eventPhotoView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.borderWidth = 3
        imgView.layer.borderColor = UIColor.zipYellow.cgColor
        return imgView
    }()
    private let spinner = JGProgressHUD(style: .light)
    
    // MARK: - Labels
    private let countDownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.sizeToFit()
        return label
    }()
    
    private let hostLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipTitle.withSize(16)
        label.sizeToFit()
        return label
    }()
    
    private let userCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipTitle.withSize(16)
        label.sizeToFit()
        return label
    }()
    
    private let distanceView = UIView()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(18)
        label.sizeToFit()
        return label
    }()
    
    private let distanceImage: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "distanceToWhite")
        return imgView
    }()
    
    // MARK: - Buttons
    private let goingButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        
        btn.setTitle("GOING", for: .normal)
        btn.titleLabel?.textColor = .zipVeryLightGray
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        return btn
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let img = UIImage(systemName: "square.and.arrow.down.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let inviteButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let img = UIImage(systemName: "calendar.badge.plus", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let buyTicketsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let img = UIImage(systemName: "ticket.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    
    
    private let inviteLabel: UILabel = {
        let label = UILabel()
        label.text = "Invite"
        label.font = .zipBody.withSize(16)
        label.textColor = .white
        return label
    }()
    
    private let buyTicketsLabel: UILabel = {
        let label = UILabel()
        label.text = "Buy Tickets"
        label.font = .zipBody.withSize(16)
        label.textColor = .white
        return label
    }()
    
    private let saveLabel: UILabel = {
        let label = UILabel()
        label.text = "Save"
        label.font = .zipBody.withSize(16)
        label.textColor = .white
        return label
    }()
    
    private let zipListButton: UIButton = {
        let btn = UIButton()        
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let img = UIImage(systemName: "chevron.compact.up", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: btn.topAnchor).isActive = true
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .zipVeryLightGray
        label.text = "Zip List"
        
        btn.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    

    
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
    
    @objc private func didTapBuyTicketsButton(){
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer.invalidate()
    }
    
    //MARK: - Config
    public func configure(_ event: Event){
        self.event = event
        
        eventPhotoView.image = event.image
        
        hostLabel.isUserInteractionEnabled = true
        let hostTap = UITapGestureRecognizer(target: self, action: #selector(didTapHost))
        hostLabel.addGestureRecognizer(hostTap)
        
        userCountLabel.isUserInteractionEnabled = true
        let userTap = UITapGestureRecognizer(target: self, action: #selector(didTapZipListButton))
        userCountLabel.addGestureRecognizer(userTap)
        
        configureNavBar()
        configureLabels()
        configureTable()

    }
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let titleLabel = UILabel()
        titleLabel.font = .zipTitle.withSize(27)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.3
        titleLabel.text = event.title

        navigationItem.titleView = titleLabel
        
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

        tableHeader.addSubview(distanceView)
        distanceView.addSubview(distanceLabel)
        distanceView.addSubview(distanceImage)

        distanceView.translatesAutoresizingMaskIntoConstraints = false
        distanceView.topAnchor.constraint(equalTo: countDownLabel.bottomAnchor).isActive = true
        distanceView.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        distanceView.rightAnchor.constraint(equalTo: distanceLabel.rightAnchor).isActive = true
        distanceView.leftAnchor.constraint(equalTo: distanceImage.leftAnchor).isActive = true
        distanceView.heightAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.rightAnchor.constraint(equalTo: distanceView.rightAnchor).isActive = true
        distanceLabel.centerYAnchor.constraint(equalTo: distanceView.centerYAnchor).isActive = true
        
        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.rightAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        distanceImage.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true

        tableHeader.addSubview(hostLabel)
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        hostLabel.topAnchor.constraint(equalTo: distanceView.bottomAnchor).isActive = true
        
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
        
        
        tableHeader.addSubview(buyTicketsButton)
        buyTicketsButton.translatesAutoresizingMaskIntoConstraints = false
        buyTicketsButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        buyTicketsButton.topAnchor.constraint(equalTo: userCountLabel.bottomAnchor, constant: 10).isActive = true
        buyTicketsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buyTicketsButton.widthAnchor.constraint(equalTo: buyTicketsButton.heightAnchor).isActive = true

        tableHeader.addSubview(buyTicketsLabel)
        buyTicketsLabel.translatesAutoresizingMaskIntoConstraints = false
        buyTicketsLabel.centerXAnchor.constraint(equalTo: buyTicketsButton.centerXAnchor).isActive = true
        buyTicketsLabel.topAnchor.constraint(equalTo: buyTicketsButton.bottomAnchor, constant: 5).isActive = true

        tableHeader.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -35).isActive = true
        saveButton.topAnchor.constraint(equalTo: buyTicketsButton.topAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        saveButton.widthAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        tableHeader.addSubview(saveLabel)
        saveLabel.translatesAutoresizingMaskIntoConstraints = false
        saveLabel.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor).isActive = true
        saveLabel.topAnchor.constraint(equalTo: buyTicketsLabel.topAnchor).isActive = true

        tableHeader.addSubview(inviteButton)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 35).isActive = true
        inviteButton.topAnchor.constraint(equalTo: buyTicketsButton.topAnchor).isActive = true
        inviteButton.heightAnchor.constraint(equalTo: buyTicketsButton.heightAnchor).isActive = true
        inviteButton.widthAnchor.constraint(equalTo: buyTicketsButton.widthAnchor).isActive = true

        tableHeader.addSubview(inviteLabel)
        inviteLabel.translatesAutoresizingMaskIntoConstraints = false
        inviteLabel.centerXAnchor.constraint(equalTo: inviteButton.centerXAnchor).isActive = true
        inviteLabel.topAnchor.constraint(equalTo: buyTicketsLabel.topAnchor).isActive = true

        goingButton.layer.cornerRadius = 5
        buyTicketsButton.layer.cornerRadius = 30
        saveButton.layer.cornerRadius = 30
        inviteButton.layer.cornerRadius = 30
        
        goingButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        inviteButton.addTarget(self, action: #selector(didTapInviteButton), for: .touchUpInside)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.topAnchor.constraint(equalTo: eventPhotoView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: buyTicketsLabel.bottomAnchor).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        tableView.tableHeaderView = tableHeader
        
        //good for iphone 11 pro
        tableHeader.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.frame.width,
                                   height: 404 + 15)
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

        tableFooter.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.frame.width,
                                   height: 60)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableHeader.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.frame.width,
                                   height: buyTicketsLabel.frame.maxY + 15)
                
        tableView.tableHeaderView = tableHeader
    }

    //MARK: - Label Config
    private func configureLabels(){
        userCountLabel.text = String(event.usersGoing.count) + "/" + String(event.maxGuests) + " participants"
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        hostLabel.attributedText = NSAttributedString(string: "Hosted by " + event.hosts[0].fullName, attributes: attributes)
        
        let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        
        let eventLoc = CLLocation(latitude: event.coordinates.latitude, longitude: event.coordinates.longitude)
        var distance = Double(round(10*(userLoc.distance(from: eventLoc))/1000))/10
        var unit = "km"
        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
        }
        
        if distance > 10 {
            let intDistance = Int(distance)
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceLabel.text = "<1 \(unit) away"
            } else if distance >= 500 {
                distanceLabel.text = ">500 \(unit) away"
            } else {
                distanceLabel.text = String(intDistance) + " \(unit) away"
            }
        } else {
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceLabel.text = "<1 \(unit) away"
            } else if distance >= 500 {
                distanceLabel.text = ">500 \(unit) away"
            } else {
                distanceLabel.text = String(distance) + " \(unit) away"
            }
        }
    }
    
    //MARK: - Timer Config
    private func configureTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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
            countDownLabel.text = "See You There!"
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
