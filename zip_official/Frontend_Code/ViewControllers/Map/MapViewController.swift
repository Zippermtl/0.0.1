//
//  MapViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/15/21.
//

/*
 
 
Myzips page is fucked
scroll for entire profile/event - Make a UIView out of the header and make that
 
 
 
 iphone 8 backdrop to zip finder pictures is reusing other pictures
 */








import UIKit
import MapKit
import CoreLocation
import CoreGraphics

//MARK: View Controller
class MapViewController: UIViewController {
    static let title = "MapVC"
    //rootUser
//    @EnvironmentObject var rootUser: User
    
    
    
    // MARK: - Delegates
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Location Services
    private let locationManager = CLLocationManager()
    static var userLoc: CLLocationCoordinate2D!
    
    
    // MARK: - Rings
    var ring1 = MKCircle()
    var ring2 = MKCircle()
    var ring3 = MKCircle()

    // MARK: - Events
    //to be brought in via json file
    //func loadEventData()
    var user = User()
    var launchEvent = Event()
    var randomEvent = Event()
    
    
    // MARK: - Data
    private var events: [Event] = []
    
    // MARK: - Subviews
    let mapView = MKMapView()
    var filterButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "filterButton"), for: .normal)
        btn.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Button Actions
    @objc private func didTapHomeButton(){
        if(MapViewController.userLoc != nil ){
            zoomToLatestLocation(with: MapViewController.userLoc)
        }
    }
    
    @objc private func didTapFilterButton(){
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        filtersVC.modalPresentationStyle = .overCurrentContext
        present(filtersVC, animated: true, completion: nil)
    }
    
    @objc func didTapProfileButton() {
        let profileView = ProfileViewController()
        profileView.modalPresentationStyle = .overCurrentContext
        present(profileView, animated: false, completion: nil)
    }

    
    //MARK: - Ring Taps
    private func didTapRing1() {
        presentZipFinder(ring1)
        print("ring1 tapped")
    }
    
    private func didTapRing2() {
       presentZipFinder(ring2)
        print("ring2 tapped")

    }
    
    private func didTapRing3() {
        presentZipFinder(ring3)
        print("ring3 tapped")

    }

    private func presentZipFinder(_ ring: MKCircle){
        let zipFinderView = ZipFinderViewController()
        zipFinderView.modalPresentationStyle = .overCurrentContext
        zipFinderView.loadDataByRingTap(ring: ring)
        present(zipFinderView, animated: false, completion: nil)
    }
    
    // MARK: - Handle Tap
    

    //checks distance between click and user
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        if sender?.state != UIGestureRecognizer.State.began { return }
        let tapPoint = sender?.location(in: mapView)
        
        let tapCoordinate = mapView.convert(tapPoint!, toCoordinateFrom: mapView)
        let tapLocation = CLLocation(latitude: tapCoordinate.latitude, longitude: tapCoordinate.longitude)
        let userLocation = CLLocation(latitude: MapViewController.userLoc.latitude, longitude: MapViewController.userLoc.longitude)
        
        let tapDistance = userLocation.distance(from: tapLocation)
        
        if tapDistance < AppDelegate.userDefaults.double(forKey: "BlueRing") {
            didTapRing1()
        } else if tapDistance < AppDelegate.userDefaults.double(forKey: "GreenRing") {
            didTapRing2()
        } else if tapDistance < AppDelegate.userDefaults.double(forKey: "PinkRing") {
            didTapRing3()
        }
    }

    
    
    // MARK: ViewDidLoad
    // essentially the main
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            self.overrideUserInterfaceStyle = .dark
        }
        generateTestData()
        
        definesPresentationContext = true
        configureLocationServices()
        configureSubviews()
        configureAnnotations()
        configureGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let vc = self.presentingViewController else { return }
        while (vc.presentingViewController != nil ) {
            vc.dismiss(animated: false, completion: nil)
        }
        
        if MapViewController.userLoc != nil {
            zoomToLatestLocation(with: MapViewController.userLoc)
        }
    }

    
    // MARK: - Location Config
    //get location updates
    private func configureLocationServices(){
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
//        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

    }
    
    // MARK: - Tap Recognizer Config
    private func configureGestureRecognizer(){
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.delegate = self
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - Configure Subviews
    private func configureSubviews(){
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        view.addSubview(filterButton)
        filterButton.frame = CGRect(x: 10, y: 40, width: 50, height: 50)
    }
    

    //MARK: - Annotation Config
    // regisers annotation views and adds them to map
    func configureAnnotations(){
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: EventAnnotation.identifier)

        //Events
        let event1 = EventAnnotation(event: launchEvent,
                                    coordinate: CLLocationCoordinate2D(latitude: 51.5014, longitude: -0.1419))
        
        let event2 = EventAnnotation(event: randomEvent,
                                    coordinate: CLLocationCoordinate2D(latitude: 51.5313, longitude: -0.1570))
        
        
        mapView.addAnnotation(event1)
        mapView.addAnnotation(event2)
    }

    
    //configures ring overlays
    //MARK: - Ring Overlay Config
    func configureOverlays(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
//        ring1 = Ring(title: "ring1", midCoordinate: MapViewController.userLoc)
//        ring2 = Ring(title: "ring2", midCoordinate: MapViewController.userLoc)
//        ring3 = Ring(title: "ring3", midCoordinate: MapViewController.userLoc)
        
        
      
//        let ring1Overlay = RingOverlay(ring: ring1)
//        let ring2Overlay = RingOverlay(ring: ring2)
//        let ring3Overlay = RingOverlay(ring: ring3)
        
        
        ring1 = MKCircle(center: MapViewController.userLoc, radius: CLLocationDistance(AppDelegate.userDefaults.integer(forKey: "BlueRing")))
        ring2 = MKCircle(center: MapViewController.userLoc, radius: CLLocationDistance(AppDelegate.userDefaults.integer(forKey: "GreenRing")))
        ring3 = MKCircle(center: MapViewController.userLoc, radius: CLLocationDistance(AppDelegate.userDefaults.integer(forKey: "PinkRing")))
        
        mapView.addOverlay(ring1)
        mapView.addOverlay(ring2)
        mapView.addOverlay(ring3)
    }
   
  
    
    // MARK: - Map Functions
    //Zoom to user location
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D, animated: Bool = true){
        //change 20000,20000 so that it fits all 3 rings
        let zoomDistance = Double(AppDelegate.userDefaults.integer(forKey: "PinkRing") + 2000)
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: zoomDistance,longitudinalMeters: zoomDistance)
        mapView.setRegion(zoomRegion, animated: animated)
    }

    
    

}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    // fires on location update
    // redraws rings
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        if MapViewController.userLoc == nil {
            zoomToLatestLocation(with: latestLocation.coordinate, animated: false)
        }
        MapViewController.userLoc = latestLocation.coordinate

        configureOverlays()
    }
    
    // change auuthorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
}



// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation === mapView.userLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ProfileViewController.identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: ProfileViewController.identifier)
            }
            annotationView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            let profileButton = UIButton()
            
            annotationView?.addSubview(profileButton)
            profileButton.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            let layer = profileButton.layer
            layer.borderWidth = 2
            layer.borderColor = UIColor.zipBlue.cgColor
            layer.cornerRadius = layer.frame.height/2
            layer.masksToBounds = true

            profileButton.setBackgroundImage(UIImage(named: "yianni1"), for: .normal)
            profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
            
            annotationView?.layer.removeAllAnimations()
            annotationView?.zPriority = .max
            annotationView?.canShowCallout = false
            
            return annotationView
            
        } else if let eventAnnotation = annotation as? EventAnnotation {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EventAnnotation.identifier) else { return MKAnnotationView() }
            
            let img = UIImageView(image: eventAnnotation.event.image)
            annotationView.addSubview(img)
            annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

            img.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
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

        print("ERROR IN MapViewController: MKMapViewDelegate - Should not be returning nil for annotations")
       // I think this will be an error in the future - only happens if it isnt determined annotation type
        return nil
    }
    
    //did select is how you click annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.isZoomEnabled = true
        if let annotation = view.annotation as? EventAnnotation {
            let eventView = EventViewController()
            eventView.configure(annotation.event)
            eventView.modalPresentationStyle = .overCurrentContext
            present(eventView, animated: false, completion: nil)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
//        return UIColor(red: 106/255, green: 205/255, blue: 237/255, alpha: 1)
//
//        return UIColor(red: 154/255, green: 219/255, blue: 131/255, alpha: 1)
//        return UIColor(red: 233/255, green: 163/255, blue: 226/255, alpha: 1)
        
        let circleRenderer =  CircleRenderer(circle: circleOverlay)

        switch circleOverlay {
        case ring1:
            circleRenderer.gradientColor = [0.0, 0.0, 0.0, 0.0, 0.415, 0.80, 0.93, 0.8]
            circleRenderer.strokeColor = .zipBlue
            circleRenderer.alpha = 1
        case ring2:
            circleRenderer.gradientColor = [0.0, 0.0, 0.0, 0.0, 0.25, 0.89, 0.659, 0.8]
            circleRenderer.strokeColor = .zipGreen
            circleRenderer.alpha = 1
        default:
            circleRenderer.gradientColor = [0.0, 0.0, 0.0, 0.0, 0.91, 0.64, 0.886, 0.8]
            circleRenderer.strokeColor = .zipPink
            circleRenderer.alpha = 1
        }
        
        return circleRenderer
    }

}

