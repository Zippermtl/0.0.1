//
//  MyEventsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/22/21.
//

import UIKit
import MapKit
import CoreLocation


class MyEventsViewController: UIViewController {
    var tableView = UITableView()
    
    var eventData: [String:[String:[Event]]] =
    [
        "Going" : ["Today" : [],
                   "Upcoming" : [],
                   "Previous" : []],
        "Saved" : ["Today" : [],
                   "Upcoming" : []],
        "Hosting" : ["Today" : [],
                     "Upcoming" : [],
                     "Previous": []],
    ]
    
    var tableData: [String:[Event]] =
    [
        "Today" : [],
        "Upcoming" : [],
        "Previous" : []
    ]
    
    // MARK: - Buttons
    var goingButton = UIButton()
    var savedButton = UIButton()
    var hostingButton = UIButton()
    
    // MARK: - Button Actions
    @objc private func didTapBackButton(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapGoingButton() {
        goingButton.backgroundColor = .zipVeryLightGray
        savedButton.backgroundColor = .zipLightGray
        hostingButton.backgroundColor = .zipLightGray
        tableData = eventData["Going"]!
        tableView.reloadData()
    }
    
    @objc private func didTapSavedButton() {
        savedButton.backgroundColor = .zipVeryLightGray
        goingButton.backgroundColor = .zipLightGray
        hostingButton.backgroundColor = .zipLightGray

        tableData = eventData["Saved"]!
        tableView.reloadData()
    }
    
    @objc private func didTapHostingButton() {
        savedButton.backgroundColor = .zipLightGray
        goingButton.backgroundColor = .zipLightGray
        hostingButton.backgroundColor = .zipVeryLightGray
        tableData = eventData["Hosting"]!
        tableView.reloadData()
    }

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        generateTestData()

        configureNavBar()
        configureTable()
        configureButtons()
        configureSubviewLayout()
    }
    
    private func configureNavBar() {
        navigationItem.title = "My Events"
    }
    
    //MARK: - Table Config
    private func configureTable(){
        // TableView
        tableView.register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        
        tableData = eventData["Going"]!
    }
    
    //MARK: - Button Config
    private func configureButtons(){
        goingButton.backgroundColor = .zipVeryLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        goingButton.setTitle("Going", for: .normal)
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipSubtitle2
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
        goingButton.layer.cornerRadius = 10
        
        savedButton.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        savedButton.setTitle("Saved", for: .normal)
        savedButton.titleLabel?.textColor = .white
        savedButton.titleLabel?.font = .zipSubtitle2
        savedButton.titleLabel?.textAlignment = .center
        savedButton.contentVerticalAlignment = .center
        savedButton.layer.cornerRadius = 10
        
        hostingButton.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        hostingButton.setTitle("Hosting", for: .normal)
        hostingButton.titleLabel?.textColor = .white
        hostingButton.titleLabel?.font = .zipSubtitle2
        hostingButton.titleLabel?.textAlignment = .center
        hostingButton.contentVerticalAlignment = .center
        hostingButton.layer.cornerRadius = 10
        
        goingButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        savedButton.addTarget(self, action: #selector(didTapSavedButton), for: .touchUpInside)
        hostingButton.addTarget(self, action: #selector(didTapHostingButton), for: .touchUpInside)

    }
    
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        view.addSubview(tableView)

        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Public Button
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        header.addSubview(goingButton)
        header.addSubview(savedButton)
        header.addSubview(hostingButton)
        
        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        goingButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        goingButton.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        goingButton.rightAnchor.constraint(equalTo: savedButton.leftAnchor, constant: -10).isActive = true
        
        // Private Button
        savedButton.translatesAutoresizingMaskIntoConstraints = false
        savedButton.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        savedButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        savedButton.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        savedButton.widthAnchor.constraint(equalTo: goingButton.widthAnchor).isActive = true
        
        
        hostingButton.translatesAutoresizingMaskIntoConstraints = false
        hostingButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -10).isActive = true
        hostingButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        hostingButton.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        hostingButton.leftAnchor.constraint(equalTo: savedButton.rightAnchor, constant: 10).isActive = true
        
        tableView.tableHeaderView = header
    }

}


//MARK: - TableDelegate
extension MyEventsViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}


//MARK: TableDataSource
extension MyEventsViewController :  UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        view.backgroundColor = .zipLightGray
        let title = UILabel()
        if tableData.count == 1 {
            title.text = ""
        } else if tableData.count == 2 {
            switch section{
            case 0: title.text = "Today"
            case 1: title.text = "Upcoming"
            default: print("section out of range")
            }
        } else {
            switch section{
            case 0: title.text = "Today"
            case 1: title.text = "Upcoming"
            case 2: title.text = "Previous"
            default: print("section out of range")
            }
        }
        
        title.font = .zipTextNoti
        title.textColor = .white
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData.count == 1 {
            return tableData["Previous"]!.count
        }
        if tableData.count == 2 {
            switch section{
            case 0: return tableData["Today"]!.count
            case 1: return tableData["Upcoming"]!.count
            default: return 0
            }
        } else {
            switch section{
            case 0: return tableData["Today"]!.count
            case 1: return tableData["Upcoming"]!.count
            case 2: return tableData["Previous"]!.count
            default: return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var events = [Event]()
        switch Array(tableData.keys)[indexPath.section] {
        case "Today": events = tableData["Today"]!
        case "Upcoming": events = tableData["Upcoming"]!
        case "Previous": events = tableData["Previous"]!
        default: print("section out of range")
        }
        
        let cellEvent = events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(cellEvent)
        return cell
    }
}


extension MyEventsViewController {
    func generateTestData(){
        var launchEvent = Event()
        var fakeFroshEvent = Event()
        var spikeBallEvent = Event()
        
        
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
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "launchevent")!)
        
        fakeFroshEvent = PublicEvent(title: "Fake Ass Frosh",
                            hosts: [yianni],
                            description: "The FitnessGram™ Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. Ding  A single lap should be completed each time you hear this sound. Ding  Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, ding",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "muzique")!)
        
        spikeBallEvent = PublicEvent(title: "Zipper Spikeball Tournament",
                            hosts: [yianni],
                            description: "Zipper Spikeball Tournament",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            startTime: Date(timeIntervalSinceNow: 100000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "spikeball"))
        
        eventData["Going"]?["Today"]?.append(launchEvent)
        eventData["Going"]?["Upcoming"]?.append(spikeBallEvent)
        eventData["Going"]?["Previous"]?.append(fakeFroshEvent)

    }
    
}
