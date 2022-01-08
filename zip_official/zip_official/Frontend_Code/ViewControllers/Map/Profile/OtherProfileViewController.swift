//
//  OtherProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import MapKit
import CoreLocation

class OtherProfileViewController: UIViewController {
    private var user = User()
    
    // MARK: - SubViews
    private var scrollView = UIScrollView()
    private var pictureCollectionView: UICollectionView!


    // MARK: - Labels
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.sizeToFit()
        return label
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        return label
    }()
    
    private var bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private var interestsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private var birthdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    let schoolImage = UIImageView(image: UIImage(named: "school"))
    let birthdayImage = UIImageView(image: UIImage(named: "birthday"))

    
    // MARK: - Buttons
    
    private var messageButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.backgroundColor = .zipBlue
        btn.setTitle("MESSAGE", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = btn.frame.size.height/2
        return btn
    }()
    
    private var addButton:  UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add"), for: .normal)
        return btn
    }()
    var myZipsButton = UIButton()
    var myEventsButton = UIButton()
    
    
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        print("report Tapped" )
    }

    @objc private func didTapMessageButton(){
        print("Message tapped")
    }
    
    @objc private func didTapAddButton(){
        print("add tapped")
    }
    
    @objc private func didTapMyZipsButton(){
        let myZipsView = MyZipsViewController()
        myZipsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myZipsView, animated: true)
    }
    
    @objc private func didTapMyEventsButton(){
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myEventsView, animated: true)
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }
    
    public func configure(_ user: User){
        self.user = user
        configureNavBar()
        configureLabels()
        configureButtons()
        configurePictures()
        addSubviews()
        addButtonTargets()
        
    }
    
    //MARK: - ViewDidAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        adjustScaleAndAlpha()

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        scrollView.contentSize = CGSize(width: view.frame.width, height: myZipsButton.frame.maxY + 20)
        scrollView.updateContentView(20)
//        adjustScaleAndAlpha()

        
        

    }
    
    //MARK: - ViewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviewLayout()