// MARK: UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is MKAnnotationView {
            mapView.isZoomEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.mapView.isZoomEnabled = true
            }
            return false
        }
        return true
    }
}


//MARK: Tabbar Reselect
extension MapViewController: TabBarReselectHandling {
    func handleReselect() {
        if self.presentedViewController != nil {
            self.dismiss(animated: false, completion: nil)
        }
        
        if(MapViewController.userLoc != nil){
            zoomToLatestLocation(with: MapViewController.userLoc, animated: true)
        }
    }
}

class CircleRenderer: MKCircleRenderer {
    var gradientColor: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.25]
    
    override func fillPath(_ path: CGPath, in context: CGContext) {
        let rect: CGRect = path.boundingBox
        context.addPath(path)
        context.clip()
        let gradientLocations: [CGFloat]  = [0.4, 1.0]
        let gradientColors: [CGFloat] = gradientColor
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: gradientColors, locations: gradientLocations, count: 2) else { return }

        let gradientCenter = CGPoint(x: rect.midX, y: rect.midY)
        let gradientRadius = min(rect.size.width, rect.size.height) / 2
        context.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: gradientRadius, options: .drawsAfterEndLocation)
    }
}


extension MapViewController: FilterVCDelegate {
    func updateRings() {
        configureOverlays()
        zoomToLatestLocation(with: MapViewController.userLoc)
    }
}


extension MapViewController {
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


        let seung = User(userID: 1,
                         email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         name: "Seung Choi",
                         zipped: true,
                         birthday: seungBirthday,
                         location: CLLocation(latitude: 51.5014, longitude: -0.1419),
                         pictures: seungpics,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing")
        
        let ezra = User(userID: 2,
                         email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         name: "Ezra Taylor",
                         zipped: false,
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570),
                         pictures: ezrapics,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance")
        
        let yianni = User(userID: 3,
                         email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         name: "Yianni Zavaliagkos",
                         zipped: true,
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                         pictures: yiannipics,
                         bio: "Yianni. I run this shit. Know the name")

        let elias = User(userID: 4,
                         email: "elias.levy@vanderbilt.edu",
                         username: "elias.levy",
                         name: "Elias Levy",
                         zipped: true,
                         birthday: eliasBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.5070),
                         pictures: eliaspics,
                         bio: "Hey guys, I'm elias, robotics enthusiast and musician. One of the newest Zipper members. I developed the back end of the app basically making things work behind the scenes")
        
