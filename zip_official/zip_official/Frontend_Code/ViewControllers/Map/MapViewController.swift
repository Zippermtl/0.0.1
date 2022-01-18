//
//  MapViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/15/21.
//

/*
 
 
 /Users/yiannizavaliagkos/Desktop/Zip/fontend/zip_official/zip_official/Frontend_Code/ViewControllers/Map/MapViewController.swift
 
 
 */


import UIKit
import MapKit
import CoreLocation
import CoreGraphics
import SDWebImage
import FloatingPanel

//MARK: View Controller
class MapViewController: UIViewController {
    static let title = "MapVC"
    static let profileIdentifier = "profile"

    var isNewAccount = false
    let locationManager = CLLocationManager()
    var userLoc = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    let fpc = FloatingPanelController()


    // MARK: - Events
    //to be brought in via json file
    //func loadEventData()
    var user = User()
    var launchEvent = Event()
    var randomEvent = Event()
    
    // MARK: - Data
    private var events: [Event] = []
    
    // MARK: - Subviews
    private var mapView: MKMapView?
    
    private var profileButton = UIButton()
    
    var guardingGeoFireCalls = false
    
    // MARK: - Button Actions
    @objc private func didTapHomeButton(){
        if(ZipperTabBarViewController.userLoc != nil ){
            zoomToLatestLocation(with: userLoc)
        }
    }
    
    @objc private func didTapFilterButton(){
        //        filterButton.isHidden = true
//        let filtersVC = FiltersViewController()
//        filtersVC.delegate = self
//        filtersVC.modalPresentationStyle = .overCurrentContext
//        present(filtersVC, animated: true, completion: nil)
    }
    
    @objc func didTapProfileButton() {
//        createNewUsersInDB()
//        updateUsersInDB()
        
        
        let vc = ProfileViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext
        present(nav, animated: true, completion: nil)
    }


    // MARK: ViewDidLoad
    // essentially the main
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            overrideUserInterfaceStyle = .dark
        }
//        AppDelegate.locationManager.requexstWhenInUseAuthorization()

        
        view.backgroundColor = .zipGray
        mapView = MKMapView()

        mapView?.showsCompass = false
        mapView?.pointOfInterestFilter = .excludingAll
        
        configureLocationServices()
        
        generateTestData()
        
        definesPresentationContext = true
        configureProfilePicture()
        configureNavBar()
        configureSubviews()
        configureFloatingPanel()
        configureAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        navigationController?.navigationBar.isHidden = true
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        isNewAccount = true
        if isNewAccount {
            isNewAccount = false
            let vc = NewAccountPopupViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    
    }
    
    private func configureProfilePicture(){
        if let urlString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String {
            let url = URL(string: urlString)
            profileButton.sd_setImage(with: url, for: .normal, completed: nil)
        } else {
            profileButton.setImage(UIImage(named: "profilePicture"), for: .normal)
        }
        
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)

        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = 25
        profileButton.layer.borderColor = UIColor.zipVeryLightGray.cgColor //UIColor.zipVeryLightGray.cgColor
        profileButton.layer.borderWidth = 1
    }
    
    private func configureFloatingPanel() {
        fpc.delegate = self
        
        let fpcContent = FPCViewController()
        fpcContent.configure(userLocation: CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude))
        fpc.layout = ZipFloatingPanelLayout()
        fpcContent.delegate = self
        
        fpc.set(contentViewController: fpcContent)
        fpc.addPanel(toParent: self)
        
        // Create a new appearance.
        let appearance = SurfaceAppearance()

        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = .clear

        // Set the new appearance
        fpc.surfaceView.appearance = appearance
        
    }


    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationController?.navigationBar.isHidden = true
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D, animated: Bool = true){
        guard let mapView = mapView else {
            return
        }
        
        //change 20000,20000 so that it fits all 3 rings
        let zoomDistance = CGFloat(2000)
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: zoomDistance,longitudinalMeters: zoomDistance)
        mapView.setRegion(zoomRegion, animated: animated)
    }
    
    
    //MARK: - Configure Subviews
    private func configureSubviews(){
        guard let mapView = mapView else {
            return
        }
        
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -45).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true

        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        profileButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor).isActive = true
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
    }
    

    //MARK: - Annotation Config
    // regisers annotation views and adds them to map
    func configureAnnotations(){
        guard let mapView = mapView else {
            return
        }
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: EventAnnotation.identifier)

        //Events
        // MARK: London
        let event1 = EventAnnotation(event: launchEvent, coordinate:  CLLocationCoordinate2D(latitude: 51.5014, longitude: -0.1419))
        let event2 = EventAnnotation(event: randomEvent, coordinate: CLLocationCoordinate2D(latitude: 51.5313, longitude: -0.1570))
        
        //MARK: Montreal
