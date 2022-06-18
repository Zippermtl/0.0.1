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
        "Upcoming" : ["Hosting" : [],
                      "Going" : [],
                      "Interested" : []],
        "Previous" : ["Hosted" : [],
                      "Went" : []]
    ]
    
    var tableData: [String:[Event]] =
    [
        "Hosting" : [Event](),
        "Going" : [Event](),
        "Interested" : [Event]()
    ]
    
    // MARK: - Buttons
    var upcomingButton = UIButton()
    var previousButton = UIButton()
    
    // MARK: - Button Actions
    @objc private func didTapBackButton(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapUpcomingButton() {
        upcomingButton.backgroundColor = .zipVeryLightGray
        previousButton.backgroundColor = .zipLightGray
        tableData = eventData["Upcoming"]!
        tableView.reloadData()
    }
    
    @objc private func didTapPreviousButton() {
        previousButton.backgroundColor = .zipVeryLightGray
        upcomingButton.backgroundColor = .zipLightGray
        tableData = eventData["Previous"]!
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
        navigationItem.title = "MY EVENTS"
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
        
        tableData = eventData["Upcoming"]!
    }
    
    //MARK: - Button Config
    private func configureButtons(){
        let width = view.frame.size.width
        upcomingButton = UIButton(frame: CGRect(x: 0, y: 0, width: width/2-20, height: 40))
        upcomingButton.backgroundColor = .zipVeryLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        upcomingButton.setTitle("UPCOMING", for: .normal)
        upcomingButton.titleLabel?.textColor = .white
        upcomingButton.titleLabel?.font = .zipBodyBold
        upcomingButton.titleLabel?.textAlignment = .center
        upcomingButton.contentVerticalAlignment = .center
        upcomingButton.layer.cornerRadius = 10
        
        previousButton = UIButton(frame: CGRect(x: 0, y: 0, width: width/2-20, height: 40))
        previousButton.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        previousButton.setTitle("PREVIOUS", for: .normal)
        previousButton.titleLabel?.textColor = .white
        previousButton.titleLabel?.font = .zipBodyBold
        previousButton.titleLabel?.textAlignment = .center
        previousButton.contentVerticalAlignment = .center
        previousButton.layer.cornerRadius = 10
        
        upcomingButton.addTarget(self, action: #selector(didTapUpcomingButton), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
        
    }
    
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        view.addSubview(tableView)
        view.addSubview(upcomingButton)
        view.addSubview(previousButton)
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: upcomingButton.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Public Button
        upcomingButton.translatesAutoresizingMaskIntoConstraints = false
        upcomingButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        upcomingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        upcomingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Private Button
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        previousButton.leftAnchor.constraint(equalTo: upcomingButton.rightAnchor, constant: 10).isActive = true
        previousButton.widthAnchor.constraint(equalTo: upcomingButton.widthAnchor).isActive = true
        previousButton.topAnchor.constraint(equalTo: upcomingButton.topAnchor).isActive = true
        previousButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
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
        if tableData.count == 2 {
            switch section{
            case 0: title.text = "Hosted"
            case 1: title.text = "Went"
            default: print("section out of range")
            }
        } else {
            switch section{
            case 0: title.text = "Hosting"
            case 1: title.text = "Going"
            case 2: title.text = "Interested"
            default: print("section out of range")
            }
        }
        
        title.font = .zipBody
        title.textColor = .white
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData.count == 2 {
            switch section{
            case 0: return tableData["Hosted"]!.count
            case 1: return tableData["Went"]!.count
            default: return 0
            }
        } else {
            switch section{
            case 0: return tableData["Hosting"]!.count
            case 1: return tableData["Going"]!.count
            case 2: return tableData["Interested"]!.count
            default: return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sectionName = ""
        if tableData.count == 2 {
            switch indexPath.section{
            case 0: sectionName = "Hosted"
            case 1: sectionName = "Went"
            default: print("section out of range")
            }
        } else {
            switch indexPath.section {
            case 0: sectionName = "Hosting"
            case 1: sectionName = "Going"
            case 2: sectionName = "Interested"
            default: print("section out of range")
            }
        }
        
        guard let events = tableData[sectionName] else {
            return
        }
        
        let cellEvent = events[indexPath.row]
        
        if sectionName == "Hosting" || sectionName == "Hosted" {
            let eventView = MyEventViewController()
            eventView.configure(cellEvent)
            eventView.modalPresentationStyle = .overCurrentContext
            navigationController?.pushViewController(eventView, animated: true)
        } else {
            let eventView = EventViewController()
            eventView.configure(cellEvent)
            eventView.modalPresentationStyle = .overCurrentContext
            navigationController?.pushViewController(eventView, animated: true)
        }
    
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var events = [Event]()
        switch Array(tableData.keys)[indexPath.section] {
        case "Hosting": events = tableData["Hosting"]!
        case "Going": events = tableData["Going"]!
        case "Interested": events = tableData["Interested"]!
        case "Hosted": events = tableData["Hosted"]!
        case "Went": events = tableData["Went"]!
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
        
        eventData["Upcoming"]?["Hosting"]?.append(launchEvent)
        eventData["Upcoming"]?["Going"]?.append(spikeBallEvent)
        eventData["Upcoming"]?["Interested"]?.append(fakeFroshEvent)

    }
    
}
