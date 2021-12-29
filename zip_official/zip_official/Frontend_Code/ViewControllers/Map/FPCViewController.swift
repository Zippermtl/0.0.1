//
//  FPCViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 11/15/21.
//

import UIKit
import CoreLocation

protocol FPCMapDelegate: AnyObject {
    func openZipFinder()
    func findEvents()
    func createEvent()
    func openNotifications()
    func openMessages()
    func openFPC()
}

class FPCViewController: UIViewController {
    weak var delegate: FPCMapDelegate?
    
    private var userLoc = CLLocation()
    
    private let scrollView = UIScrollView()
    
    
    
    private let zipFinderButton: UIButton = {
        let btn = UIButton()
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 20
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        let img = UIImage(systemName: "person.fill.badge.plus", withConfiguration: config)
        
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = .white
        
        btn.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        imgView.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
            
        return btn
    }()
    
    private let searchBar: UITextField = {
        let tf = UITextField()
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 20
        tf.backgroundColor = .zipLightGray
        tf.tintColor = .white
        tf.leftViewMode = .always
        
        tf.placeholder = "Search for Users or Events"
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .unspecified, scale: .small)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        let imgView = UIImageView(image: img)
        let view = UIView()
        
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        view.addSubview(imgView)
        if let size = img?.size {
            imgView.frame = CGRect(x: (view.frame.width-size.width)/2,
                                   y: (view.frame.height-size.height)/2,
                                   width: size.width,
                                   height: size.height)
        }
        tf.leftView = view
        return tf
        
    }()
    
    private var collectionView: UICollectionView?

    private let collectionTitles = [
        "Find\nEvents",
        "Create\nEvent",
        "Notifications",
        "Messages"
    ]
    
    private let collectionImages: [UIImage?] = [
        UIImage(systemName: "calendar"),
        UIImage(systemName: "calendar.badge.plus"),
        UIImage(systemName: "bell.fill"),
        UIImage(systemName: "message.fill")
    ]
    
    private let zipRequestsLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody.withSize(16)
        label.textColor = .zipVeryLightGray
        label.text = "Zip Requests (0)"
        return label
    }()
    
    private let zipRequestsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        btn.setAttributedTitle(NSMutableAttributedString(string: "See All", attributes: attributes), for: .normal)
        return btn
    }()
    
    private var zipRequestsTable: UITableView?
    private var requests: [ZipNotification] = []

    private let eventsLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody.withSize(16)
        label.textColor = .zipVeryLightGray
        label.text = "Event Invites (0)"
        return label
    }()
    
    private let eventsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        btn.setAttributedTitle(NSMutableAttributedString(string: "See All", attributes: attributes), for: .normal)
        return btn
    }()
    
    private var eventsTable: UITableView?
    private var events: [Event] = []
    
    
    @objc private func openZipFinder() {
        delegate?.openZipFinder()
    }
    
    func findEvents() {
        delegate?.findEvents()
    }
    
    func createEvent() {
        delegate?.createEvent()
    }
    
    func openNotifications(){
        delegate?.openNotifications()
    }
    
    func openMessages(){
        delegate?.openMessages()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRequests()
        generateEvents()
        view.backgroundColor = .zipGray
        
        //Collection View
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        //Table Views
        zipRequestsTable = UITableView()
        eventsTable = UITableView()
        
        //Buttons
        zipFinderButton.addTarget(self, action: #selector(openZipFinder), for: .touchUpInside)
        
        //Search Bar
        searchBar.delegate = self
        
        configureCollectionView()
        configureTables()
        addSubviews()
    }
    
    public func configure(userLocation: CLLocation) {
        self.userLoc = userLocation
        eventsTable?.reloadData()
    }
    
    private func configureCollectionView() {
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
    }
    
    private func configureTables(){
        guard let zipRequestsTable = zipRequestsTable,
              let eventsTable = eventsTable else {
            return
        }

        zipRequestsTable.register(ZipRequestTableViewCell.self, forCellReuseIdentifier: ZipRequestTableViewCell.identifier)
        zipRequestsTable.delegate = self
        zipRequestsTable.dataSource = self
        zipRequestsTable.backgroundColor = .clear
        zipRequestsTable.separatorStyle = .none
        zipRequestsTable.tableHeaderView = nil
        zipRequestsTable.tableFooterView = nil
        zipRequestsTable.sectionIndexBackgroundColor = .zipLightGray
        zipRequestsTable.separatorColor = .zipSeparator
        zipRequestsTable.backgroundColor = .clear
        zipRequestsTable.isScrollEnabled = false
        zipRequestsTable.bounces = false

        
        eventsTable.register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)
        eventsTable.delegate = self
        eventsTable.dataSource = self
        eventsTable.backgroundColor = .clear
        eventsTable.separatorStyle = .none
        eventsTable.tableHeaderView = nil
        eventsTable.tableFooterView = nil
        eventsTable.sectionIndexBackgroundColor = .zipLightGray
        eventsTable.separatorColor = .zipSeparator
        eventsTable.backgroundColor = .clear
        eventsTable.isScrollEnabled = false
        eventsTable.bounces = false
        
    }

    
    private func addSubviews(){
        guard let collectionView = collectionView,
              let zipRequestsTable = zipRequestsTable,
              let eventsTable = eventsTable else {
            return
        }
        view.addSubview(scrollView)
        
        scrollView.addSubview(zipFinderButton)
        scrollView.addSubview(searchBar)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(zipRequestsLabel)
        scrollView.addSubview(zipRequestsButton)
        scrollView.addSubview(zipRequestsTable)
        scrollView.addSubview(eventsLabel)
        scrollView.addSubview(eventsButton)
        scrollView.addSubview(eventsTable)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let collectionView = collectionView,
              let zipRequestsTable = zipRequestsTable,
              let eventsTable = eventsTable else {
            return
        }
        scrollView.updateContentView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        
        zipFinderButton.translatesAutoresizingMaskIntoConstraints = false
        zipFinderButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8).isActive = true
        zipFinderButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        zipFinderButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        zipFinderButton.widthAnchor.constraint(equalTo: zipFinderButton.heightAnchor).isActive = true

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leftAnchor.constraint(equalTo: zipFinderButton.rightAnchor, constant: 12).isActive = true
        searchBar.topAnchor.constraint(equalTo: zipFinderButton.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: zipFinderButton.bottomAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true

        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        let height = (view.frame.width - 35)/4*0.8 + 40
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        zipRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        zipRequestsLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20).isActive = true
        
        zipRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        zipRequestsButton.centerYAnchor.constraint(equalTo: zipRequestsLabel.centerYAnchor).isActive = true
        
        zipRequestsTable.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsTable.topAnchor.constraint(equalTo: zipRequestsLabel.bottomAnchor, constant: 5).isActive = true
        zipRequestsTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        zipRequestsTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        zipRequestsTable.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        eventsLabel.topAnchor.constraint(equalTo: zipRequestsTable.bottomAnchor, constant: 20).isActive = true
        
        eventsButton.translatesAutoresizingMaskIntoConstraints = false
        eventsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        eventsButton.centerYAnchor.constraint(equalTo: eventsLabel.centerYAnchor).isActive = true
        
        eventsTable.translatesAutoresizingMaskIntoConstraints = false
        eventsTable.topAnchor.constraint(equalTo: eventsLabel.bottomAnchor, constant: 5).isActive = true
        eventsTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        eventsTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        eventsTable.heightAnchor.constraint(equalToConstant: 360).isActive = true


        
        
    }
    
}