//        let event1 = EventAnnotation(event: launchEvent, coordinate:  CLLocationCoordinate2D(latitude: 45.5317, longitude: -73.5873))
//        let event2 = EventAnnotation(event: randomEvent, coordinate: CLLocationCoordinate2D(latitude: 45.4817, longitude: -73.4873))
        
        mapView.addAnnotation(event1)
        mapView.addAnnotation(event2)
    }

}

//MARK: -  Location Services
extension MapViewController: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        userLoc = latestLocation.coordinate
        
        AppDelegate.userDefaults.set([userLoc.latitude, userLoc.longitude], forKey: "userLoc")

        if !guardingGeoFireCalls {
            GeoManager.shared.UpdateLocation(location: latestLocation)
            let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
            GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: 2, max: 3, completion: {

                GeoManager.shared.LoadNextUsers(size: 10, completion: {
                })

            })
            guardingGeoFireCalls = true
            zoomToLatestLocation(with: userLoc)
        }
    }
    
    // change auuthorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    @objc  func configureLocationServices(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    //start location updates
    private func beginLocationUpdates(locationManager: CLLocationManager){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
    }
}

extension MapViewController: FPCMapDelegate {
    func openZipFinder() {
        let zipFinder = ZipFinderViewController()
        zipFinder.delegate = self
        zipFinder.userLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        let vc = UINavigationController(rootViewController: zipFinder)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
    }
    
    func findEvents() {
        let vc = EventFinderViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
        
    }
    
    func createEvent() {
        let vc = CreateEventViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
        
//        let actionSheet = UIAlertController(title: "Create an Event",
//                                            message: "Which type of event would you like to create",
//                                            preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Private",
//                                            style: .default,
//                                            handler: { [weak self] _ in
//            let privateEvent = NewPrivateEventViewController()
//            let nav = UINavigationController(rootViewController: privateEvent)
//            nav.modalPresentationStyle = .fullScreen
//            self?.present(nav, animated: true, completion: { [weak self] in
//                self?.fpc.move(to: .tip, animated: true, completion: nil)
//            })
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Public",
//                                            style: .default,
//                                            handler: { [weak self] _ in
//            let publicEvent = NewPublicEventViewController()
//            let nav = UINavigationController(rootViewController: publicEvent)
//            nav.modalPresentationStyle = .fullScreen
//            self?.present(nav, animated: true, completion: { [weak self] in
//                self?.fpc.move(to: .tip, animated: true, completion: nil)
//            })
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Promoter",
//                                            style: .default,
//                                            handler: { [weak self] _ in
//            let publicEvent = NewPublicEventViewController()
//            let nav = UINavigationController(rootViewController: publicEvent)
//            nav.modalPresentationStyle = .fullScreen
//            self?.present(nav, animated: true, completion: { [weak self] in
//                self?.fpc.move(to: .tip, animated: true, completion: nil)
//            })
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel",
//                                            style: .default,
//                                            handler: nil))
//        present(actionSheet, animated: true)
    }
    
    func openMessages() {
        let vc = ZipMessagesViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
    }
    
    func openNotifications() {
        fpc.move(to: .tip, animated: true, completion: nil)
        let vc = NotificationsViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
        
    }
    
    func openFPC() {
        fpc.move(to: .full, animated: true, completion: nil)
    }
}



// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let eventAnnotation = annotation as? EventAnnotation {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EventAnnotation.identifier) else {
                return MKAnnotationView()
            }
            
            let img = UIImageView(image: eventAnnotation.event.image)
            annotationView.addSubview(img)
            annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

            img.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            img.layer.cornerRadius = img.frame.height/2
            img.layer.masksToBounds = true
            img.layer.borderWidth = 1
            switch eventAnnotation.event.type {
            case "promoter": img.layer.borderColor = CGColor(red: 1, green: 1, blue: 0, alpha: 1)
            case "innerCircle": img.layer.borderColor = CGColor(red: 35/255, green: 207/255, blue: 244/255, alpha: 1)
            default: break
            }
            
            annotationView.canShowCallout = false
            return annotationView
        }

        return nil
    }
    
    //did select is how you click annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.isZoomEnabled = true
        if let annotation = view.annotation as? EventAnnotation {
            let eventVC = EventViewController()
            eventVC.configure(annotation.event)
            
            let nav = UINavigationController(rootViewController: eventVC)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .coverVertical
            present(nav, animated: true, completion: nil)
//            navigationController?.navigationBar.isHidden = false
//            navigationController?.pushViewController(eventVC, animated: true)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
}

