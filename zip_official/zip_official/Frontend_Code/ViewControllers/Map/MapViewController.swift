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

extension MKMapView {
    var zoomLevel: Double {
        return log2(360 * ((Double(self.frame.size.width) / 256) / self.region.span.longitudeDelta)) - 1
    }
}

protocol InitMapDelegate: AnyObject {
    
}


//MARK: View Controller
class MapViewController: UIViewController {
    private var isNewAccount: Bool
    private let locationManager: CLLocationManager
    
    private let fpc: FloatingPanelController
    
    private var events: [Event]
    
    private let mapView: MKMapView
    private let profileButton: UIButton
    private let zoomToCurrentButton : UIButton

    private let DEFAULT_ZOOM_DISTANCE = CGFloat(2000)
    private let DOT_ZOOM_DISTANCE: Double = 12

    
    var guardingGeoFireCalls: Bool
    
    var mapDidMove: Bool
    
//    typealias LoadCircle = (center: CLLocation, radius: Double)
//    var eventId_circles = [LoadCircle]()
//    var loadedEvent_circles = [LoadCircle]()
//    var userCenter: CLLocation
//    var currentCenter: CLLocation
//    var currentRadius: Double
//
//    var getCurrentCircle: LoadCircle = {
//        return LoadCircle()
//    }()


    
    init(isNewAccount: Bool){
        self.isNewAccount = isNewAccount
        self.events = []
        self.locationManager = CLLocationManager()
        self.mapView = MKMapView()
        self.fpc = FloatingPanelController()
        self.zoomToCurrentButton = UIButton()
        self.profileButton = UIButton()
        
        self.mapDidMove = true
        self.guardingGeoFireCalls = false
 
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .zipGray
        definesPresentationContext = true
        
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = true
        
        zoomToCurrentButton.backgroundColor = .zipVeryLightGray.withAlphaComponent(0.7)
        zoomToCurrentButton.layer.borderColor = UIColor.zipVeryLightGray.cgColor
        zoomToCurrentButton.layer.borderWidth = 1
        zoomToCurrentButton.setImage(UIImage(systemName: "location")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        zoomToCurrentButton.imageView?.contentMode = .scaleToFill
        zoomToCurrentButton.contentMode = .scaleToFill
        zoomToCurrentButton.layer.cornerRadius = 8
        zoomToCurrentButton.layer.masksToBounds = true
        
        
        zoomToCurrentButton.addTarget(self, action: #selector(didTapZoom), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        
        addSubviews()
        configureSubviewLayout()
        configureLocationServices()
        configureProfilePicture()
        configureFloatingPanel()
        configureNavBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapProfileButton() {
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String
        else { return }
        let vc = ProfileViewController(id: userId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapZoom(){
        zoomToLatestLocation()
        hideZoomButton()
        mapDidMove = false
    }
    
    private func zoomToLatestLocation(){
        //change 20000,20000 so that it fits all 3 rings
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocationCoordinate2D(latitude: loc[0], longitude: loc[1])
        let zoomRegion = MKCoordinateRegion(center: userLoc, latitudinalMeters: DEFAULT_ZOOM_DISTANCE,longitudinalMeters: DEFAULT_ZOOM_DISTANCE)
        mapView.setRegion(zoomRegion, animated: true)
        updateAnnotation()
    }

    private func hideZoomButton() {
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.zoomToCurrentButton.alpha = 0
        }, completion: { finished in
            self.zoomToCurrentButton.isHidden = true
        })
        
    }

    private func showZoomButton() {
        self.zoomToCurrentButton.isHidden = false
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.zoomToCurrentButton.alpha = 1
        }, completion: { finished in
            
        })
    }

    // MARK: ViewDidLoad
    // essentially the main
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            overrideUserInterfaceStyle = .dark
        }

        configureAnnotations()
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchGR.delegate = self
        self.mapView.addGestureRecognizer(pinchGR)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let urlString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String {
           let url = URL(string: urlString)
           profileButton.sd_setImage(with: url, for: .normal, completed: nil)
       } else {
           profileButton.setImage(UIImage(named: "defaultProfilePic"), for: .normal)
       }
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isNewAccount {
            isNewAccount = false
            let vc = NewAccountPopupViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    
    }

