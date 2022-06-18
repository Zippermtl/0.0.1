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
    var tableView = UITableView()

    var launchEvent = Event()
    var fakeFroshEvent = Event()
    var spikeBallEvent = Event()
    
    var eventData: [Event] = []
    var publicTableData: [[Event]] = [[],[]]
    var privateTableData: [[Event]] = [[],[]]
    var tableData: [[Event]] = [[],[]]
    
    // MARK: - Buttons
    var publicButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipVeryLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        btn.setTitle("PUBLIC", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    var privateButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        btn.setTitle("PRIVATE", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = 10
        return btn
    }()
    
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
                                            message: "Which type of event would you like to create",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Private",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let privateEvent = NewPrivateEventViewController()
                                                privateEvent.modalPresentationStyle = .overCurrentContext
                                                self?.navigationController?.pushViewController(privateEvent, animated: true)
                                                print("new event tapped")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Public",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let publicEvent = NewPublicEventViewController()
                                                publicEvent.modalPresentationStyle = .overCurrentContext
                                                self?.navigationController?.pushViewController(publicEvent, animated: true)
                                                print("new event tapped")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Promoter",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let publicEvent = NewPublicEventViewController()
                                                publicEvent.modalPresentationStyle = .overCurrentContext
                                                self?.navigationController?.pushViewController(publicEvent, animated: true)
                                                print("new event tapped")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .default,
                                            handler: nil))
        present(actionSheet, animated: true)
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        generateTestData()
        eventData.append(launchEvent)
        eventData.append(fakeFroshEvent)
        eventData.append(spikeBallEvent)

        configureNavBar()
        configureEventLists()
        configureTable()
        configureButtons()

    }
    
    
    
    private func configureNavBar(){
        navigationItem.title = "EVENTS"

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "add")!.withRenderingMode(.alwaysOriginal),
                                                            landscapeImagePhone: nil,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapAddButton))
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    //MARK: - Event Data Config
    private func configureEventLists() {
        let userCalendar = Calendar.current
        publicTableData[0] = eventData.filter { $0.isPublic() &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day == 0 }
        publicTableData[1] = eventData.filter { $0.isPublic() &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day != 0 }
        privateTableData[0] = eventData.filter { !$0.isPublic() &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day == 0 }
        privateTableData[1] = eventData.filter { !$0.isPublic() &&
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
//        tableView.sectionHeaderTopPadding = 0

        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        
        //layout and constraints
        view.addSubview(tableView)
        view.addSubview(publicButton)
        view.addSubview(privateButton)
        
        //TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: publicButton.bottomAnchor, constant: 5).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        // Public Button
        publicButton.translatesAutoresizingMaskIntoConstraints = false
        publicButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        publicButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        publicButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Private Button
        privateButton.translatesAutoresizingMaskIntoConstraints = false
        privateButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        privateButton.leftAnchor.constraint(equalTo: publicButton.rightAnchor, constant: 10).isActive = true
        privateButton.topAnchor.constraint(equalTo: publicButton.topAnchor).isActive = true
        privateButton.widthAnchor.constraint(equalTo: publicButton.widthAnchor).isActive = true
        privateButton.heightAnchor.constraint(equalTo: publicButton.heightAnchor).isActive = true
    }
    
    //MARK: - Button Config
    private func configureButtons(){
        publicButton.addTarget(self, action: #selector(didTapPublicButton), for: .touchUpInside)
        privateButton.addTarget(self, action: #selector(didTapPrivateButton), for: .touchUpInside)
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
 
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
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
        
        navigationController?.pushViewController(eventView, animated: true)
        
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


//MARK: Generate Data
extension EventFinderViewController {
    func generateTestData(){
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
        
        
        launchEvent = PromoterEvent(title: "Zipper Launch Party",
                            hosts: [yianni],
                            description: "Come experience the release and launch of Zipper! Open Bar! Zipper profiles and ID's will be checked at the door. Must be 18 years or older",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [yianni],
                            usersInterested: [yianni],
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "launchevent")!)
        
        fakeFroshEvent = PublicEvent(title: "Fake Ass Frosh",
                            hosts: [yianni],
                            description: "The FitnessGram™ Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. Ding  A single lap should be completed each time you hear this sound. Ding  Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, ding",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [yianni],
                            usersInterested: [yianni],
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "muzique")!)
        
        spikeBallEvent = PublicEvent(title: "Zipper Spikeball Tournament",
                            hosts: [yianni],
                            description: "Zipper Spikeball Tournament",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [yianni],
                            usersInterested: [yianni],
                            startTime: Date(timeIntervalSinceNow: 100000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "spikeball"))
    }
    
    
    
}


class BackBarButtonItem: UIBarButtonItem {
  @available(iOS 14.0, *)
  override var menu: UIMenu? {
    set {
      /* Don't set the menu here */
      /* super.menu = menu */
    }
    get {
      return super.menu
    }
  }
}