//MARK: Floating Panel Delegate
extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanelWillBeginDragging(_ fpc: FloatingPanelController) {

    }
}

// MARK: UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let mapView = mapView else {
            return false
        }
        
        if touch.view is MKAnnotationView {
            mapView.isZoomEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.mapView!.isZoomEnabled = true
            }
            return false
        }
        return true
    }
}

extension MapViewController: FilterVCDelegate {
    func updateRings() {
        
    }
    
    func showFilterButton() {

    }
}

extension MapViewController: ZipFinderVCDelegate {
    func showFilterButtonFromZF() {

    }
    
    func updateHomeButton() {

    }
}

extension MapViewController: NewAccountDelegate {
    func completeProfile() {
        let vc = CompleteProfileViewController()

        vc.user.userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        vc.user.username = AppDelegate.userDefaults.value(forKey: "username") as! String
        vc.user.firstName = AppDelegate.userDefaults.value(forKey: "firstName") as! String
        vc.user.lastName = AppDelegate.userDefaults.value(forKey: "lastName") as! String
        vc.user.birthday = AppDelegate.userDefaults.value(forKey: "birthday") as! Date


        guard let urlString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String,
              let url = URL(string: urlString) else {
            return
        }
        
        let getDataTask = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                vc.user.pictures.append(UIImage(data: data) ?? UIImage())
                vc.collectionView?.reloadData()
            }
            
        })
        getDataTask.resume()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}


extension MKAnnotationView {
    private var touchPath: UIBezierPath { return UIBezierPath(ovalIn: bounds) }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return touchPath.contains(point)
    }
}





