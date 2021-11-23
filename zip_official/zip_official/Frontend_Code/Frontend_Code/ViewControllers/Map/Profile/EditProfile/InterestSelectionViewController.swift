//
//  InterestSelectionViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/3/21.
//

import UIKit


protocol UpdateInterestsProtocol {
    func updateInterests(_ interests: [Interests])
}

class InterestSelectionViewController: UIViewController, UpdateInterestsProtocol {
    
    var userInterests: [Interests] = []
    var delegate: UpdateInterestsProtocol?

    let interestLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody.withSize(26)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody.withSize(26)
        label.textColor = .zipVeryLightGray
        return label
    }()
    
    let clearButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("clear", for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        return btn
    }()
    
    var collectionView: UICollectionView?

    func updateInterests(_ interests: [Interests]) {
        delegate?.updateInterests(userInterests)
    }
    
    @objc private func didTapDoneButton(){
        updateInterests(userInterests)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapClearButton(){
        userInterests = []
        collectionView?.reloadData()
        interestLabel.text = "Interests: " + userInterests.map{$0.description}.joined(separator: ", ")
//        countLabel.text = userInterests.count.description + "0/5"

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "INTERESTS"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
        view.backgroundColor = .zipGray
        configureCollectionView()
        

       
        interestLabel.text = "Interests: " + userInterests.map{$0.description}.joined(separator: ", ")
        countLabel.text = userInterests.count.description + "/5"
        
        view.addSubview(interestLabel)
        view.addSubview(countLabel)
        view.addSubview(clearButton)
        view.addSubview(collectionView!)
        
    }
    


    
    override func viewWillLayoutSubviews() {
        interestLabel.translatesAutoresizingMaskIntoConstraints = false
        interestLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        interestLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        interestLabel.rightAnchor.constraint(equalTo: clearButton.leftAnchor, constant: -10).isActive = true
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.bottomAnchor.constraint(equalTo: interestLabel.centerYAnchor).isActive = true
        countLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        countLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor).isActive = true
        clearButton.centerXAnchor.constraint(equalTo: countLabel.centerXAnchor).isActive = true

        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.topAnchor.constraint(equalTo: interestLabel.bottomAnchor, constant: 10).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    

    private func configureCollectionView() {
        let layout = LeftOreintedFlowLayout()
        layout.minimumLineSpacing = 5

        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView?.register(InterestsCollectionViewCell.self, forCellWithReuseIdentifier: InterestsCollectionViewCell.identifier)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self

        
        collectionView?.backgroundColor = .zipGray
        view.addSubview(collectionView!)
    }
    
    


}


//MARK: - CollectionView Delegate
extension InterestSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.zipBody]
        return CGSize(width: Interests.allCases[indexPath.row].description.size(withAttributes: fontAttributes).width+20,
                      height: 40)
        
    }
    

}

//MARK: - CollectionView DataSource
extension InterestSelectionViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Interests.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestsCollectionViewCell.identifier, for: indexPath) as! InterestsCollectionViewCell

        let cellInterest = Interests.allCases[indexPath.row]
        cell.label.text = cellInterest.description
        cell.tag = Interests.allCases[indexPath.row].rawValue
        cell.label.textColor = .white
        cell.label.font = .zipBody
        

        cell.configure()
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.zipLightGray.cgColor
        cell.layer.cornerRadius = 20
        
        if userInterests.contains(cellInterest) {
            cell.label.textColor = .zipBlue
            cell.layer.borderColor = UIColor.zipBlue.cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCollectionViewCell
        let idx = userInterests.firstIndex(of: Interests.init(rawValue: cell.tag)!)
        if  idx != nil{
            userInterests.remove(at: idx!)
            collectionView.reloadData()
        } else if userInterests.count < 5 {
            userInterests.append(Interests.init(rawValue: cell.tag) ?? .acting)
            collectionView.reloadData()
        }
        userInterests.sort(by: {$0.rawValue < $1.rawValue})
        interestLabel.text = "Interests: " + userInterests.map{$0.description}.joined(separator: ", ")
        countLabel.text = userInterests.count.description + "/5"

    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    
}


class LeftOreintedFlowLayout : UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}


