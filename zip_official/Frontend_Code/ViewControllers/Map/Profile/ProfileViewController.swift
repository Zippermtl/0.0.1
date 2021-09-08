//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


// Infinite Scroll Wheel of pictures
// https://stackoverflow.com/questions/34396108/how-to-implement-horizontally-infinite-scrolling-uicollectionview

import UIKit
import MapKit
import CoreLocation

class ProfileViewController: UIViewController {
    static let identifier = "profile"
    static let identifierWithImage = "profileWithImage"
    static let identifierLastCell = "profileLastCell"
    static let identifierFirstCell = "profileFirstCell"


    
    private var user = User()
    private var tableData = [String]()
    private var birthday = ""
    
    // MARK: - SubViews
    private var topViewContainer = UIView()
    private var pictureCollectionView: UICollectionView!
    private var scrollingContainer = UIView()
    private var infoHeaderContainer = UIView()
    private var tableView = UITableView()

    
    // MARK: - Labels
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        return label
    }()
    
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
    
    
    // MARK: - Buttons
    var backButton = UIButton()
    var settingsButton = UIButton()
    var editProfileButton = UIButton()
    
    var lastCell = UIView()
    var myZipsButton = UIButton()
    var myEventsButton = UIButton()
    
    
    
    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)

        self.dismiss(animated: false, completion: nil)
        
    }

    @objc private func didTapSettingsButton(){
        let settingsView = SettingsPageViewController()
        settingsView.modalPresentationStyle = .overCurrentContext
        
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: nil)
        present(settingsView, animated: false, completion: nil)

        print("settings tapped")
    }

    @objc private func didTapEditButton(){
        let editView = EditProfileViewController()
        editView.modalPresentationStyle = .overCurrentContext
        editView.configure(with: user)
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: nil)
        present(editView, animated: false, completion: nil)

        print("edit tapped")
    }
    
    @objc private func didTapMyZipsButton(){
        let myZipsView = MyZipsViewController()
        myZipsView.modalPresentationStyle = .overCurrentContext
        present(myZipsView, animated: true, completion: nil)
        print("myZips tapped")
    }
    
    @objc private func didTapMyEventsButton(){
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext

        present(myEventsView, animated: true, completion: nil)
        print("myEvents tapped")
    }
    

    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        generateTestData()
       
        configureLabels()
        configureButtons()
        configureTable()
        configurePictures()
        addSubviews()
        addButtonTargets()
        
    }
    
    //MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        adjustScaleAndAlpha()
    }
    
    //MARK: - ViewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        configureSubviewLayout()
        if user.pictures.count > 2 {
            pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0), at: .centeredHorizontally, animated: false)
        }

    }
    
    //MARK: - Table Config    
    private func configureTable(){
        configureTableData()
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierFirstCell)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierWithImage)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierLastCell)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    private func configureTableData(){
        tableData.append(user.bio)
        if user.school != nil {
            tableData.append(user.school!)
        }
        tableData.append("Interests: " + user.interests.map{$0}.joined(separator: ", "))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        birthday = dateFormatter.string(from: user.birthday)
        tableData.append(birthday)
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
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.contentInset = UIEdgeInsets(top: 0, left: view.frame.width/4, bottom: 0, right: view.frame.width/4)
        pictureCollectionView.decelerationRate = .fast

    }
    
    //MARK: - Button config
    private func configureButtons() {
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        settingsButton.setImage(UIImage(named: "settings"), for: .normal)

        editProfileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        editProfileButton.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        editProfileButton.setTitle("EDIT", for: .normal)
        editProfileButton.titleLabel?.textColor = .white
        editProfileButton.titleLabel?.font = .zipBodyBold
        editProfileButton.titleLabel?.textAlignment = .center
        editProfileButton.contentVerticalAlignment = .center
        editProfileButton.layer.cornerRadius = editProfileButton.frame.size.height/2
        
        myZipsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myZipsButton.backgroundColor = .zipMyZipsBlue
        myZipsButton.setTitle("MY ZIPS", for: .normal)
        myZipsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myZipsButton.titleLabel?.textAlignment = .center
        myZipsButton.contentVerticalAlignment = .center
        myZipsButton.layer.cornerRadius = 17
        
        myEventsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myEventsButton.backgroundColor = .zipMyEventsYellow
        myEventsButton.setTitle("MY EVENTS", for: .normal)
        myEventsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myEventsButton.titleLabel?.textAlignment = .center
        myEventsButton.contentVerticalAlignment = .center
        myEventsButton.layer.cornerRadius = 17
        
        configureLastCell()
    }
    
    private func configureLastCell(){
        lastCell.addSubview(myZipsButton)
        lastCell.addSubview(myEventsButton)
                
        myZipsButton.translatesAutoresizingMaskIntoConstraints = false
        myZipsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        myZipsButton.centerYAnchor.constraint(equalTo: lastCell.centerYAnchor).isActive = true
        myZipsButton.rightAnchor.constraint(equalTo: lastCell.centerXAnchor, constant: -5).isActive = true
        myZipsButton.leftAnchor.constraint(equalTo: lastCell.leftAnchor, constant: 15).isActive = true

        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        myEventsButton.heightAnchor.constraint(equalTo: myZipsButton.heightAnchor).isActive = true
        myEventsButton.centerYAnchor.constraint(equalTo: lastCell.centerYAnchor).isActive = true
        myEventsButton.leftAnchor.constraint(equalTo: lastCell.centerXAnchor, constant: 5).isActive = true
        myEventsButton.rightAnchor.constraint(equalTo: lastCell.rightAnchor, constant: -15).isActive = true
    }
    
    private func addButtonTargets(){
        // topViewContainer
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        
        // infoHeaderContainer
        editProfileButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        myZipsButton.addTarget(self, action: #selector(didTapMyZipsButton), for: .touchUpInside)
        myEventsButton.addTarget(self, action: #selector(didTapMyEventsButton), for: .touchUpInside)

    }

    //MARK: - Label Config
    private func configureLabels(){
        nameLabel.text = user.name
        ageLabel.text = String(user.age)
        usernameLabel.text = "@" + user.username
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //username and top buttons
        view.addSubview(topViewContainer)
        topViewContainer.addSubview(usernameLabel)
        topViewContainer.addSubview(backButton)
        topViewContainer.addSubview(settingsButton)

        view.addSubview(scrollingContainer)
        //photos
        scrollingContainer.addSubview(pictureCollectionView!)
        scrollingContainer.addSubview(infoHeaderContainer)
        infoHeaderContainer.addSubview(nameLabel)
        infoHeaderContainer.addSubview(ageLabel)
        infoHeaderContainer.addSubview(editProfileButton)
        
        //table view
        view.addSubview(tableView)
        

    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        //Dimensions
        
        let width = view.frame.size.width
        
        // Top container
        topViewContainer.frame = CGRect(x: 0,
                                        y: view.safeAreaInsets.top,
                                        width: width,
                                        height: 60)
        //Pictures
        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictureCollectionView.topAnchor.constraint(equalTo: scrollingContainer.topAnchor).isActive = true
        pictureCollectionView.leftAnchor.constraint(equalTo: scrollingContainer.leftAnchor).isActive = true
        pictureCollectionView.rightAnchor.constraint(equalTo: scrollingContainer.rightAnchor).isActive = true
        pictureCollectionView.heightAnchor.constraint(equalToConstant: width/2).isActive = true

        // Containers
                

        // info header constraints
        // height = height of contents + 5 buffer
        let infoHeaderHeight = nameLabel.intrinsicContentSize.height + editProfileButton.frame.height + ageLabel.intrinsicContentSize.height
        infoHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        infoHeaderContainer.leftAnchor.constraint(equalTo: scrollingContainer.leftAnchor).isActive = true
        infoHeaderContainer.rightAnchor.constraint(equalTo: scrollingContainer.rightAnchor).isActive = true
        infoHeaderContainer.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor).isActive = true
        infoHeaderContainer.heightAnchor.constraint(equalToConstant: infoHeaderHeight).isActive = true

        // tableView constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        tableView.topAnchor.constraint(equalTo: topViewContainer.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // many more constraints
        addLabelConstraints()
        addButtonConstraints()
    }
    
    private func addLabelConstraints(){
        // username label constraints
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.centerXAnchor.constraint(equalTo: topViewContainer.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topViewContainer.topAnchor, constant: 5).isActive = true

        // name label constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.widthAnchor.constraint(equalToConstant: nameLabel.intrinsicContentSize.width).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: nameLabel.intrinsicContentSize.height).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: infoHeaderContainer.topAnchor).isActive = true
        
        // age label constraints
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.widthAnchor.constraint(equalToConstant: ageLabel.intrinsicContentSize.width).isActive = true
        ageLabel.heightAnchor.constraint(equalToConstant: ageLabel.intrinsicContentSize.height).isActive = true
        ageLabel.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
    }
    
    private func addButtonConstraints(){
        // Top View Container
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: usernameLabel.topAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topViewContainer.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.topAnchor.constraint(equalTo: usernameLabel.topAnchor).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor).isActive = true
        settingsButton.rightAnchor.constraint(equalTo: topViewContainer.rightAnchor, constant: -20).isActive = true
        settingsButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true

        // Info Header Container
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        editProfileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editProfileButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor).isActive = true
        editProfileButton.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
    }
    
    // MARK: - Scale/Alpha
    func adjustScaleAndAlpha(){
        let centerX = self.pictureCollectionView!.center.x
        for cell in self.pictureCollectionView!.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
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

// MARK: - Extensions
extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var model: UIImage
        if user.pictures.count > 2 {
            model = user.pictures[indexPath.row % user.pictures.count]
        } else {
            model = user.pictures[indexPath.row]
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with:model)
        return cell
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if user.pictures.count > 2 {
            return 10000
        } else {
            return user.pictures.count
        }
    }
}