extension MapViewController {
    func createNewUsersInDB(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let seungBirthday = formatter.date(from: "2002/01/01")!
        let ezraBirthday = formatter.date(from: "2001/10/23")!
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        let gabeBirthday = formatter.date(from: "2002/06/06")!
        let nicBirthday = formatter.date(from: "2002/03/14")!
        
        let yianni = User(
            userId: "u6501111111",
            username: "yianni_zav",
            firstName: "Yianni",
            lastName: "Zavaliagkos",
            birthday: yianniBirthday,
            bio: "This is Yianni's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let nicholas = User(
            userId: "u65022222222",
            username: "nicholas.almerge",
            firstName: "Nicholas",
            lastName: "Almerge",
            birthday: nicBirthday,
            bio: "This is Nic's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let gabe = User(
            userId: "u6503333333",
            username: "gabe.denton",
            firstName: "Gabe",
            lastName: "Denton",
            birthday: gabeBirthday,
            bio: "This is Gabe's Test Bio",
            school: "Vanderbilt University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let seung = User(
            userId: "u6504444444",
            username: "seung.choi13",
            firstName: "Seung",
            lastName: "Choi",
            birthday: seungBirthday,
            bio: "This is Seung's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let ezra = User(
            userId: "u6505555555",
            username: "ezrataylor55",
            firstName: "Ezra",
            lastName: "Taylor",
            birthday: ezraBirthday,
            bio: "This is Ezra's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        DatabaseManager.shared.insertUser(with: yianni, completion: { success in
            if success {
                print("successfully uploaded Yianni")
            } else {
                print("failed to upload Yianni")
            }
            
            DatabaseManager.shared.insertUser(with: nicholas, completion: { success in
                if success {
                    print("successfully uploaded Nic")
                } else {
                    print("failed to upload Nic")
                }
                
                DatabaseManager.shared.insertUser(with: gabe, completion: { success in
                    if success {
                        print("successfully uploaded Gabe")
                    } else {
                        print("failed to upload Gabe")
                    }
                    
                    DatabaseManager.shared.insertUser(with: seung, completion: { success in
                        if success {
                            print("successfully uploaded Seung")
                        } else {
                            print("failed to upload Seung")
                        }
                        
                        DatabaseManager.shared.insertUser(with: ezra, completion: { success in
                            if success {
                                print("successfully uploaded Ezra")
                            }  else {
                                print("failed to upload Ezra")
                            }
                        })
                    })
                })
            })
        })
    }
    
    func updateUsersInDB() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let seungBirthday = formatter.date(from: "2002/01/01")!
        let ezraBirthday = formatter.date(from: "2001/10/23")!
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        let gabeBirthday = formatter.date(from: "2002/06/06")!
        let nicBirthday = formatter.date(from: "2002/03/14")!
        
        let yianni = User(
            userId: "u6501111111",
            username: "yianni_zav",
            firstName: "Yianni",
            lastName: "Zavaliagkos",
            birthday: yianniBirthday,
            bio: "This is Yianni's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let nicholas = User(
            userId: "u65022222222",
            username: "nicholas.almerge",
            firstName: "Nicholas",
            lastName: "Almerge",
            birthday: nicBirthday,
            bio: "This is Nic's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let gabe = User(
            userId: "u6503333333",
            username: "gabe.denton",
            firstName: "Gabe",
            lastName: "Denton",
            birthday: gabeBirthday,
            bio: "This is Gabe's Test Bio",
            school: "Vanderbilt University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let seung = User(
            userId: "u6504444444",
            username: "seung.choi13",
            firstName: "Seung",
            lastName: "Choi",
            birthday: seungBirthday,
            bio: "This is Seung's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        let ezra = User(
            userId: "u6505555555",
            username: "ezrataylor55",
            firstName: "Ezra",
            lastName: "Taylor",
            birthday: ezraBirthday,
            bio: "This is Ezra's Test Bio",
            school: "McGill University",
            interests: [Interests(rawValue: 0)!, Interests(rawValue: 1)!, Interests(rawValue: 2)!],
            notificationPreferences: [
                "pause_all" : false,
                "news_update" : true,
                "zip_requests" : true,
                "accepted_zip_requests" : true,
                "messages" : true,
                "message_requests" : true,
                "event_invites" : true,
                "public_events" : true,
                "one_day_reminders" : true,
                "changes_to_event_info" : true
            ]
        )
        
        DatabaseManager.shared.updateUser(with: yianni, completion: { success in
            if success {
                print("successfully updated Yianni")
            } else {
                print("failed to updated Yianni")
            }
            
            DatabaseManager.shared.updateUser(with: nicholas, completion: { success in
                if success {
                    print("successfully updated Nic")
                } else {
                    print("failed to updated Nic")
                }
                DatabaseManager.shared.updateUser(with: gabe, completion: { success in
                    if success {
                        print("successfully updated Gabe")
                    } else {
                        print("failed to updated Gabe")
                    }
                    
                    DatabaseManager.shared.updateUser(with: ezra, completion: { success in
                        if success {
                            print("successfully updated Ezra")
                        } else {
                            print("failed to updated Ezra")
                        }
                        
                        DatabaseManager.shared.updateUser(with: seung, completion: { success in
                            if success {
                                print("successfully updated Seung")
                            } else {
                                print("failed to updated Seung")
                            }
                        })
                    })
                })
            })
        })
    }
    
    
    
    func generateTestData(){
        var seungpics = [UIImage]()
        var ezrapics = [UIImage]()
        var yiannipics = [UIImage]()
        var eliaspics = [UIImage]()
        var gabepics = [UIImage]()
        
        seungpics.append(UIImage(named: "seung1")!)
        seungpics.append(UIImage(named: "seung2")!)
        seungpics.append(UIImage(named: "seung3")!)
        
        ezrapics.append(UIImage(named: "ezra1")!)
        ezrapics.append(UIImage(named: "ezra2")!)
        ezrapics.append(UIImage(named: "ezra3")!)

        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        eliaspics.append(UIImage(named: "elias1")!)
        eliaspics.append(UIImage(named: "elias2")!)
        eliaspics.append(UIImage(named: "elias3")!)
        
        gabepics.append(UIImage(named: "gabe1")!)
        gabepics.append(UIImage(named: "gabe2")!)
        gabepics.append(UIImage(named: "gabe3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let seungBirthday = formatter.date(from: "2002/01/01")!
        let ezraBirthday = formatter.date(from: "2001/10/23")!
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        let gabeBirthday = formatter.date(from: "2002/06/06")!
        let eliasBirthday = formatter.date(from: "2002/03/14")!

        var seung = User(email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         firstName: "Seung",
                         lastName: "Choi",
//                         name: "Seung Choi",
                         zipped: true,
                         birthday: seungBirthday,
                         location:  CLLocation(latitude: 51.5014, longitude: -0.1419),
                         pictures: seungpics,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing",
                         school: "McGill University")
        
        var ezra = User(email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         firstName: "Ezra",
                         lastName: "Taylor",
//                         name: "Ezra Taylor",
                         zipped: false,
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570),
                         pictures: ezrapics,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance",
                         school: "McGill University")
        
        var yianni = User(email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         firstName: "Yianni",
                         lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                         zipped: true,
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                         pictures: yiannipics,
                         bio: "Yianni. I run this shit. Know the name",
                         school: "McGill Univeristy")

        var elias = User(email: "elias.levy@vanderbilt.edu",
                         username: "elias.levy",
                         firstName: "Elias",
                         lastName: "Levy",
//                         name: "Elias Levy",
                         zipped: true,
                         birthday: eliasBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.5070),
                         pictures: eliaspics,
                         bio: "Hey guys, I'm elias, robotics enthusiast and musician. One of the newest Zipper members. I developed the back end of the app basically making things work behind the scenes",
                         school: "Vanderbilt University")
        
        var gabe = User(email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        firstName: "Gabe",
                        lastName: "Denton",
//                        name: "Gabe Denton",
                        zipped: false,
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870),
                        pictures: gabepics,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order",
                        school: "Vanderbilt University")
        
        user = yianni
        