extension FPCViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 4
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
                       + flowLayout.sectionInset.right
                       + (flowLayout.minimumInteritemSpacing * CGFloat(numCells - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numCells))
        
        return CGSize(width: size, height: size + 40)
    }
    

}

extension FPCViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: findEvents()
        case 1: createEvent()
        case 2: openNotifications()
        case 3: openMessages()
        default:
            print("failed to select item at \(indexPath.row)")
        }
    }
}

extension FPCViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .zipGray
        
        let cellWidth = view.frame.width*0.2*0.8

//        let cellBg = UIView( )
        
        let imgBg = UIView()
        imgBg.backgroundColor = .zipLightGray
        imgBg.layer.cornerRadius = cellWidth/2
        imgBg.layer.masksToBounds = true
        
        let imgView = UIImageView()
        let icon = collectionImages[indexPath.row]
        imgView.image = icon
        imgView.tintColor = .white
        imgView.backgroundColor = .clear
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 10
        imgView.contentScaleFactor = 0.5
        
        imgBg.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.centerXAnchor.constraint(equalTo: imgBg.centerXAnchor).isActive = true
        imgView.centerYAnchor.constraint(equalTo: imgBg.centerYAnchor).isActive = true
        imgView.heightAnchor.constraint(equalTo: imgBg.heightAnchor, multiplier: 0.75).isActive = true
        imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor).isActive = true
        
        cell.contentView.addSubview(imgBg)
        imgBg.translatesAutoresizingMaskIntoConstraints = false
        imgBg.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        imgBg.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        imgBg.widthAnchor.constraint(equalToConstant: cellWidth).isActive = true
        imgBg.heightAnchor.constraint(equalTo: imgBg.widthAnchor).isActive = true
        
        
        let label = UILabel()
        label.text = collectionTitles[indexPath.row]
        label.textColor = .white
        label.font = .zipBody.withSize(14)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        cell.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 10).isActive = true
        
        return cell
    }
    
    
}