    private func configureProfilePicture(){
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)

        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = 25
        profileButton.layer.borderColor = UIColor.zipVeryLightGray.cgColor //UIColor.zipVeryLightGray.cgColor
        profileButton.layer.borderWidth = 1
    }
    
    private func configureFloatingPanel() {
        fpc.delegate = self
        let events = MapViewController.generateEvents()
        
        let fpcContent = FPCViewController(events: events)
        
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
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        navigationController?.navigationBar.isHidden = true
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
   
    
    
    //MARK: - Configure Subviews
    private func addSubviews(){
        view.addSubview(mapView)
        view.addSubview(profileButton)
        mapView.addSubview(zoomToCurrentButton)
    }
    
    private func configureSubviewLayout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -45).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        profileButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor).isActive = true
        
        zoomToCurrentButton.translatesAutoresizingMaskIntoConstraints = false
        zoomToCurrentButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true
        zoomToCurrentButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -10).isActive = true
        zoomToCurrentButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        zoomToCurrentButton.heightAnchor.constraint(equalTo: zoomToCurrentButton.widthAnchor).isActive = true
    }

    //MARK: - Annotation Config
    // regisers annotation views and adds them to map
    func configureAnnotations(){
        mapView.delegate = self
        mapView.register(PromoterEventAnnotationView.self, forAnnotationViewWithReuseIdentifier: PromoterEventAnnotationView.identifier)
        mapView.register(PrivateEventAnnotationView.self, forAnnotationViewWithReuseIdentifier: PrivateEventAnnotationView.identifier)
        mapView.register(PublicEventAnnotationView.self, forAnnotationViewWithReuseIdentifier: PublicEventAnnotationView.identifier)

        
        DatabaseManager.shared.getAllPrivateEventsForMap(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.mapView.addAnnotation(EventAnnotation(event: event))
        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let events):
                guard let fpcVC = strongSelf.fpc.contentViewController as? FPCViewController else {
                    return
                }
                fpcVC.events = events
                fpcVC.updateEventsLabel(events: events)
                fpcVC.eventsTable.updateEvents(events: events)
            case .failure(let error):
                print("failure loading all events: \(error)")
            }
        })

        DatabaseManager.shared.getAllPublic(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.mapView.addAnnotation(EventAnnotation(event: event))
        }, allCompletion: { result in

        })
        
        DatabaseManager.shared.getAllPromoter(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            print("IN LOAD \(event.getType())")
            strongSelf.mapView.addAnnotation(EventAnnotation(event: event))
        }, allCompletion: { result in
            
        })
        
    }

}

//MARK: -  Location Services
extension MapViewController: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        AppDelegate.userDefaults.set([latestLocation.coordinate.latitude, latestLocation.coordinate.longitude], forKey: "userLoc")

        if !guardingGeoFireCalls {
            
            GeoManager.shared.UpdateLocation(location: latestLocation)
            let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
            GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: 2, max: 3, completion: {

                GeoManager.shared.LoadNextUsers(size: 10, completion: {
                })

            })
            guardingGeoFireCalls = true
            zoomToLatestLocation()
            mapDidMove = false
        }
//        DatabaseManager.shared.testUserTableView()
//        DatabaseManager.shared.testEventTableView()
//        DatabaseManager.shared.createSampleUsersMany()
//        DatabaseManager.shared.createSampleEventsMany()
//        DatabaseManager.shared.testthequery()
        //MARK: For test code to be added to database only necessary once but leaving for future use if needed
//        DatabaseManager.shared.makeSampleEvent()
//        DatabaseManager.shared.checkSampleEvent()
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
    func openVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openZipFinder() {
        let zipFinder = ZipFinderViewController()
        zipFinder.delegate = self
        
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        zipFinder.userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        
        let vc = UINavigationController(rootViewController: zipFinder)
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
    }
    
    func createEvent() {
        openVC(EventTypeSelectViewController(map: mapView))
    }
    
    func openFPC() {
        if fpc.state != .full {
            fpc.move(to: .full, animated: true, completion: nil)
        }
    }
}



// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let eventAnnotation = annotation as? EventAnnotation else {
            return nil
        }
        switch eventAnnotation.event.getType() {
        case .Private, .Friends:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PrivateEventAnnotationView.identifier) as? PrivateEventAnnotationView else {
                return MKAnnotationView()
            }
            annotationView.configure(event: eventAnnotation.event)
            
            annotationView.canShowCallout = false
            
            eventAnnotation.event.annotationView = annotationView
            return annotationView
            
        case .Public:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PublicEventAnnotationView.identifier) as? PublicEventAnnotationView else {
                return MKAnnotationView()
            }
            annotationView.configure(event: eventAnnotation.event)
            annotationView.canShowCallout = false
            eventAnnotation.event.annotationView = annotationView
            return annotationView
            
        case .Promoter:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PromoterEventAnnotationView.identifier) as? PromoterEventAnnotationView else {
                return MKAnnotationView()
            }
            annotationView.configure(event: eventAnnotation.event)
            
            annotationView.canShowCallout = false
            eventAnnotation.event.annotationView = annotationView
            return annotationView
            
        case .Event:
            return MKAnnotationView()
        }

    }
    
    //did select is how you click annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.isZoomEnabled = true
        if mapView.zoomLevel < DOT_ZOOM_DISTANCE { return }
        if let annotation = view.annotation as? EventAnnotation {
            var eventVC: UIViewController
            let userId = (AppDelegate.userDefaults.value(forKey: "userId") as? String) ?? ""
            if annotation.event.hosts.map({ $0.userId }).contains(userId) {
                eventVC = MyEventViewController(event: annotation.event)
            } else {
                eventVC = EventViewController(event: annotation.event)
            }
            
            navigationController?.pushViewController(eventVC, animated: true)
            
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateAnnotation()
        if mapDidMove {
            showZoomButton()
        } else {
            hideZoomButton()
            mapDidMove = true
        }
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
//            updateAnnotation()
        }
    }
    
    private func updateAnnotation(){
        for annotation in mapView.annotations {
            if annotation is MKUserLocation {
                continue
            }
            guard let annotationView = self.mapView.view(for: annotation) as? EventAnnotationView else { continue }
            if mapView.zoomLevel <= DOT_ZOOM_DISTANCE {
                annotationView.makeDot()
            } else {
                annotationView.makeEvent()
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is MKAnnotationView {
            mapView.isZoomEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.mapView.isZoomEnabled = true
            }
            return false
        }
        return true
    }
    
}


//MARK: Floating Panel Delegate
extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanelWillBeginDragging(_ fpc: FloatingPanelController) {

    }
    
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        self.fpc.view.endEditing(true)
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
        let user = User()
        user.userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        user.username = AppDelegate.userDefaults.value(forKey: "username") as! String
        user.firstName = AppDelegate.userDefaults.value(forKey: "firstName") as! String
        user.lastName = AppDelegate.userDefaults.value(forKey: "lastName") as! String
        user.birthday = AppDelegate.userDefaults.value(forKey: "birthday") as! Date
        user.pictureURLs = [URL(string: AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as! String)!]
        let vc = CompleteProfileViewController(user: user)

        navigationController?.pushViewController(vc, animated: true)
    }
}

