//
//  EventsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//



//https://stackoverflow.com/questions/35662840/how-to-add-circular-mask-on-camera-in-swift

//https://stackoverflow.com/questions/31283523/display-uisearchcontrollers-searchbar-programmatically

import UIKit
import MapKit
import CoreLocation

class EventFinderViewController: UIViewController {
    // MARK: - SubViews
    var headerView = UIView()
    var tableView = UITableView()

    var launchEvent = Event()
    var fakeFroshEvent = Event()
    var spikeBallEvent = Event()
    
    var eventData: [Event] = []
    var publicTableData: [[Event]] = [[],[]]
    var privateTableData: [[Event]] = [[],[]]
    var tableData: [[Event]] = [[],[]]
    
    // MARK: - Labels
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "EVENTS"
        return label
    }()
    
    
    
    
    // MARK: - Buttons
    var publicButton = UIButton()
    var privateButton = UIButton()
    var addEventButton = UIButton()
    
    
    // MARK: - Button Actions
    @objc private func didTapPublicButton(){
        publicButton.backgroundColor = .zipVeryLightGray
        privateButton.backgroundColor = .zipLightGray
        tableData = publicTableData
        tableView.reloadData()
    }
    
    @objc private func didTapPrivateButton(){
        privateButton.backgroundColor = .zipVeryLightGray
        publicButton.backgroundColor = .zipLightGray
        tableData = privateTableData
        tableView.reloadData()
    }
    
    @objc private func didTapAddButton(){
        let actionSheet = UIAlertController(title: "Create an Event",
                                            message: "What type of event would you like to create",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Private",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let privateEvent = NewPrivateEventViewController()
                                                privateEvent.modalPresentationStyle = .overCurrentContext
                                                self?.present(privateEvent, animated: true, completion: nil)
                                                print("new event tapped")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Public",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let publicEvent = NewPublicEventViewController()
                                                publicEvent.modalPresentationStyle = .overCurrentContext
                                                self?.present(publicEvent, animated: true, completion: nil)
                                                print("new event tapped")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Promoter",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let publicEvent = NewPublicEventViewController()
                                                publicEvent.modalPresentationStyle = .overCurrentContext
                                                self?.present(publicEvent, animated: true, completion: nil)
                                                print("new event tapped")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .default,
                                            handler: nil))
        present(actionSheet, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        generateTestData()
        eventData.append(launchEvent)
        eventData.append(fakeFroshEvent)
        eventData.append(spikeBallEvent)

        
        configureEventLists()
        configureTable()
        configureButtons()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Event Data Config
    private func configureEventLists() {
        let userCalendar = Calendar.current
        publicTableData[0] = eventData.filter { $0.isPublic &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day == 0 }
        publicTableData[1] = eventData.filter { $0.isPublic &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day != 0 }
        privateTableData[0] = eventData.filter { !$0.isPublic &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day == 0 }
        privateTableData[1] = eventData.filter { !$0.isPublic &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day != 0 }
        tableData = publicTableData
    }

    //MARK: - Table Config
    private func configureTable(){
        tableView.register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
    }
    //MARK: - Button Config
    private func configureButtons(){
        let width = view.frame.size.width
        publicButton = UIButton(frame: CGRect(x: 0, y: 0, width: width/2-20, height: 40))
        publicButton.backgroundColor = .zipVeryLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        publicButton.setTitle("PUBLIC", for: .normal)
        publicButton.titleLabel?.textColor = .white
        publicButton.titleLabel?.font = .zipBodyBold
        publicButton.titleLabel?.textAlignment = .center
        publicButton.contentVerticalAlignment = .center
        publicButton.layer.cornerRadius = 10
        
        privateButton = UIButton(frame: CGRect(x: 0, y: 0, width: width/2-20, height: 40))
        privateButton.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        privateButton.setTitle("PRIVATE", for: .normal)
        privateButton.titleLabel?.textColor = .white
        privateButton.titleLabel?.font = .zipBodyBold
        privateButton.titleLabel?.textAlignment = .center
        privateButton.contentVerticalAlignment = .center
        privateButton.layer.cornerRadius = 10
        
        addEventButton.setImage(UIImage(named: "add"), for: .normal)
        
        addButtonTargets()
    }
    
    private func addButtonTargets(){
        // topViewContainer
        publicButton.addTarget(self, action: #selector(didTapPublicButton), for: .touchUpInside)
        privateButton.addTarget(self, action: #selector(didTapPrivateButton), for: .touchUpInside)
        
        addEventButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    
    //MARK: - Add Subviews
    private func addSubviews(){
        // Header
        view.addSubview(headerView)
        headerView.addSubview(pageTitleLabel)
        headerView.addSubview(addEventButton)
        headerView.addSubview(privateButton)
        headerView.addSubview(publicButton)
        
        // Table View
        view.addSubview(tableView)
    }
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        configureHeader()

        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    //MARK: - Header Config
    private func configureHeader(){
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: publicButton.bottomAnchor, constant: 10).isActive = true
        headerView.backgroundColor = .zipGray
        
        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor,constant: 20).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true

        // Public Button
        publicButton.translatesAutoresizingMaskIntoConstraints = false
        publicButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        publicButton.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 10).isActive = true
        publicButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Private Button
        privateButton.translatesAutoresizingMaskIntoConstraints = false
        privateButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        privateButton.leftAnchor.constraint(equalTo: publicButton.rightAnchor, constant: 10).isActive = true
        privateButton.widthAnchor.constraint(equalTo: publicButton.widthAnchor).isActive = true
        privateButton.topAnchor.constraint(equalTo: publicButton.topAnchor).isActive = true
        privateButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        // Add Button
        addEventButton.translatesAutoresizingMaskIntoConstraints = false
        addEventButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -40).isActive = true
        addEventButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
        addEventButton.heightAnchor.constraint(equalToConstant: pageTitleLabel.intrinsicContentSize.height).isActive = true
        addEventButton.widthAnchor.constraint(equalTo: addEventButton.heightAnchor).isActive = true
    }

}