enum Interests: Int, CaseIterable, CustomStringConvertible {
    case acting
    case activism
    case art
    case astrology
    case athlete
    case blm
    case baking
    case basketball
    case bingeWatching
    case blogging
    case boardGames
    case brunch
    case cannabis
    case cars
    case catLover
    case chess
    case climateChange
    case climbing
    case coding
    case coffee
    case collecting
    case comedy
    case cooking
    case craftBeer
    case crossfit
    case cycling
    case diy
    case djing
    case dancing
    case dogLover
    case environmentalism
    case fashion
    case feminism
    case festivals
    case fishing
    case foodie
    case football
    case gardening
    case givingAdvice
    case golf
    case grabADrink
    case graphicDesign
    case greekLife
    case gymnastics
    case hiking
    case history
    case hockey
    case iceSkating
    case karaoke
    case lgbtq
    case lgbtqRights
    case language
    case learning
    case makeup
    case makingMusic
    case mathematics
    case mentalHealthAwareness
    case military
    case mixology
    case movies
    case museum
    case music
    case outdoors
    case partying
    case photography
    case picnicking
    case poetry
    case politics
    case puzzles
    case rapping
    case reading
    case roadTrips
    case running
    case science
    case shopping
    case singing
    case skiing
    case sleeping
    case snowboarding
    case soccer
    case spirituality
    case sports
    case surfing
    case swimming
    case tattoos
    case tea
    case thrifting
    case travel
    case trivia
    case vegan
    case vegetarian
    case videoGames
    case vlogging
    case volunteering
    case voterRights
    case walking
    case wine
    case workingOut
    case writing
    case yoga
    
    var description: String {
        switch self {
        case .acting: return "Acting"
        case .activism: return "Activism"
        case .art: return "Art"
        case .astrology: return "Astrology"
        case .athlete: return "Athlete"
        case .blm: return "BLM"
        case .baking: return "Baking"
        case .basketball: return "Basketball"
        case .bingeWatching: return "Binge-watching"
        case .blogging: return "Blogging"
        case .boardGames: return "Board Games"
        case .brunch: return "Brunch"
        case .cannabis: return "Cannabis"
        case .cars: return "Cars"
        case .catLover: return "Cat Lover"
        case .chess: return "Chess"
        case .climateChange: return "Climate Change"
        case .climbing: return "Climbing"
        case .coding: return "Coding"
        case .coffee: return "Coffee"
        case .collecting: return "Collecting"
        case .comedy: return "Comedy"
        case .cooking: return "Cooking"
        case .craftBeer: return "Craft Beer"
        case .crossfit: return "Crossfit"
        case .cycling: return "Cycling"
        case .diy: return "DIY"
        case .djing: return "DJing"
        case .dancing: return "Dancing"
        case .dogLover: return "Dog Lover"
        case .environmentalism: return "Environmentalism"
        case .fashion: return "Fashion"
        case .feminism: return "Feminism"
        case .festivals: return "Festivals"
        case .fishing: return "Fishing"
        case .foodie: return "Foodie"
        case .football: return "Football"
        case .gardening: return "Gardening"
        case .givingAdvice: return "Giving Advice"
        case .golf: return "Golf"
        case .grabADrink: return "Grab A Drink"
        case .graphicDesign: return "Graphic Design"
        case .greekLife: return "Greek Life"
        case .gymnastics: return "Gymnastics"
        case .hiking: return "Hiking"
        case .history: return "History"
        case .hockey: return "Hockey"
        case .iceSkating: return "Ice Skating"
        case .karaoke: return "Karaoke"
        case .lgbtq: return "LGBTQ+"
        case .lgbtqRights: return "LGBTQ+ Rights"
        case .language: return "Language"
        case .learning: return "Learning"
        case .makeup: return "Makeup"
        case .makingMusic: return "Making Music"
        case .mathematics: return "Mathematics"
        case .mentalHealthAwareness: return "Mental Health Awareness"
        case .military: return "Military"
        case .mixology: return "Mixology"
        case .movies: return "Movies"
        case .museum: return "Museum"
        case .music: return "Music"
        case .outdoors: return "Outdoors"
        case .partying: return "Partying"
        case .photography: return "Photography"
        case .picnicking: return "Picnicking"
        case .poetry: return "Poetry"
        case .politics: return "Politics"
        case .puzzles: return "Puzzles"
        case .rapping: return "Rapping"
        case .reading: return "Reading"
        case .roadTrips: return "Road Trips"
        case .running: return "Running"
        case .science: return "Science"
        case .shopping: return "Shopping"
        case .singing: return "Singing"
        case .skiing: return "Skiing"
        case .sleeping: return "Sleeping"
        case .snowboarding: return "Snowboarding"
        case .soccer: return "Soccer"
        case .spirituality: return "Spirituality"
        case .sports: return "Sports"
        case .surfing: return "Surfing"
        case .swimming: return "Swimming"
        case .tattoos: return "Tattoos"
        case .tea: return "Tea"
        case .thrifting: return "Thrifting"
        case .travel: return "Travel"
        case .trivia: return "Trivia"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .videoGames: return "Video Games"
        case .vlogging: return "Vlogging"
        case .volunteering: return "Volunteering"
        case .voterRights: return "Voter Rights"
        case .walking: return "Walking"
        case .wine: return "Wine"
        case .workingOut: return "Working Out"
        case .writing: return "Writing"
        case .yoga: return "Yoga"
        }
    }
}
