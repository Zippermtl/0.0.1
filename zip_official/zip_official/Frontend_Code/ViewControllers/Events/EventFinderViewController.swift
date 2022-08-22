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
        btn.setTitle("Public", for: .normal)
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
        btn.setTitle("Private", for: .normal)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        fetchEvents()

        configureNavBar()
        configureEventLists()
        configureTable()
        configureButtons()
    }
    
    private func configureNavBar(){
        navigationItem.title = "Find Events"
        

        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
    }
    
    //MARK: - Event Data Config
    private func configureEventLists() {
        let userCalendar = Calendar.current
        publicTableData[0] = eventData.filter { ($0.getType() == .Public || $0.getType() == .Promoter) &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day == 0 }
        publicTableData[1] = eventData.filter { ($0.getType() == .Public || $0.getType() == .Promoter) &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day != 0 }
        privateTableData[0] = eventData.filter { $0.getType() == .Private &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day == 0 }
        privateTableData[1] = eventData.filter { $0.getType() == .Private  &&
                                                userCalendar.dateComponents([.day], from: Date(), to: $0.startTime).day != 0 }
        tableData = publicTableData
    }
    
    private func fetchEvents(){
        DatabaseManager.shared.getAllPrivateEventsForMap(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.eventData.append(event)
        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
//            strongSelf.tableView.reloadData()
            strongSelf.configureEventLists()
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        })
        
        DatabaseManager.shared.getAllPublic(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.eventData.append(event)
//            strongSelf.configureEventLists()

        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.configureEventLists()
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
            
        })
        
        DatabaseManager.shared.getAllPromoter(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.eventData.append(event)
        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.configureEventLists()
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
            
        })

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
        
        let eventView = EventViewController(event: cellEvent)
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
        cellEvent.tableViewCell = cell
        cell.configure(cellEvent)
        return cell
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