//        //Montreal
//        seung.location = CLLocation(latitude: 45.5017, longitude: -73.5673)
//        ezra.location = CLLocation(latitude: 45.4917, longitude: -73.4973)
//        yianni.location = CLLocation(latitude: 45.5517, longitude: -73.5873)
//        elias.location = CLLocation(latitude: 45.6717, longitude: -73.6073)
//        gabe.location = CLLocation(latitude: 45.5017, longitude: -73.6073)
        
//        let event1 = EventAnnotation(event: launchEvent, coordinate:  CLLocationCoordinate2D(latitude: 51.5014, longitude: -0.1419))
//        let event2 = EventAnnotation(event: randomEvent, coordinate: CLLocationCoordinate2D(latitude: 51.5313, longitude: -0.1570))
        

        launchEvent = Event(title: "Zipper Launch Party",
                            coordinates: CLLocationCoordinate2D(latitude: 51.5014, longitude: -0.1419),
                            hosts: [user],
                            description: "Come experience the release and launch of Zipper! Open Bar! Zipper profiles and ID's will be checked at the door. Must be 18 years or older",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [seung,yianni,gabe],
                            usersInterested: [elias,ezra],
                            type: "promoter",
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(2000),
                            image: UIImage(named: "launchevent")!)
        
        randomEvent = Event(title: "Fake Ass Frosh",
                            coordinates: CLLocationCoordinate2D(latitude: 51.5313, longitude: -0.1570),
                            hosts: [user,gabe,seung,ezra],
                            description: "The FitnessGram™ Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. Ding  A single lap should be completed each time you hear this sound. Ding  Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, ding",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [ezra,yianni,gabe],
                            usersInterested: [elias,seung],
                            type: "innerCircle",
                            startTime: Date(timeIntervalSinceNow: 100000),
                            duration: TimeInterval(200),
                            image: UIImage(named: "muzique")!)
    }
    
    
    static func getTestUsers() -> [User] {
        var seungpics = [UIImage]()
        var ezrapics = [UIImage]()
        var yiannipics = [UIImage]()
        var eliaspics = [UIImage]()
        var gabepics = [UIImage]()
        
        seungpics.append(UIImage(named: "seung1")!)
        seungpics.append(UIImage(named: "seung2")!)
        seungpics.append(UIImage(named: "seung3")!)
        
        ezrapics.append(UIImage(named: "ezra1")!)
        ezrapics.append(UIImage(named: "ezra2")!)
        ezrapics.append(UIImage(named: "ezra3")!)

        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        eliaspics.append(UIImage(named: "elias1")!)
        eliaspics.append(UIImage(named: "elias2")!)
        eliaspics.append(UIImage(named: "elias3")!)
        
        gabepics.append(UIImage(named: "gabe1")!)
        gabepics.append(UIImage(named: "gabe2")!)
        gabepics.append(UIImage(named: "gabe3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let seungBirthday = formatter.date(from: "2002/01/01")!
        let ezraBirthday = formatter.date(from: "2001/10/23")!
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        let gabeBirthday = formatter.date(from: "2002/06/06")!
        let eliasBirthday = formatter.date(from: "2002/03/14")!

        var seunginterests = [Interests]()
        var ezrainterests = [Interests]()
        var yianniinterests = [Interests]()
        var gabeinterests = [Interests]()
        var eliasinterests = [Interests]()
        
        seunginterests.append(.music)
        seunginterests.append(.makingMusic)
        seunginterests.append(.fashion)
        seunginterests.append(.sports)
        seunginterests.append(.graphicDesign)
        
        
        ezrainterests.append(.music)
        ezrainterests.append(.makingMusic)
        ezrainterests.append(.grabADrink)
        ezrainterests.append(.sports)
        ezrainterests.append(.football)
        
        yianniinterests.append(.skiing)
        yianniinterests.append(.coding)
        yianniinterests.append(.chess)
        yianniinterests.append(.wine)
        yianniinterests.append(.workingOut)
        
        gabeinterests.append(.skiing)
        gabeinterests.append(.coding)
        gabeinterests.append(.grabADrink)
        gabeinterests.append(.greekLife)
        gabeinterests.append(.workingOut)
        
        eliasinterests.append(.learning)
        eliasinterests.append(.coding)
        eliasinterests.append(.grabADrink)
        eliasinterests.append(.greekLife)
        eliasinterests.append(.music)
        
        seunginterests.sort(by: {$0.rawValue < $1.rawValue})
        ezrainterests.sort(by: {$0.rawValue < $1.rawValue})
        yianniinterests.sort(by: {$0.rawValue < $1.rawValue})
        gabeinterests.sort(by: {$0.rawValue < $1.rawValue})
        eliasinterests.sort(by: {$0.rawValue < $1.rawValue})

        var seung = User(userId: "u65044444444",
                         email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         firstName: "Seung",
                         lastName: "Choi",
//                         name: "Seung Choi",
                         zipped: true,
                         birthday: seungBirthday,
                         location: CLLocation(latitude: 51.5014, longitude: -0.1419), //CLLocation(latitude: 45.5017, longitude: -73.5673),
                         pictures: seungpics,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing",
                         school: "McGill University",
                         interests: seunginterests)
        
        var ezra = User(userId: "u6505555555",
                        email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         firstName: "Ezra",
                         lastName: "Taylor",
//                         name: "Ezra Taylor",
                         zipped: false,
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570), //CLLocation(latitude: 45.4917, longitude: -73.4973),
                         pictures: ezrapics,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance",
                         school: "McGill University",
                         interests: ezrainterests)
        
        var yianni = User(userId: "u6501111111",
                          email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         firstName: "Yianni",
                         lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                         zipped: true,
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070), //CLLocation(latitude: 45.5517, longitude: -73.5873),
                         pictures: yiannipics,
                         bio: "Yianni. I run this shit. Know the name",
                         school: "McGill Univeristy",
                         interests: yianniinterests)

        var elias = User(userId: "u6502222222",
                         email: "elias.levy@vanderbilt.edu",
                         username: "elias.levy",
                         firstName: "Elias",
                         lastName: "Levy",
//                         name: "Elias Levy",
                         zipped: true,
                         birthday: eliasBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.5070), //CLLocation(latitude: 45.671, longitude: -73.6073),
                         pictures: eliaspics,
                         bio: "Hey guys, I'm elias, robotics enthusiast and musician. One of the newest Zipper members. I developed the back end of the app basically making things work behind the scenes",
                         school: "Vanderbilt University",
                         interests: eliasinterests)
        
        var gabe = User(userId: "u6503333333",
                        email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        firstName: "Gabe",
                        lastName: "Denton",
//                        name: "Gabe Denton",
                        zipped: false,
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870), //CLLocation(latitude: 45.5017, longitude: -73.6073),
                        pictures: gabepics,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order",
                        school: "Vanderbilt University",
                        interests: gabeinterests)
        
        //Montreal
//        seung.location = CLLocation(latitude: 45.5017, longitude: -73.5673)
//        ezra.location = CLLocation(latitude: 45.4917, longitude: -73.4973)
//        yianni.location = CLLocation(latitude: 45.5517, longitude: -73.5873)
//        elias.location = CLLocation(latitude: 45.6717, longitude: -73.6073)
//        gabe.location = CLLocation(latitude: 45.5017, longitude: -73.6073)
        
        let list: [User] = [seung,ezra,yianni,elias,gabe]
        return list
    }
}

//Solves the corner problem
//extension UIButton {
//    private var touchPath: UIBezierPath { return UIBezierPath(ovalIn: bounds) }
//
//    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return touchPath.contains(point)
//    }
//}
