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
import FirebaseFirestore

extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
    
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
    
    private var mappedEvents: [String:EventAnnotation]
    private var mappedHappenings: [String: EventAnnotation]
    
    
    private let mapView: MKMapView
    let profileButton: UIButton
    private let zoomToCurrentButton : UIButton

    private let DEFAULT_ZOOM_DISTANCE = CGFloat(2000)
    private let DOT_ZOOM_DISTANCE: Double = 12
    
    var guardingGeoFireCalls: Bool
    var firstLocationUpdate = false

    var mapDidMove: Bool
    
    var promoterEventListener : ListenerRegistration?
    var invitedEventListener : ListenerRegistration?

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
        self.mappedEvents = [:]
        self.mappedHappenings = [:]
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
//        let path1 = "/Users/yiannizavaliagkos/Downloads/happenings.csv"
//        DatabaseManager.shared.getCSVData(path: path1)

//        let path2 = "/Users/yiannizavaliagkos/Downloads/happenings2.csv"
//        DatabaseManager.shared.getCSVData(path: path2)
        
//        DatabaseManager.shared.writeSpecialUsers()


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
        if let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] {
            let userLoc = CLLocationCoordinate2D(latitude: loc[0], longitude: loc[1])
            let zoomRegion = MKCoordinateRegion(center: userLoc, latitudinalMeters: DEFAULT_ZOOM_DISTANCE,longitudinalMeters: DEFAULT_ZOOM_DISTANCE)
            mapView.setRegion(zoomRegion, animated: true)
        }
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
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        
        if AppDelegate.userDefaults.value(forKey: "userLoc") == nil && locationManager.authorizationStatus == .denied {
            initZFUsers()
        }
        
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

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
        if let promoterEventListener = promoterEventListener {
            promoterEventListener.remove()
        }
       
        if let invitedEventListener = invitedEventListener {
            invitedEventListener.remove()
        }
        
    }
    
    
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureObservers()

//        isNewAccount = true
        if isNewAccount {
            isNewAccount = false
            let vc = NewAccountPopupViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureProfilePicture(){
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)

        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = 25
        profileButton.layer.borderColor = UIColor.white.cgColor //UIColor.zipVeryLightGray.cgColor
        profileButton.layer.borderWidth = 1
    }
    
    private func configureFloatingPanel() {
        fpc.delegate = self
        let fpcContent = FPCViewController()
        
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
        mapView.register(UserEventAnnotationView.self, forAnnotationViewWithReuseIdentifier: UserEventAnnotationView.identifier)
        mapView.register(RecurringEventAnnotationView.self, forAnnotationViewWithReuseIdentifier: RecurringEventAnnotationView.identifier)
        mapView.register(EventClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: EventClusterAnnotationView.identifier)
        mapView.register(HappeningsClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: HappeningsClusterAnnotationView.identifier)
        
        guard let selfId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
        
        
        
        
        DatabaseManager.shared.getAllGoingEvents(userId: selfId, eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.addEvent(event: event)
            }
        }, allCompletion: { result in
            
        })

        DatabaseManager.shared.getAllHappeningsToday(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            if strongSelf.mappedEvents[event.eventId] == nil {
                let annotation = EventAnnotation(event: event)
                DispatchQueue.main.async {
                    if strongSelf.mappedHappenings[event.eventId] == nil {
                        strongSelf.mapView.addAnnotation(annotation)
                        strongSelf.mappedHappenings[event.eventId] = annotation
                    }
                }
            }
        }, allCompletion: { result in
            
            
        })

        
    }
    
    private func configureObservers() {
        invitedEventListener = DatabaseManager.shared.getInivtedEventsListener(addedEventHandler: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.addEvent(event: event)
            }
            
            guard let fpcVC = strongSelf.fpc.contentViewController as? FPCViewController,
                  let id = AppDelegate.userDefaults.value(forKey: "userId") as? String,
                  event.getType() != .Promoter,
                  !event.usersGoing.contains(where:{ $0.userId == id } ),
                  !event.usersNotGoing.contains(where:{ $0.userId == id } )
            else { return }
            User.appendUDEvent(event: event, toKey: .invitedEvents)
            fpcVC.addEvent(event: event)
        }, modifiedEventHandler: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.modifyEvent(event: event)
            }
        }, removedEventHandler: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.removeEvent(event: event)
            }
            
            guard let fpcVC = strongSelf.fpc.contentViewController as? FPCViewController
            else {
                return
            }
            fpcVC.removeEvent(event: event)
        })
        
        
        promoterEventListener = DatabaseManager.shared.getPromoterEventListener(addedEventHandler: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.addEvent(event: event)
            }
        }, modifiedEventHandler: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.modifyEvent(event: event)
            }
        }, removedEventHandler: { [weak self] event in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.removeEvent(event: event)
            }
        })
    }
    
    func removeEvent(event: Event) {
        guard let annotation = mappedEvents[event.eventId],
              !event.canIGo()
        else {
            return
        }
        
        mapView.removeAnnotation(annotation)
        mappedEvents[event.eventId] = nil
    }
    
    func modifyEvent(event: Event) {
        guard let fpcVC = fpc.contentViewController as? FPCViewController,
              let id = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }

        let invited = event.usersInvite.contains(where: { $0.userId == id })
        let going = event.usersGoing.contains(where: { $0.userId == id })
        let hosting = event.hosts.contains(where: { $0.userId == id })
        
        if !invited {
            fpcVC.removeEvent(event: event)
        }
        
        if invited || going || hosting || event.getType() == .Promoter {
            updateEvent(event: event)
        } else {
            removeEvent(event: event)
        }
    }
    
    func updateEvent(event: Event) {
        guard let oldInstance = mappedEvents[event.eventId]?.event else { return }
        if oldInstance.picNum != event.picNum {
            event.updateImageInView{_ in}
        }
    }
    
    func addEvent(event: Event) {
        if mappedEvents[event.eventId] == nil {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.mappedEvents[event.eventId] == nil {
                    let annotation = EventAnnotation(event: event)
                    strongSelf.mapView.addAnnotation(annotation)
                    strongSelf.mappedEvents[event.eventId] = annotation
                    event.updateImageInView(completion: {_ in})
                }
            }
        }
    }
}

