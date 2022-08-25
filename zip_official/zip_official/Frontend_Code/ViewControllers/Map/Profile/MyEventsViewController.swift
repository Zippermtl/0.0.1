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
                   "Upcoming" : [],
                   "Previous": []],
        "Hosting" : ["Today" : [],
                     "Upcoming" : [],
                     "Previous": []]
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
    
    var hostEvents: [Event]
    var saveEvents: [Event]
    var goingEvents: [Event]
    
    var tableState: String
    
    // MARK: - Button Actions
    @objc private func didTapBackButton(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapGoingButton() {
        goingButton.backgroundColor = .zipVeryLightGray
        savedButton.backgroundColor = .zipLightGray
        hostingButton.backgroundColor = .zipLightGray
        tableData = eventData["Going"]!
        tableState = "Going"
        tableView.reloadData()
    }
    
    @objc private func didTapSavedButton() {
        savedButton.backgroundColor = .zipVeryLightGray
        goingButton.backgroundColor = .zipLightGray
        hostingButton.backgroundColor = .zipLightGray
        tableState = "Saved"
        tableData = eventData["Saved"]!
        tableView.reloadData()
    }
    
    @objc private func didTapHostingButton() {
        savedButton.backgroundColor = .zipLightGray
        goingButton.backgroundColor = .zipLightGray
        hostingButton.backgroundColor = .zipVeryLightGray
        tableData = eventData["Hosting"]!
        tableState = "Host"
        tableView.reloadData()
    }

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray

        configureNavBar()
        configureTable()
        configureButtons()
        configureSubviewLayout()
    }
    
    init() {
        tableState = "Going"
        let hostedIds = AppDelegate.userDefaults.value(forKey: "hostedEvents") as? [String] ?? []
        self.hostEvents = hostedIds.map({ Event(eventId: $0) })
        let savedEventsIds = AppDelegate.userDefaults.value(forKey: "savedEvents") as? [String] ?? []
        let goingEventsIds = AppDelegate.userDefaults.value(forKey: "goingEvents") as? [String] ?? []
        self.saveEvents = savedEventsIds.map({Event(eventId: $0)})
        self.goingEvents = goingEventsIds.map({Event(eventId: $0)})
        super.init(nibName: nil, bundle: nil)
//        fetchEvents()
        loadEvents()
        print("GOING EVENTS ", goingEvents)
        print("SAVED EVENTS ", saveEvents)
        print("HOST EVENTS ", hostEvents)

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchEvents() {
//        DatabaseManager.shared.getAllHostedEventsForMap(eventCompletion: { [weak self] event in
//            guard let strongSelf = self else {
//                return
//            }
//            strongSelf.hostEvents.append(even)
//        }, allCompletion: { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//
//            strongSelf.loadEvents()
//        })
    }
    
    private func loadEvents() {
        var hostCount = 0
        let hostTotal = hostEvents.count
        for event in hostEvents {
            DatabaseManager.shared.eventLoadTableView(event: event, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let event):
                    if event.endTime < Date() {
                        strongSelf.eventData["Hosting"]!["Previous"]!.append(event)
                    } else if Calendar.current.isDateInToday(event.startTime) {
                        strongSelf.eventData["Hosting"]!["Today"]!.append(event)
                    } else {
                        strongSelf.eventData["Hosting"]!["Upcoming"]!.append(event)
                    }
                    hostCount+=1
                    if strongSelf.tableState == "Host" && hostCount == hostTotal {
                        DispatchQueue.main.async {
                            strongSelf.tableData = strongSelf.eventData["Hosting"]!
                            strongSelf.tableView.reloadData()
                        }
                    }
                case .failure(let error):
                    strongSelf.hostEvents.removeAll(where: { $0 == event })
                    print("error loading event with id: \(event.eventId) with Error: \(error)")
                    hostCount+=1
                    if strongSelf.tableState == "Host" && hostCount == hostTotal {
                        DispatchQueue.main.async {
                            strongSelf.tableData = strongSelf.eventData["Hosting"]!
                            strongSelf.tableView.reloadData()
                        }
                    }
                }
                
            })
        }
        
        var goingCount = 0
        let goingTotal = goingEvents.count
        for event in goingEvents {
            DatabaseManager.shared.eventLoadTableView(event: event, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(_):
                    if event.endTime < Date() {
                        strongSelf.eventData["Going"]!["Previous"]!.append(event)
                    } else if Calendar.current.isDateInToday(event.startTime) {
                        strongSelf.eventData["Going"]!["Today"]!.append(event)
                    } else {
                        strongSelf.eventData["Going"]!["Upcoming"]!.append(event)
                    }
                    goingCount+=1
                    if strongSelf.tableState == "Going" && goingCount == goingTotal {
                        DispatchQueue.main.async {
                            strongSelf.tableData = strongSelf.eventData["Going"]!
                            strongSelf.tableView.reloadData()
                        }
                    }
                case .failure(let error):
                    strongSelf.goingEvents.removeAll(where: { $0 == event })
                    print("error loading event with id: \(event.eventId) with Error: \(error)")
                    goingCount+=1
                    if strongSelf.tableState == "Going" && goingCount == goingTotal {
                        DispatchQueue.main.async {
                            strongSelf.tableData = strongSelf.eventData["Going"]!
                            strongSelf.tableView.reloadData()
                        }
                    }
                }
                
            })
        }
        
        var saveCount = 0
        let saveTotal = saveEvents.count
        for event in saveEvents {
            DatabaseManager.shared.eventLoadTableView(event: event, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(_):
                    if event.endTime < Date() {
                        strongSelf.eventData["Saved"]!["Previous"]!.append(event)
                    } else if Calendar.current.isDateInToday(event.startTime) {
                        strongSelf.eventData["Saved"]!["Today"]!.append(event)
                    } else {
                        strongSelf.eventData["Saved"]!["Upcoming"]!.append(event)
                    }
                    saveCount+=1
                    if strongSelf.tableState == "Saved" && saveCount == saveTotal {
                        DispatchQueue.main.async {
                            strongSelf.tableData = strongSelf.eventData["Saved"]!
                            strongSelf.tableView.reloadData()
                        }
                    }
                case .failure(let error):
                    strongSelf.saveEvents.removeAll(where: { $0 == event })
                    print("error loading event with id: \(event.eventId) with Error: \(error)")
                    saveCount+=1
                    if strongSelf.tableState == "Saved" && saveCount == saveTotal {
                        DispatchQueue.main.async {
                            strongSelf.tableData = strongSelf.eventData["Saved"]!
                            strongSelf.tableView.reloadData()
                        }
                    }
                }
            })
        }
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
        
        switch section{
        case 0: title.text = "Today"
        case 1: title.text = "Upcoming"
        case 2: title.text = "Previous"
        default: print("section out of range")
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

        switch section{
        case 0: return tableData["Today"]!.count
        case 1: return tableData["Upcoming"]!.count
        case 2: return tableData["Previous"]!.count
        default: return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let event
//        if event.ownerId == AppDelegate.userDefaults.value(forKey: "userId") as! String {
//            let vc = MyEventViewController(event: event)
//            navigationController?.pushViewController(vc, animated: true)
//        } else {
//            let vc = EventViewController(event: event)
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var events = [Event]()
        switch indexPath.section {
        case 0: events = tableData["Today"]!
        case 1: events = tableData["Upcoming"]!
        case 2: events = tableData["Previous"]!
        default: print("section out of range")
        }
        
        let cellEvent = events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell
        cellEvent.tableViewCell = cell
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(cellEvent)
        return cell
    }
}