//MARK: - TableDelegate
extension EventFinderViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

//MARK: TableDataSource
extension EventFinderViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        view.backgroundColor = .zipLightGray
        
        let title = UILabel()
        switch section {
        case 0:  title.text = "Today"
        case 1:  title.text = "Upcoming"
        default:  title.text = "default"
        }
        
        title.font = .zipBody
        title.textColor = .white
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true

        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellEvent = tableData[indexPath.section][indexPath.row]
        
        let eventView = EventViewController()
        eventView.configure(cellEvent)
        eventView.modalPresentationStyle = .overCurrentContext
        present(eventView, animated: false, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellEvent = tableData[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(cellEvent)
        return cell
    }
    
}

//MARK: -Handle Retap
extension EventFinderViewController: TabBarReselectHandling {
    func handleReselect() {
        if self.presentedViewController != nil {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

//MARK: Generate Data
extension EventFinderViewController {
    func generateTestData(){
        var yiannipics = [UIImage]()
        var interests = [String]()
        
        interests.append("Chess")
        interests.append("Coding")
        interests.append("\"Getting Bitches\"")
        interests.append("Grinding Zipper")
        interests.append("Bar Hopping/Clubbing🍻")


        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        
        let yianni = User(userID: 3,
                          email: "zavalyia@gmail.com",
                          username: "yianni_zav",
                          name: "Yianni Zavaliagkos",
                          birthday: yianniBirthday,
                          location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                          pictures: yiannipics,
                          bio: "Yianni Zavaliagkos. Second Year at Mcgill. Add my snap and follow my insta @Yianni_Zav. I run this shit. Remember my name when I pass Zuckerberg on Forbes",
                          school: "McGill University",
                          interests: interests)
        
        
        launchEvent = Event(title: "Zipper Launch Party",
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
        
        fakeFroshEvent = Event(title: "Fake Ass Frosh",
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
        
        spikeBallEvent = Event(title: "Zipper Spikeball Tournament",
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
    }
    
    
    
}
