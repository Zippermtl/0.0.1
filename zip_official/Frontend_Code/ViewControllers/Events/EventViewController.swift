//
//  EventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import UIKit
import MapKit
import CoreLocation

class EventViewController: UIViewController {
    //MARK: Event Data
    var event: Event = Event()
    var tableData = [String]()
    var eventDate: String = ""
    var timer: Timer!
    
    //MARK: - SubViews
    private var topViewContainer = UIView()
    private var scrollingContainer = UIView()
    private var pictureView =  UIView()
    private var infoHeaderContainer = UIView()
    private var tableView = UITableView()
    private var footerView = UIView()
    
    
    
    //MARK: - Labels
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    private var countDownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    private var userCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipLightGray
        label.font = .zipSubscript
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    private var hostLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipLightGray
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "A"
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Buttons
    var backButton = UIButton()
    var reportButton = UIButton()
    var buyTicketsButton = UIButton()
    
    var attendanceView = UIView()
    var goingButton = UIButton()
    var interestedButton = UIButton()
    
    var swipeUp = UISwipeGestureRecognizer()
        
    var zipListButton = UIButton()
    var upArrow = UIImageView(image: UIImage(named: "upArrow"))
    
    //MARK: - Button Actions

    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }


    @objc private func didTapReportButton(){
        print("Report tapped")
    }

    @objc private func didTapBuyTicketsButton(){
        print("Buy Tickets tapped")
    }
    
    @objc private func didTapGoingButton(){
        if goingButton.backgroundColor == .zipLightGray{
            goingButton.backgroundColor = .zipGreen
            interestedButton.backgroundColor = .zipLightGray
        } else {
            goingButton.backgroundColor = .zipLightGray
        }
        
        print("Going Tapped")
    }
    
    @objc private func didTapInterestedButton(){
        if interestedButton.backgroundColor == .zipLightGray{
            goingButton.backgroundColor = .zipLightGray
            interestedButton.backgroundColor = .zipYellow
        } else {
            interestedButton.backgroundColor = .zipLightGray
        }
        print("Interested tapped")
    }
    
    @objc private func didTapZipListButton(){
        let zipListView = ZipListViewController()
        zipListView.configure(event: event)
        zipListView.modalPresentationStyle = .overCurrentContext
        present(zipListView, animated: true, completion: nil)
        print("ZipList tapped")
    }
    
    //MARK: - Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer.invalidate()
    }
    
    //MARK: - Config
    public func configure(_ event: Event){
        self.event = event
        configureLabels()
        configureButtons()
        configureTable()
        addSubviews()
        configurePicture()
        configureSubviewLayout()
        addButtonTargets()
    }
    
    //MARK: - Table Config
    private func configureTable(){
        configureTableData()
        
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierFirstCell)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierWithImage)

        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
        tableView.separatorColor = .zipSeparator
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()

    }
    
    private func configureTableData(){
        tableData.append(event.address)
        tableData.append(eventDate)
        tableData.append(event.description)
    }

    //MARK: - Label Config
    private func configureLabels(){
        titleLabel.text = event.title
        userCountLabel.text = String(event.usersGoing.count) + "/" + String(event.maxGuests) + " participants"
        if event.hosts.count > 1 {
            hostLabel.text = "Hosted by " + event.hosts[0].name + "and " + (event.hosts.count-1).description + "more"
        } else {
            hostLabel.text = "Hosted by " + event.hosts[0].name
        }
        
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "E, MMM d,"
        
        let startTimeFormatter = DateFormatter()
        startTimeFormatter.dateStyle = .none
        startTimeFormatter.timeStyle = .short
        
        let endTimeFormatter = DateFormatter()
        endTimeFormatter.dateStyle = .none
        endTimeFormatter.timeStyle = .short
        
        eventDate = startDateFormatter.string(from: event.startTime) + " " +
                    startTimeFormatter.string(from: event.startTime) + "-" +
                    endTimeFormatter.string(from: Date(timeInterval: event.duration, since: event.startTime))
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
    
    //MARK: - Button config
    private func configureButtons() {
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didTapZipListButton))
        swipeUp.direction = .up
        
        self.view.addGestureRecognizer(swipeUp)
        
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        reportButton.setImage(UIImage(named: "report"), for: .normal)

        buyTicketsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        buyTicketsButton.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        buyTicketsButton.setTitle("BUY TICKETS", for: .normal)
        buyTicketsButton.titleLabel?.textColor = .white
        buyTicketsButton.titleLabel?.font = .zipBodyBold
        buyTicketsButton.titleLabel?.textAlignment = .center
        buyTicketsButton.contentVerticalAlignment = .center
        buyTicketsButton.layer.cornerRadius = 17
        
        goingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        goingButton.backgroundColor = .zipLightGray//.zipBlue //UIColor(red: 109/255, green: 203/255, blue: 241/255, alpha: 1)
        goingButton.setTitle("GOING", for: .normal)
        goingButton.titleLabel?.font = .zipBodyBold.withSize(22)
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
        goingButton.layer.cornerRadius = 15
        
        interestedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        interestedButton.backgroundColor = .zipLightGray//UIColor(red: 183/255, green: 179/255, blue: 75/255, alpha: 1)
        // UIColor(red: 211/255, green: 208/255, blue: 132/255, alpha: 1)
        interestedButton.setTitle("INTERESTED", for: .normal)
        interestedButton.titleLabel?.font = .zipBodyBold.withSize(22)
        interestedButton.titleLabel?.textAlignment = .center
        interestedButton.contentVerticalAlignment = .center
        interestedButton.layer.cornerRadius = 15
        
        
        zipListButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        zipListButton.setTitle("Zip List", for: .normal)
        zipListButton.titleLabel?.textAlignment = .center
        zipListButton.titleLabel?.font = .zipSubscript
        zipListButton.titleLabel?.textColor = .zipLightGray
        zipListButton.contentVerticalAlignment = .bottom
        zipListButton.addSubview(upArrow)

        
        upArrow.translatesAutoresizingMaskIntoConstraints = false
        upArrow.bottomAnchor.constraint(equalTo: zipListButton.titleLabel!.bottomAnchor, constant: -5).isActive = true
        upArrow.centerXAnchor.constraint(equalTo: zipListButton.titleLabel!.centerXAnchor).isActive = true

        configureLastCell()
    }
    
    //Adds subview to last cell and constrains
    private func configureLastCell(){
        attendanceView.addSubview(goingButton)
        attendanceView.addSubview(interestedButton)
                
        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        goingButton.centerYAnchor.constraint(equalTo: attendanceView.centerYAnchor).isActive = true
        goingButton.rightAnchor.constraint(equalTo: attendanceView.centerXAnchor, constant: -5).isActive = true
        goingButton.leftAnchor.constraint(equalTo: attendanceView.leftAnchor, constant: 20).isActive = true

        interestedButton.translatesAutoresizingMaskIntoConstraints = false
        interestedButton.heightAnchor.constraint(equalTo: goingButton.heightAnchor).isActive = true
        interestedButton.centerYAnchor.constraint(equalTo: attendanceView.centerYAnchor).isActive = true
        interestedButton.leftAnchor.constraint(equalTo: attendanceView.centerXAnchor, constant: 5).isActive = true
        interestedButton.rightAnchor.constraint(equalTo: attendanceView.rightAnchor, constant: -20).isActive = true
    }
    
    //Button Targets
    private func addButtonTargets(){
        // topViewContainer
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        
        // infoHeaderContainer
        buyTicketsButton.addTarget(self, action: #selector(didTapBuyTicketsButton), for: .touchUpInside)
        goingButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        interestedButton.addTarget(self, action: #selector(didTapInterestedButton), for: .touchUpInside)
        
        zipListButton.addTarget(self, action: #selector(didTapZipListButton), for: .touchUpInside)

        
    }
    
    //MARK: Picture Config
    private func configurePicture(){
        let pic = UIImageView(image: event.image!)
        let size = view.frame.width/3
        pic.frame = CGRect(x: 0, y: 0, width: size, height: size)

        let layer = pic.layer
        layer.borderWidth = 4
        layer.masksToBounds = true
        layer.cornerRadius = layer.frame.height/2

        switch event.type {
        case "promoter": layer.borderColor = CGColor(red: 1, green: 1, blue: 0, alpha: 1)
        case "innerCircle": layer.borderColor = UIColor.zipInnerCircleBlue.cgColor
        default: layer.borderColor = CGColor(red: 1, green: 0, blue: 1, alpha: 1)
        }
        pictureView.addSubview(pic)

    }

    
    //MARK: - Add Subviews
    private func addSubviews(){
        //username and top buttons
        view.addSubview(topViewContainer)
        topViewContainer.addSubview(titleLabel)
        topViewContainer.addSubview(backButton)
        topViewContainer.addSubview(reportButton)

        //TopCell
        scrollingContainer.addSubview(pictureView)
        scrollingContainer.addSubview(infoHeaderContainer)
        infoHeaderContainer.addSubview(countDownLabel)
        infoHeaderContainer.addSubview(buyTicketsButton)
        infoHeaderContainer.addSubview(userCountLabel)
        infoHeaderContainer.addSubview(hostLabel)
        scrollingContainer.addSubview(attendanceView)
        
        //table view
        view.addSubview(tableView)
        
        view.addSubview(footerView)
        footerView.addSubview(zipListButton)

    }
    
    //MARK: - Layout Constraints
    private func configureSubviewLayout(){
        //Dimensions
        let width = view.frame.size.width
        
        // Top View Container
        topViewContainer.translatesAutoresizingMaskIntoConstraints = false
        topViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topViewContainer.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        
        // Pictures
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.topAnchor.constraint(equalTo: scrollingContainer.topAnchor).isActive = true
        pictureView.leftAnchor.constraint(equalTo: scrollingContainer.leftAnchor, constant: view.frame.width/3).isActive = true
        pictureView.rightAnchor.constraint(equalTo: scrollingContainer.rightAnchor, constant: -view.frame.width/3).isActive = true
        pictureView.heightAnchor.constraint(equalToConstant: width/3).isActive = true

        // Profile Container constraints
        
        // info header constraints
        // height = height of contents + 5 buffer
        let infoHeaderHeight = buyTicketsButton.frame.height + userCountLabel.intrinsicContentSize.height + countDownLabel.intrinsicContentSize.height + hostLabel.intrinsicContentSize.height + 10

        infoHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        infoHeaderContainer.leftAnchor.constraint(equalTo: scrollingContainer.leftAnchor).isActive = true
        infoHeaderContainer.rightAnchor.constraint(equalTo: scrollingContainer.rightAnchor).isActive = true
        infoHeaderContainer.topAnchor.constraint(equalTo: pictureView.bottomAnchor).isActive = true
        infoHeaderContainer.heightAnchor.constraint(equalToConstant: infoHeaderHeight).isActive = true

        // AttendanceView
        attendanceView.translatesAutoresizingMaskIntoConstraints = false
        attendanceView.leftAnchor.constraint(equalTo: scrollingContainer.leftAnchor).isActive = true
        attendanceView.rightAnchor.constraint(equalTo: scrollingContainer.rightAnchor).isActive = true
        attendanceView.topAnchor.constraint(equalTo: infoHeaderContainer.bottomAnchor, constant: 5).isActive = true
        attendanceView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topViewContainer.bottomAnchor,constant: 5).isActive = true
        tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        footerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: zipListButton.frame.size.height).isActive = true
        
        // many more constraints
        addLabelConstraints()
        addButtonConstraints()
    }
    
    private func addLabelConstraints(){
        // title label constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: topViewContainer.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topViewContainer.topAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        
        // countdown label constraints
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.centerXAnchor.constraint(equalTo: scrollingContainer.centerXAnchor).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: infoHeaderContainer.topAnchor).isActive = true
        
        // age label constraints
        userCountLabel.translatesAutoresizingMaskIntoConstraints = false
        userCountLabel.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        userCountLabel.topAnchor.constraint(equalTo: buyTicketsButton.bottomAnchor).isActive = true
        
        // host label constraints
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.centerXAnchor.constraint(equalTo: scrollingContainer.centerXAnchor).isActive = true
        hostLabel.topAnchor.constraint(equalTo: userCountLabel.bottomAnchor).isActive = true
    }
    
    
    private func addButtonConstraints(){
        // Top View Container
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topViewContainer.leftAnchor, constant: 20).isActive = true

        // Report Button
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.topAnchor.constraint(equalTo: backButton.topAnchor).isActive = true
        reportButton.bottomAnchor.constraint(equalTo: backButton.bottomAnchor).isActive = true
        reportButton.heightAnchor.constraint(equalTo: reportButton.widthAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: topViewContainer.rightAnchor, constant: -20).isActive = true

        // Info Header Container
        // Buy Tickets
        buyTicketsButton.translatesAutoresizingMaskIntoConstraints = false
        buyTicketsButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        buyTicketsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        buyTicketsButton.topAnchor.constraint(equalTo: countDownLabel.bottomAnchor, constant: 10).isActive = true
        buyTicketsButton.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        
        // Zip List
        zipListButton.translatesAutoresizingMaskIntoConstraints = false
        zipListButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -2).isActive = true
        zipListButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
    }

}