        let gabe = User(userID: 5,
                        email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        name: "Gabe Denton",
                        zipped: false,
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870),
                        pictures: gabepics,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order")
        
        self.user = yianni
        
        
        launchEvent = Event(title: "Zipper Launch Party",
                            hosts: [self.user],
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
                            hosts: [self.user],
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

        var seunginterests = [String]()
        var ezrainterests = [String]()
        var yianniinterests = [String]()
        var gabeinterests = [String]()
        var eliasinterests = [String]()

        seunginterests.append("Music")
        seunginterests.append("Producing")
        seunginterests.append("Engineering")
        seunginterests.append("Fashion")
        seunginterests.append("App Design")
        
        ezrainterests.append("Music")
        ezrainterests.append("Producing")
        ezrainterests.append("Drinking")
        ezrainterests.append("Legal Shit That No One Understands")
        ezrainterests.append("Hanging out with friends")
        
        yianniinterests.append("Chess")
        yianniinterests.append("Coding")
        yianniinterests.append("\"Getting Bitches\"")
        yianniinterests.append("Grinding Zipper")
        yianniinterests.append("Bar Hopping/Clubbing🍻")
        
        gabeinterests.append("ARK Surival (no life)")
        gabeinterests.append("Coding")
        gabeinterests.append("Developing Yianni's backend ;)")
        gabeinterests.append("Arguing over random things")
        gabeinterests.append("Frat Life")
        
        eliasinterests.append("Music")
        eliasinterests.append("Hanging out with my girlfriend")
        eliasinterests.append("Developing Yianni's backend ;)")
        eliasinterests.append("Vandi Life")
        eliasinterests.append("Frat life")

        let seung = User(userID: 1,
                         email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         name: "Seung Choi",
                         zipped: true,
                         birthday: seungBirthday,
                         location: CLLocation(latitude: 51.5014, longitude: -0.1419),
                         pictures: seungpics,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing",
                         school: "McGill University",
                         interests: seunginterests)
        
        let ezra = User(userID: 2,
                         email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         name: "Ezra Taylor",
                         zipped: false,
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570),
                         pictures: ezrapics,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance",
                         school: "McGill University",
                         interests: ezrainterests)
        
        let yianni = User(userID: 3,
                         email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         name: "Yianni Zavaliagkos",
                         zipped: true,
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                         pictures: yiannipics,
                         bio: "Yianni. I run this shit. Know the name",
                         school: "McGill Univeristy",
                         interests: yianniinterests)

        let elias = User(userID: 4,
                         email: "elias.levy@vanderbilt.edu",
                         username: "elias.levy",
                         name: "Elias Levy",
                         zipped: true,
                         birthday: eliasBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.5070),
                         pictures: eliaspics,
                         bio: "Hey guys, I'm elias, robotics enthusiast and musician. One of the newest Zipper members. I developed the back end of the app basically making things work behind the scenes",
                         school: "Vanderbilt University",
                         interests: eliasinterests)
        
        let gabe = User(userID: 5,
                        email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        name: "Gabe Denton",
                        zipped: false,
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870),
                        pictures: gabepics,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order",
                        school: "Vanderbilt University",
                        interests: gabeinterests)
        
        let list: [User] = [seung,ezra,yianni,elias,gabe]
        return list
    }
}

//Solves the corner problem
//extension UIButton {
//    private var touchPath: UIBezierPath { return UIBezierPath(ovalIn: self.bounds) }
//
//    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return touchPath.contains(point)
//    }
//}

extension MKAnnotationView {
    private var touchPath: UIBezierPath { return UIBezierPath(ovalIn: self.bounds) }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return touchPath.contains(point)
    }
}