extension ProfileViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: collectionView.frame.size.width/2)
    }
}

extension ProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var indexOfCellWithLargestWidth = 0
        var largestWidth: CGFloat = 1
        
        for cell in self.pictureCollectionView!.visibleCells {
            if cell.frame.size.width > largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = self.pictureCollectionView.indexPath(for: cell){
                    indexOfCellWithLargestWidth = indexPath.item
                }
            }
        }
        pictureCollectionView.scrollToItem(at: IndexPath(item: indexOfCellWithLargestWidth, section: 0), at: .centeredHorizontally, animated: true)
    }
}







//MARK: TableDelegate
extension ProfileViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.frame.width/2 +
                   nameLabel.intrinsicContentSize.height +
                   editProfileButton.frame.height +
                   ageLabel.intrinsicContentSize.height + 10
        } else if indexPath.row < tableData.count{
            return tableData[indexPath.row-1].heightForWrap(width: tableView.frame.width) + 30
        } else {
            return 60
        }
    }
}

//MARK: TableDataSource
extension ProfileViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierFirstCell, for: indexPath) as! ProfileTableViewCell

            cell.contentView.addSubview(scrollingContainer)
            scrollingContainer.translatesAutoresizingMaskIntoConstraints = false
            scrollingContainer.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            scrollingContainer.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
            scrollingContainer.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            scrollingContainer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else if indexPath.row < tableData.count+1 {
            switch tableData[indexPath.row-1] {
            case user.school:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.textLabel?.text = ""
                
                cell.configure(with: tableData[indexPath.row-1], image: UIImage(named: "school")!)
                cell.backgroundColor = .clear
//                cell.backgroundColor = .green
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
                
            case birthday:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.configure(with: tableData[indexPath.row-1], image: UIImage(named: "birthday")!)
                cell.backgroundColor = .clear
//                cell.backgroundColor = .green
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifier, for: indexPath) as! ProfileTableViewCell
                
                let label = cell.textLabel!
                label.text = tableData[indexPath.row-1]
                label.textColor = .white
                label.font = .zipBody
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.sizeToFit()
                label.frame = cell.frame
                
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false

//                cell.backgroundColor = .red
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierLastCell, for: indexPath) as! ProfileTableViewCell
            cell.contentView.addSubview(lastCell)
            lastCell.translatesAutoresizingMaskIntoConstraints = false
            lastCell.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            lastCell.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
            lastCell.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            lastCell.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
        }
    }
}

//creates frame with wrapped text to see what the height will be
extension String {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = self
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}

extension UILabel {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = self.text
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}







//MARK: - TestData
extension ProfileViewController {
    func generateTestData(){
        var yiannipics = [UIImage]()
        var interests = [String]()
        
        interests.append("Skiing")
        interests.append("Coding")
        interests.append("Chess")
        interests.append("Wine")
        interests.append("Working out")


        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        


        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        
        self.user = User(userID: 3,
                         email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         name: "Yianni Zavaliagkos",
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                         pictures: yiannipics,
                         bio: "Yianni Zavaliagkos. Second Year at Mcgill. Add my snap and follow my insta @Yianni_Zav. I run this shit. Remember my name when I pass Zuckerberg on Forbes",
                         school: "McGill University",
                         interests: interests)
    }
}