// For Initialization
extension MapViewController {
    
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
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
                .news_update : true,
                .zip_request : false,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : false,
                .one_day_reminder : true,
                .change_to_event_info : true
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
                .news_update : false,
                .zip_request : false,
                .accepted_zip_request: false,
                .message : false,
                .message_request : false,
                .event_invite : false,
                .public_event : false,
                .one_day_reminder : false,
                .change_to_event_info : false
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : false,
                .one_day_reminder : false,
                .change_to_event_info : false
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
            ]
        )
        
        DatabaseManager.shared.insertUser(with: yianni, completion: {  err in
            guard err == nil else {
                
                print("failed to updated Seung")
                return
            }
            print("successfully updated Seung")
            
            DatabaseManager.shared.insertUser(with: nicholas, completion: {  err in
                guard err == nil else {
                    
                    print("failed to updated Seung")
                    return
                }
                print("successfully updated Seung")
                
                DatabaseManager.shared.insertUser(with: gabe, completion: {  err in
                    guard err == nil else {
                        
                        print("failed to updated Seung")
                        return
                    }
                    print("successfully updated Seung")
                    DatabaseManager.shared.insertUser(with: seung, completion: {  err in
                        guard err == nil else {
                            
                            print("failed to updated Seung")
                            return
                        }
                        print("successfully updated Seung")
                        
                        DatabaseManager.shared.insertUser(with: ezra, completion: {  err in
                            guard err == nil else {
                                
                                print("failed to updated Seung")
                                return
                            }
                            print("successfully updated Seung")
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
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
                .news_update : true,
                .zip_request : true,
                .accepted_zip_request: true,
                .message : true,
                .message_request : true,
                .event_invite : true,
                .public_event : true,
                .one_day_reminder : true,
                .change_to_event_info : true
            ]
        )
        
        DatabaseManager.shared.updateUser(with: yianni, completion: { err in
            guard err == nil else {
                print("failed to updated Yianni")
                return
            }
            print("successfully updated Yianni")
            
            DatabaseManager.shared.updateUser(with: nicholas, completion: { err in
                guard err == nil else {
                    print("failed to updated Nic")
                    return
                }
                print("successfully updated Nic")
                DatabaseManager.shared.updateUser(with: gabe, completion: { err in
                    guard err == nil else {
                        
                        print("failed to updated Gabe")
                        return
                    }
                    print("successfully updated Gabe")
                    DatabaseManager.shared.updateUser(with: ezra, completion: { err in
                        guard err == nil else {
                            
                            print("failed to updated Ezra")
                            return
                        }
                        print("successfully updated Ezra")
                        
                        DatabaseManager.shared.updateUser(with: seung, completion: { err in
                            guard err == nil else {
                                
                                print("failed to updated Seung")
                                return
                            }
                            print("successfully updated Seung")
                        })
                    })
                })
            })
        })
    }
    
    static func getTestUsers() -> [User] {
        var picUrls = [URL(string:
                            "https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6501111111%2Fprofile_picture.png?alt=media&token=3d0b4726-fd1e-41a2-a26d-24b7a932065e")!,
                       
                       URL(string: "https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6501111111%2Fprofile_picture.png?alt=media&token=3d0b4726-fd1e-41a2-a26d-24b7a932065e")!]
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

        let seung = User(userId: "u65044444444",
                         email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         firstName: "Seung",
                         lastName: "Choi",
                         birthday: seungBirthday,
                         location: CLLocation(latitude: 51.5014, longitude: -0.1419), //CLLocation(latitude: 45.5017, longitude: -73.5673),
                         pictures: seungpics,
                         pictureURLs: picUrls,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing",
                         school: "McGill University",
                         interests: seunginterests)
        
        let ezra = User(userId: "u2158018458",
                        email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         firstName: "Ezra",
                         lastName: "Taylor",
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570), //CLLocation(latitude: 45.4917, longitude: -73.4973),
                         pictures: ezrapics,
                         pictureURLs: picUrls,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance",
                         school: "McGill University",
                         interests: ezrainterests)
        
        ezra.friendshipStatus = nil
        
        let yianni = User(userId: "u9789070602",
                          email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         firstName: "Yianni",
                         lastName: "Zavaliagkos",
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070), //CLLocation(latitude: 45.5517, longitude: -73.5873),
                         pictures: yiannipics,
                          pictureURLs: picUrls,
                         bio: "Yianni. I run this shit. Know the name",
                         school: "McGill Univeristy",
                         interests: yianniinterests)

        yianni.friendshipStatus = .REQUESTED_OUTGOING
        
        let gabe = User(userId: "u6503333333",
                        email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        firstName: "Gabe",
                        lastName: "Denton",
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870), //CLLocation(latitude: 45.5017, longitude: -73.6073),
                        pictures: gabepics,
                        pictureURLs: picUrls,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order",
                        school: "Vanderbilt University",
                        interests: gabeinterests)
        

        let list: [User] = [seung,ezra,yianni,gabe]
        return list
    }
    
    static func generateRequests() -> [ZipRequest]{
        var requests: [ZipRequest] = []
        guard let picString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String,
              let picUrl = URL(string: picString) else {
                  return []
              }
        
        
        
        let ezra = User(userId: "u6502222222",
                        firstName: "Ezra",
                        lastName: "Taylor",
                        pictureURLs: [picUrl])
        
        let yianni = User(userId: "u6503333333",
                          firstName: "Ezra",
                          lastName: "Taylor",
                          pictureURLs: [picUrl])
        
        let seung = User(userId: "u6504444444",
                         firstName: "Seung",
                         lastName: "Choi",
                         pictureURLs: [picUrl])
        
        let gabe = User(userId: "u6505555555",
                        firstName: "Gabe",
                        lastName: "Denton",
                        pictureURLs: [picUrl])
        
        let request1 = ZipRequest(fromUser: ezra, time: TimeInterval(10))
        let request2 = ZipRequest(fromUser: yianni, time: TimeInterval(10))
        let request3 = ZipRequest(fromUser: seung, time: TimeInterval(10))
        let request4 = ZipRequest(fromUser: gabe, time: TimeInterval(10))
        
        print("Here321123")
        print(requests)
        
        requests.append(request1)
        print()
        print(requests)
        
        requests.append(request2)
        print()
        print(requests)
        
        requests.append(request3)
        print()
        print(requests)
        
        requests.append(request4)
        print()
        print(requests)
        
        
        return requests
    }
    
    static func generateEvents() -> [Event] {
        var events: [Event] = []
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
        
        let e1Url = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6503333333%2Fprofile_picture.png?alt=media&token=1b83e75e-6147-4da6-bd52-1eee539bbc61")!
        
   
        
        let launchEvent = PromoterEvent(
            eventId: "u6501111111_Cartoon-Museum_Jun 22, 2022 at 12:41:18 PM EDT",
            title: "Zipper Launch Party",
            hosts: [yianni],
            bio: "Come experience the release and launch of Zipper! Open Bar! Zipper profiles and ID's will be checked at the door. Must be 18 years or older",
            address: "3781 St. Lauremt Blvd.",
            maxGuests: 250,
            usersGoing: [yianni],
            usersInterested: [yianni],
            startTime: Date(timeIntervalSinceNow: 1000),
            endTime:  Date(timeIntervalSinceNow: 900000),
            image: UIImage(named: "launchevent")!
        )
        
        launchEvent.imageUrl = e1Url
        
        
        let fakeFroshEvent = PrivateEvent(
            eventId: "u6501111111_Cartoon-Museum_Jun 22, 2022 at 12:41:18 PM EDT",
            title: "Fake Ass Frosh",
            hosts: [yianni],
            bio: "The FitnessGram™ Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. Ding  A single lap should be completed each time you hear this sound. Ding  Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, ding",
            address: "3781 St. Lauremt Blvd.",
            maxGuests: 250,
            usersGoing: [yianni],
            usersInterested: [yianni],
            startTime: Date(timeIntervalSinceNow: 1000),
            endTime:  Date(timeIntervalSinceNow: 900000),
            image: UIImage(named: "muzique")!)
        
        fakeFroshEvent.imageUrl = e1Url

        
        let spikeBallEvent = PublicEvent(
            eventId: "u6501111111_Cartoon-Museum_Jun 22, 2022 at 12:41:18 PM EDT",
            title: "Zipper Spikeball Tournament",
                                   hosts: [yianni],
                                   bio: "Zipper Spikeball Tournament",
                                   address: "3781 St. Lauremt Blvd.",
                                   maxGuests: 250,
                                   usersGoing: [yianni],
                                   usersInterested: [yianni],
                                   startTime: Date(timeIntervalSinceNow: 100000),
                                   endTime:  Date(timeIntervalSinceNow: 900000),
                                   image: UIImage(named: "spikeball"))
        
        spikeBallEvent.imageUrl = e1Url

        events.append(launchEvent)
        events.append(fakeFroshEvent)
        events.append(spikeBallEvent)
        
        return events
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