//MARK: -  Location Services
extension MapViewController: CLLocationManagerDelegate {
    private func initZFUsers() {
        if !guardingGeoFireCalls {
            var maxRange : Double
            if let maxRangeFilter = AppDelegate.userDefaults.value(forKey: "MaxRangeFilter") as? Double {
                maxRange = (maxRangeFilter > 5.0 ? 5.0 : maxRangeFilter)
            } else {
                maxRange = 2.0
            }
            
            let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] ?? [36.144051, -86.800949]
            GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]),
                                           range: maxRange,
                                           max: 3,
                                           completion: {
                
                GeoManager.shared.LoadUsers(size: 10, completion: {_ in }, updateCompletion: {  [weak self] res in
                    //MARK: GABE find out how to make the user configure the image - all you need to do is find the user
                    guard let strongSelf = self else {
                        return
                    }
                    if let user = GeoManager.shared.loadedUsers[res] {
                        guard let cell = user.ZFCell else {
                            return
                        }
                        cell.configureImage(user: user)
                    }
                    
                })

            })
            guardingGeoFireCalls = true
            zoomToLatestLocation()
            mapDidMove = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        AppDelegate.userDefaults.set([latestLocation.coordinate.latitude, latestLocation.coordinate.longitude], forKey: "userLoc")