extension FPCViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == zipRequestsTable {
            return 90
        } else {
            return 120
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == zipRequestsTable {
            return 1
        } else {
            return 3
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == zipRequestsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: ZipRequestTableViewCell.identifier) as! ZipRequestTableViewCell
            cell.configure(with: requests[requests.count-1])
            return cell
        } else {
            let cellEvent = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            cell.configure(cellEvent, loc: userLoc)
            return cell
        }
        
    }
}

extension FPCViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.openFPC()
    }
}

extension FPCViewController {
    func generateRequests(){
        let request1 = ZipNotification(type: .zipRequest, image: UIImage(named: "ezra1")!, time: TimeInterval(10), hasRead: false)
        let request2 = ZipNotification(type: .zipRequest, image: UIImage(named: "yianni1")!, time: TimeInterval(10), hasRead: false)
        let request3 = ZipNotification(type: .zipRequest, image: UIImage(named: "seung1")!, time: TimeInterval(10), hasRead: false)
        let request4 = ZipNotification(type: .zipRequest, image: UIImage(named: "elias1")!, time: TimeInterval(10), hasRead: false)
        let request5 = ZipNotification(type: .zipRequest, image: UIImage(named: "gabe1")!, time: TimeInterval(10), hasRead: false)
        let request6 = ZipNotification(type: .zipRequest, image: UIImage(named: "ezra2")!, time: TimeInterval(10), hasRead: false)
        
        requests.append(request1)
        requests.append(request2)
        requests.append(request3)
        requests.append(request4)
        requests.append(request5)
        requests.append(request6)

    }
    
    func generateEvents(){
        var yiannipics = [UIImage]()
        var interests = [Interests]()
        
        interests.append(.skiing)
        interests.append(.coding)
        interests.append(.chess)
        interests.append(.wine)
        interests.append(.workingOut)


        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        
        let yianni = User(email: "zavalyia@gmail.com",
                          username: "yianni_zav",
                          firstName: "Yianni",
                          lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                          birthday: yianniBirthday,
                          location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                          pictures: yiannipics,
                          bio: "Yianni Zavaliagkos. Second Year at Mcgill. Add my snap and follow my insta @Yianni_Zav. I run this shit. Remember my name when I pass Zuckerberg on Forbes",
                          school: "McGill University",
                          interests: interests)
        
        
        let launchEvent = Event(title: "Zipper Launch Party",
                            hosts: [yianni],
                            description: "Come experience the release and launch of Zipper! Open Bar! Zipper profiles and ID's will be checked at the door. Must be 18 years or older",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [yianni],
                            usersInterested: [yianni],
                            type: "promoter",
                            isPublic: true,
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "launchevent")!)
        
        let fakeFroshEvent = Event(title: "Fake Ass Frosh",
                            hosts: [yianni],
                            description: "The FitnessGram™ Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. Ding  A single lap should be completed each time you hear this sound. Ding  Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, ding",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [yianni],
                            usersInterested: [yianni],
                            type: "innerCircle",
                            isPublic: true,
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "muzique")!)
        
        let spikeBallEvent = Event(title: "Zipper Spikeball Tournament",
                            hosts: [yianni],
                            description: "Zipper Spikeball Tournament",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [yianni],
                            usersInterested: [yianni],
                            type: "n/a",
                            isPublic: true,
                            startTime: Date(timeIntervalSinceNow: 100000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "spikeball"))
        
        events.append(launchEvent)
        events.append(fakeFroshEvent)
        events.append(spikeBallEvent)

    }
}
