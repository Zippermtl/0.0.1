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
    var headerView = UIView()
    var tableView = UITableView()
    
    var upcomingEvents: [[Event]] = [[],[]]
    var previousEvents: [[Event]] = [[]]
    
    var tableData: [[Event]] = []
    
    
    // MARK: - Labels
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "MY EVENTS"
        return label
    }()
    
    // MARK: - Buttons
    var upcomingButton = UIButton()
    var previousButton = UIButton()
    var backButton = UIButton()
    
    // MARK: - Button Actions
    @objc private func didTapBackButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapUpcomingButton(){
        upcomingButton.backgroundColor = .zipVeryLightGray
        previousButton.backgroundColor = .zipLightGray
        tableData = upcomingEvents
        tableView.reloadData()
    }
    
    @objc private func didTapPreviousButton(){
        previousButton.backgroundColor = .zipVeryLightGray
        upcomingButton.backgroundColor = .zipLightGray
        tableData = previousEvents
        tableView.reloadData()
    }

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        generateTestData()

        configureTable()
        configureButtons()
        addSubviews()
        configureSubviewLayout()
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
        
        tableData = upcomingEvents
    }
    //MARK: - Button Config
    private func configureButtons(){
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)

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
        
        addButtonTargets()
    }
    
    private func addButtonTargets(){
        // topViewContainer
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        upcomingButton.addTarget(self, action: #selector(didTapUpcomingButton), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
    }
    
    private func addSubviews(){
        // Header
        view.addSubview(headerView)
        headerView.addSubview(pageTitleLabel)
        headerView.addSubview(upcomingButton)
        headerView.addSubview(previousButton)
        headerView.addSubview(backButton)
        
        // Table Views
        view.addSubview(tableView)
    }
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        configureHeader()

        // TableView
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
        headerView.bottomAnchor.constraint(equalTo: upcomingButton.bottomAnchor, constant: 10).isActive = true
        headerView.backgroundColor = .zipGray
        
        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor,constant: 20).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true

        // Public Button
        upcomingButton.translatesAutoresizingMaskIntoConstraints = false
        upcomingButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        upcomingButton.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 10).isActive = true
        upcomingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Private Button
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        previousButton.leftAnchor.constraint(equalTo: upcomingButton.rightAnchor, constant: 10).isActive = true
        previousButton.widthAnchor.constraint(equalTo: upcomingButton.widthAnchor).isActive = true
        previousButton.topAnchor.constraint(equalTo: upcomingButton.topAnchor).isActive = true
        previousButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //Back button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: pageTitleLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
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
        
        if tableView.numberOfSections == 2 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
            view.backgroundColor = .zipLightGray
            let title = UILabel()

            switch section {
            case 0:  title.text = "Going"
            case 1:  title.text = "Interested"
            default:  title.text = "default"
            }
            
            title.font = .zipBody
            title.textColor = .white
            view.addSubview(title)
            title.translatesAutoresizingMaskIntoConstraints = false
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true

            return view
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
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
        if tableView.numberOfSections == 2 {
            return 30
        }
        return 0
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


extension MyEventsViewController {
    func generateTestData(){
        var launchEvent = Event()
        var fakeFroshEvent = Event()
        var spikeBallEvent = Event()
        
        
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
                            type: "n/a",
                            isPublic: true,
                            startTime: Date(timeIntervalSinceNow: 100000),
                            duration: TimeInterval(1000),
                            image: UIImage(named: "spikeball"))
        
        upcomingEvents[0].append(launchEvent)
        upcomingEvents[1].append(spikeBallEvent)
        previousEvents[0].append(fakeFroshEvent)
    }
    
}