//        DatabaseManager.shared.testEmail()
        if !firstLocationUpdate {
            firstLocationUpdate = true
            GeoManager.shared.UpdateLocation(location: latestLocation)
        }
        initZFUsers()
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

        if let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] {
            zipFinder.userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        }
        
        let vc = UINavigationController(rootViewController: zipFinder)
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: { [weak self] in
            self?.fpc.move(to: .tip, animated: true, completion: nil)
        })
    }
    
    func createEvent() {
        if let userType = AppDelegate.userDefaults.value(forKey: "userType") as? Int {
            if userType == 0 || userType == 1 || userType == 2 {
                promoterCreateEvent()
            } else {
                normalCreateEvent()
            }
        } else {
            normalCreateEvent()
        }
    }
    
    private func promoterCreateEvent() {
        let alert = UIAlertController(title: "Select Event Type",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Normal",
                                      style: .default,
                                      handler: { [weak self] _ in
            DispatchQueue.main.async {
                let event = UserEvent()
                event.mapView = self?.mapView
                let vc = CreateEventViewController(event: event)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Promoter",
                                      style: .default,
                                      handler: { [weak self] _ in
            DispatchQueue.main.async {
                let event = PromoterEvent()
                event.mapView = self?.mapView
                let vc = CreateEventViewController(event: event)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { _ in

            
        }))
        
        present(alert, animated: true)
    }
    
    private func normalCreateEvent() {
        let event = UserEvent()
        event.mapView = mapView
        let vc = CreateEventViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openFPC() {
        if fpc.state != .full {
            fpc.move(to: .full, animated: true, completion: { [weak self] in
//                if let fpcVC = self?.fpc.contentViewController as? FPCViewController {
//                    fpcVC.searchBar.becomeFirstResponder()
//                }
            })
        }
    }
}



// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is EventClusterAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EventClusterAnnotationView.identifier) as? EventClusterAnnotationView
            if annotationView == nil {
                annotationView = EventClusterAnnotationView(annotation: annotation, reuseIdentifier: EventClusterAnnotationView.identifier)
            }
            return annotationView
        }

        if annotation is HappeningsClusterAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: HappeningsClusterAnnotationView.identifier) as? HappeningsClusterAnnotationView
            if annotationView == nil {
                annotationView = HappeningsClusterAnnotationView(annotation: annotation, reuseIdentifier: HappeningsClusterAnnotationView.identifier)
            }
            return annotationView
        }
        
        guard let eventAnnotation = annotation as? EventAnnotation else {
            return nil
        }
        switch eventAnnotation.event.getType() {
        case .Recurring:
            guard let event = eventAnnotation.event as? RecurringEvent,
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: RecurringEventAnnotationView.identifier) as? RecurringEventAnnotationView else {
                return MKAnnotationView()
            }
            annotationView.configure(event: event)
            annotationView.canShowCallout = false
            annotationView.delegate = self
            return annotationView
            
        case .Open, .Closed:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: UserEventAnnotationView.identifier) as? UserEventAnnotationView else {
                return MKAnnotationView()
            }
            annotationView.configure(event: eventAnnotation.event)
            
            annotationView.canShowCallout = false
            
            eventAnnotation.event.annotationView = annotationView
            annotationView.delegate = self
            eventAnnotation.viewFor = annotationView
            return annotationView

        case .Promoter:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PromoterEventAnnotationView.identifier) as? PromoterEventAnnotationView else {
                return MKAnnotationView()
            }
            annotationView.configure(event: eventAnnotation.event)
            
            annotationView.canShowCallout = false
            eventAnnotation.event.annotationView = annotationView
            annotationView.delegate = self
            eventAnnotation.viewFor = annotationView
            return annotationView
            
        case .Event:
            let x = MKAnnotationView()
            x.canShowCallout = false
            return x
        }

    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        guard let eventAnnotations = memberAnnotations as? [EventAnnotation] else {
            return MKClusterAnnotation(memberAnnotations: memberAnnotations)
        }
        let type = eventAnnotations[0].event
        for event in eventAnnotations {
            if type is RecurringEvent {
                if !(event.event is RecurringEvent) { print("combining") }
            }
            
            if type is UserEvent || type is PromoterEvent {
                if !(event.event is UserEvent || event.event is PromoterEvent) { print("comining2") }
            }
        }
        
        if !(eventAnnotations[0].event is RecurringEvent) {
//            let eventAnnotations = eventAnnotations.filter({ !($0.event is RecurringEvent) })
            return EventClusterAnnotation(eventAnnotations: eventAnnotations)
        } else {
//            let recuringEventAnnotations = eventAnnotations.filter({ $0.event is RecurringEvent })
            return HappeningsClusterAnnotation(eventAnnotations: eventAnnotations)
        }
    }
    
    private func getCluterSpan(cluster: MKClusterAnnotation) -> ClusterSpan? {
        guard let eventAnnotations = cluster.memberAnnotations as? [EventAnnotation] else { return nil }
        let events = eventAnnotations.map({ $0.event })
        let currentSpan = mapView.region.span
        let currentRatio = currentSpan.latitudeDelta / currentSpan.longitudeDelta
        
        let annotations = cluster.memberAnnotations
        var minLat: CLLocationDegrees = annotations[0].coordinate.latitude
        var maxLat: CLLocationDegrees = annotations[0].coordinate.latitude
        var minLong: CLLocationDegrees = annotations[0].coordinate.longitude
        var maxLong: CLLocationDegrees = annotations[0].coordinate.longitude
        var centerLat = 0.0
        var centerLong = 0.0

        for event in events {
//            guard let event = event else { continue }
            let lat = event.coordinates.coordinate.latitude
            let long = event.coordinates.coordinate.longitude
            centerLat += lat
            centerLong += long
            
            maxLat = max(maxLat, lat)
            minLat = min(minLat, lat)
            maxLong = max(maxLong, long)
            minLong = min(minLong, long)
        }
        
        let latDifference = (maxLat - minLat) * 1.5
        let longDifference = (maxLong - minLong) * 1.5
        
        centerLat /= Double(annotations.count)
        centerLong /= Double(annotations.count)
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        return ClusterSpan(center: center, latitudeDelta: latDifference, longitudeDelta: longDifference)
    }
    
    private typealias ClusterSpan = (center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees)

    //did select is how you click annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.isZoomEnabled = true
        
        if let cluster = view.annotation as? MKClusterAnnotation {
            guard let clusterSpan = getCluterSpan(cluster: cluster) else {
                return
            }
            
            if clusterSpan.latitudeDelta < 0.0001 && clusterSpan.longitudeDelta < 0.0001 {
                guard let eventAnnotations = cluster.memberAnnotations as? [EventAnnotation] else { return }
                let events = eventAnnotations.map({ $0.event }).sorted(by: { $0.startTime > $1.startTime})
                let vc = MasterTableViewController(cellData: events, cellType: CellType(eventType: .save))
                vc.title = "Multiple Events"
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let region = MKCoordinateRegion(center: clusterSpan.center,
                                                span: MKCoordinateSpan(latitudeDelta: clusterSpan.latitudeDelta, longitudeDelta: clusterSpan.longitudeDelta))
                mapView.setRegion(region, animated: true)
            }
            
            return
        }
        
        if let annotationView = view as? EventAnnotationView,
           let annotation = view.annotation as? EventAnnotation {
            
            if let recurringEvent = annotation.event as? RecurringEvent {
                print(recurringEvent.eventId)
                return
            }
            if annotationView.isDot {
                let zoomRegion = MKCoordinateRegion(center: view.annotation!.coordinate,
                                                    latitudinalMeters: DEFAULT_ZOOM_DISTANCE-10,
                                                    longitudinalMeters: DEFAULT_ZOOM_DISTANCE-10)
                for (_,annotation) in mappedEvents {
                    if let annotationView = annotation.viewFor {
                        annotationView.makeEvent()
                    }
                }
                mapView.setRegion(zoomRegion, animated: true)
            }  else {
//                var eventVC: UIViewController
//                let userId = (AppDelegate.userDefaults.value(forKey: "userId") as? String) ?? ""
//                if annotation.event.hosts.map({ $0.userId }).contains(userId) {
//                    eventVC = MyEventViewController(event: annotation.event)
//                } else {
//                    eventVC = EventViewController(event: annotation.event)
//                }
//
//                navigationController?.pushViewController(eventVC, animated: true)
//
//                mapView.deselectAnnotation(view.annotation, animated: false)
                
            }
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
extension MapViewController : EventAnnotationDelegate {
    func selectEvent(for annotationView: EventAnnotationViewProtocol) {
        navigationController?.pushViewController(annotationView.getEvent().viewController, animated: true)
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
//            updateAnnotation()
        }
    }
    
    private func updateAnnotation(){
//        configureEventsOnDistance()
    }

    private func configureEventsOnDistance() {
        for annotation in mapView.annotations {
            if annotation is MKUserLocation {
                continue
            }
            if let annotationView = self.mapView.view(for: annotation) as? EventAnnotationView  {
                if mapView.zoomLevel <= DOT_ZOOM_DISTANCE && !annotationView.isDot{
                    annotationView.makeDot()
                } else if mapView.zoomLevel > DOT_ZOOM_DISTANCE && annotationView.isDot {
                    annotationView.makeEvent()
                }
            }
//            else if let annotationView = self.mapView.view(for: annotation) as? RecurringEventAnnotationView  {
//                if mapView.zoomLevel <= DOT_ZOOM_DISTANCE && annotationView.isVisible {
//                    annotationView.hide()
//                } else if mapView.zoomLevel > DOT_ZOOM_DISTANCE && !annotationView.isVisible {
//                    annotationView.show()
//                }
//            }
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
        
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        if fpc.state != .full {
            fpc.view.endEditing(true)
        }
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
        user.gender = AppDelegate.userDefaults.value(forKey: "gender") as! String
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
}