//        scrollView.contentSize = CGSize(width: view.frame.width, height: myZipsButton.frame.maxY + 20)
        scrollView.updateContentView(20)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
                                           at: .centeredHorizontally, animated: false)
        adjustScaleAndAlpha()
    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar() {
        navigationItem.title = "@" + user.username
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "navBarReport")!.withRenderingMode(.alwaysOriginal),
                                                            landscapeImagePhone: nil,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapReportButton))
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    //MARK: - Label Config
    private func configureLabels(){
//        nameLabel.text = user.name
        nameLabel.text = user.firstName + " " + user.lastName
        ageLabel.text = String(user.age)
        bioLabel.text = user.bio
        schoolLabel.text = user.school ?? ""
        interestsLabel.text = "Interests: " + user.interests.map{$0.description}.joined(separator: ", ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        birthdayLabel.text = dateFormatter.string(from: user.birthday)
    }
    
    

    //MARK: - CollectionView config
    private func configurePictures(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        pictureCollectionView.showsHorizontalScrollIndicator = false
        pictureCollectionView.dataSource = self
        pictureCollectionView.delegate = self
        pictureCollectionView.isPagingEnabled = false
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.decelerationRate = .fast
    }
    
    //MARK: - Button config
    private func configureButtons() {        
        myZipsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myZipsButton.backgroundColor = .zipMyZipsBlue
        myZipsButton.setTitle("ZIPS", for: .normal)
        myZipsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myZipsButton.titleLabel?.textAlignment = .center
        myZipsButton.contentVerticalAlignment = .center
        myZipsButton.layer.cornerRadius = 17
        
        myEventsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myEventsButton.backgroundColor = .zipMyEventsYellow
        myEventsButton.setTitle("EVENTS", for: .normal)
        myEventsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myEventsButton.titleLabel?.textAlignment = .center
        myEventsButton.contentVerticalAlignment = .center
        myEventsButton.layer.cornerRadius = 17
    }
    
    

    
    private func addButtonTargets(){
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        myZipsButton.addTarget(self, action: #selector(didTapMyZipsButton), for: .touchUpInside)
        myEventsButton.addTarget(self, action: #selector(didTapMyEventsButton), for: .touchUpInside)

    }
    
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //username and top buttons
        view.addSubview(scrollView)
        scrollView.addSubview(pictureCollectionView!)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(ageLabel)
        scrollView.addSubview(messageButton)
        scrollView.addSubview(addButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(schoolImage)
        scrollView.addSubview(schoolLabel)
        scrollView.addSubview(interestsLabel)
        scrollView.addSubview(birthdayImage)
        scrollView.addSubview(birthdayLabel)
        scrollView.addSubview(myZipsButton)
        scrollView.addSubview(myEventsButton)
    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        //Dimensions
        
        let width = view.frame.size.width

        // scroll view constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        // Picture constraints
        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictureCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 10).isActive = true
        pictureCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pictureCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pictureCollectionView.heightAnchor.constraint(equalToConstant: width/2).isActive = true

        // name label constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor, constant: 5).isActive = true

        // age label constraints
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        // edit button constraints
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        messageButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 5).isActive = true
        messageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerYAnchor.constraint(equalTo: messageButton.centerYAnchor).isActive = true
        addButton.leftAnchor.constraint(equalTo: messageButton.rightAnchor, constant: 5).isActive = true
        addButton.heightAnchor.constraint(equalTo: messageButton.heightAnchor).isActive = true
        addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true

        
        let buffer = CGFloat(10)
        let heightBuffer = CGFloat(20)
        // bio label constraints
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        bioLabel.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: heightBuffer/2).isActive = true
        
        // school label constraints
        schoolImage.translatesAutoresizingMaskIntoConstraints = false
        schoolImage.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: buffer).isActive = true
        schoolImage.centerYAnchor.constraint(equalTo: schoolLabel.centerYAnchor).isActive = true
        schoolImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        schoolImage.widthAnchor.constraint(equalTo: schoolImage.heightAnchor).isActive = true

        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.leftAnchor.constraint(equalTo: schoolImage.rightAnchor, constant: buffer).isActive = true
        schoolLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        schoolLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: heightBuffer).isActive = true
            
        // interests label constraints
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: buffer).isActive = true
        interestsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        interestsLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: heightBuffer).isActive = true
        
        // birthday label constraints
        birthdayImage.translatesAutoresizingMaskIntoConstraints = false
        birthdayImage.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: buffer).isActive = true
        birthdayImage.centerYAnchor.constraint(equalTo: birthdayLabel.centerYAnchor).isActive = true
        birthdayImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        birthdayImage.widthAnchor.constraint(equalTo: birthdayImage.heightAnchor).isActive = true
        
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.leftAnchor.constraint(equalTo: birthdayImage.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor, constant: heightBuffer).isActive = true
        
        // my zips button constraints
        myZipsButton.translatesAutoresizingMaskIntoConstraints = false
        myZipsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        myZipsButton.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: heightBuffer).isActive = true
        myZipsButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
        myZipsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
    
        // my events button constraints
        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        myEventsButton.heightAnchor.constraint(equalTo: myZipsButton.heightAnchor).isActive = true
        myEventsButton.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: heightBuffer).isActive = true
        myEventsButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
        myEventsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
    }
    

    // MARK: - Scale/Alpha
    func adjustScaleAndAlpha(){
        let centerX = view.frame.midX
        for cell in pictureCollectionView!.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: view)
            let cellCenterX = basePosition.x + cell.frame.size.width/2
            let distance = abs(centerX-cellCenterX)
            let tolerance : CGFloat = 0.02
        
            var scale = 1.00 + tolerance - ((distance/centerX)*0.205)
            if scale > 1.0 {
                scale = 1.0
            }

            if scale < 0.5 {
                scale = 0.5
            }

            
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let coverCell = cell as! PictureCollectionViewCell
            coverCell.alpha = sizeScaleToAlphaScale(scale)
        }
    }
    
    
    func sizeScaleToAlphaScale(_ x : CGFloat) -> CGFloat{
        let minScale : CGFloat = 0.5
        let maxScale : CGFloat = 1.0
        
        let minAlpha : CGFloat = 0.25
        let maxAlpha : CGFloat = 1.0
        
        return ((maxAlpha - minAlpha) * (x - minScale)) / (maxScale - minScale) + minAlpha
    }
}

// MARK: - CollectionView DataSource
extension OtherProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = user.pictures[indexPath.row % user.pictures.count]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        cell.cornerRadius = 10
//        cell.configure(with:model)
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000 //user.pictures.count
    }
}

//MARK: - CollectionView Flow Delegate
extension OtherProfileViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: collectionView.frame.size.width/2)
    }
}

extension OtherProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var indexOfCellWithLargestWidth = 0
        var largestWidth: CGFloat = 1
        
        for cell in pictureCollectionView!.visibleCells {
            if cell.frame.size.width > largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = pictureCollectionView.indexPath(for: cell){
                    indexOfCellWithLargestWidth = indexPath.item
                }
            }
        }
        pictureCollectionView.scrollToItem(at: IndexPath(item: indexOfCellWithLargestWidth, section: 0), at: .centeredHorizontally, animated: true)
    }
}