//MARK: - TableDelegate
extension EventViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.frame.width/3 +
                buyTicketsButton.frame.height +
                userCountLabel.intrinsicContentSize.height +
                countDownLabel.intrinsicContentSize.height +
                hostLabel.intrinsicContentSize.height +
                40 + //40 is the height of attendance
                20 //buffer
        } else {
            return tableData[indexPath.row-1].heightForWrap(width: tableView.frame.width) + 25
        }
    }
}

//MARK: TableDataSource
extension EventViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + 1 //tabledata cells + top cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierFirstCell, for: indexPath) as! ProfileTableViewCell
            cell.leftInset = 0
            cell.rightInset = 0
            cell.contentView.addSubview(scrollingContainer)
            scrollingContainer.translatesAutoresizingMaskIntoConstraints = false
            scrollingContainer.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            scrollingContainer.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
            scrollingContainer.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            scrollingContainer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
                        
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            switch tableData[indexPath.row-1] {
            case event.address:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.textLabel?.text = ""
                
                cell.configure(with: tableData[indexPath.row-1], image: UIImage(named: "distanceToWhite")!)
                cell.backgroundColor = .clear
//                cell.backgroundColor = .green
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
                
            case eventDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.configure(with: tableData[indexPath.row-1], image: UIImage(named: "clock")!)
                cell.backgroundColor = .clear
//                cell.backgroundColor = .green
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifier, for: indexPath) as! ProfileTableViewCell
                
                let label = cell.textLabel!
                label.text = tableData[indexPath.row-1]
                label.textColor = .white
                label.font = .zipBody
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.sizeToFit()
                label.frame = cell.frame
                
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false

//                cell.backgroundColor = .red
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            }
        }
    }
}


