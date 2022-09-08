//
//  File.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/31/22.
//

import Foundation
import UIKit



public typealias MasterTableSwipeConfiguration = (style: UIContextualAction.Style, title: String?, action: ((CellItem) -> Void), exclude : [CellItem]?)

protocol MasterTableSectionHeaderDelegate: AnyObject {
    func didTapMultiSection(superSection: Int)
}

class MasterTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    fileprivate var multiSectionData : [MultiSectionData]
    fileprivate var tableData : MultiSectionData
    weak var delegate : MasterTableViewDelegate?
    
    var searchBar: UISearchBar

    var superSection = 0
    
    let tableView : UITableView
    var tableHeader: UIView? {
        didSet {
            tableView.tableHeaderView = tableHeader
        }
    }
    
    var trailingCellSwipeConfiguration : [MasterTableSwipeConfiguration]?
    var leadingCellSwipeConfiguration :  [MasterTableSwipeConfiguration]?
    
    var defaultRightBarButton: UIBarButtonItem? {
        didSet {
            self.navigationItem.rightBarButtonItem = defaultRightBarButton
        }
    }
    
    var dispearingRightButton = false
    var headerButtonStack: UIStackView?
    var fetch: Bool = true
    
    var impactedItems = [CellItem]()
    var saveFunc :  (([CellItem]) -> Void)?
    
    public var findData : (() -> [CellItem])?
    
    init(multiSectionData: [MultiSectionData], fetch: Bool = true) {
        self.tableView = UITableView()
        self.fetch = fetch
        self.multiSectionData = multiSectionData
        self.tableData = multiSectionData[superSection]
        self.searchBar = UISearchBar()
        
     
        super.init(nibName: nil, bundle: nil)
        searchBar.backgroundColor = .zipGray
        initConfig()
    }
    
    init(sectionData: [CellSectionData]) {
        self.tableView = UITableView()
        self.multiSectionData = [MultiSectionData(title: nil, sections: sectionData)]
        self.tableData = multiSectionData[superSection]
        self.searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        initConfig()
    }
    
    init(cellData: [CellItem], cellType: CellType) {
        self.tableView = UITableView()
        self.multiSectionData = [MultiSectionData(title: nil,
                                                  sections: [Self.cellControllers(with: cellData,
                                                                                 title: nil,
                                                                                 cellType: cellType)])]
        self.tableData = multiSectionData[superSection]
        self.searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        initConfig()
    }
    
    @objc public func saveFuncTarget() {
        guard let saveFunc = saveFunc else {
            return
        }
        saveFunc(impactedItems)
    }
    
    @objc public func didTapRightBarButton() {
        delegate?.didTapRightBarButton()

        if dispearingRightButton {
            if let defaultRightBarButton = defaultRightBarButton {
                navigationItem.rightBarButtonItem = defaultRightBarButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    
    private func initConfig() {
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        fetchAll()
        configureSearchbar()
        configureTable()
    }
    

    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
    
    
    private func configureSearchbar(){
        let searchController = UISearchController(searchResultsController: nil)

        searchController.searchBar.searchBarStyle = UISearchBar.Style.default
        searchController.searchBar.barStyle = .black
        searchController.searchBar.backgroundColor = .zipGray
        searchController.searchBar.barTintColor = .zipGray
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        searchController.searchBar.inputAccessoryView = doneToolbar
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureTable() {
        tableView.separatorStyle = .none
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = .zero
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        if multiSectionData.count > 1 {
            tableHeader = UIView()
            headerButtonStack = UIStackView()
            configureTableHeader()
            print("CONFIGURING")
        } else {
            print("NOT CONFIGURING")
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 1))
//            tableView.tableHeaderView?.backgroundColor = .red
        }
    }
    
    private func configureTableHeader(){
        guard let header = tableHeader,
              let buttonStack = headerButtonStack
        else {
            return
        }

        buttonStack.axis = .horizontal
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 15
        buttonStack.alignment = .leading
        
        header.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        buttonStack.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        buttonStack.rightAnchor.constraint(lessThanOrEqualTo: header.rightAnchor).isActive = true

        var superSectionIdx = 0
        for superSection in multiSectionData {
            guard let title = superSection.title else { continue }
            let btn = UIButton()
            if superSectionIdx == 0 { btn.isSelected = true }
            btn.tag = superSectionIdx
            let underlineAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextFill,
                                                                   .foregroundColor: UIColor.white,
                                                                   .underlineStyle: NSUnderlineStyle.single.rawValue]
            
            let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextFill,
                                                                   .foregroundColor: UIColor.white]
            
            let selectedAttributes = NSAttributedString(string: title, attributes: underlineAttributes)
            let unselectedAttributes = NSAttributedString(string: title, attributes: normalAttributes)
            
            btn.setAttributedTitle(selectedAttributes, for: .selected)
            btn.setAttributedTitle(unselectedAttributes, for: .normal)
            btn.addTarget(self, action: #selector(didTapSuperSectionButton(_:)), for: .touchUpInside)
            buttonStack.addArrangedSubview(btn)
            superSectionIdx += 1
        }
        
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        tableView.tableHeaderView = header
    }
    
    @objc private func didTapSuperSectionButton(_ sender: UIButton) {
        guard let buttonStack = headerButtonStack else { return }
        for btn in buttonStack.subviews.map({ $0 as! UIButton }) {
            if sender.tag == btn.tag {
                btn.isSelected = true
            } else {
                btn.isSelected = false
            }
        }
        
        self.superSection = sender.tag
        if let searchText = searchBar.text {
            filter(textSearched: searchText)
        } else {
            tableData = multiSectionData[superSection]
            tableView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .zipGray
        view.backgroundColor = .zipGray

        var cellTypes = [CellType]()
        for multiSection in multiSectionData {
            for section in multiSection.sections {
                cellTypes.append(section.cellType)
            }
        }
        
        UserCellController.registerCell(on: tableView, cellTypes: cellTypes)
        EventCellController.registerCell(on: tableView, cellTypes: cellTypes)
        tableView.register(MasterTableSectionHeader.self, forHeaderFooterViewReuseIdentifier: MasterTableSectionHeader.identifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "empty")

        tableData = multiSectionData[superSection]
//        tableView.reloadData()
        
        guard let tableHeader = tableHeader else {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 1))
            return
        }

        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame
        tableView.tableHeaderView = tableHeader
    }
    
    static func cellControllers(with items: [CellItem], title: String? , cellType: CellType) -> CellSectionData {
        let controllers : [TableCellController] = items.map { item in
            if item.isUser {
                return UserCellController(item: item, cellType: cellType)
            } else {
                return EventCellController(item: item, cellType: cellType)
            }
        }
        
        return CellSectionData(title: title, items: controllers, cellType: cellType)
    }
    
    static func cellControllers(with items: [CellItem], title: String? , cellType: UserCellType) -> CellSectionData {
        return Self.cellControllers(with: items, title: title, cellType: CellType(userType: cellType, eventType: .abstract))
    }
    
    static func cellControllers(with items: [CellItem], title: String? , cellType: EventCellType) -> CellSectionData {
        return Self.cellControllers(with: items, title: title, cellType: CellType(userType: .abstract, eventType: cellType))
    }

    public func findAndFilter() {
        
    }
    
    func fetchAll(){
        if !fetch { return }
        for multiSectionDatum in multiSectionData {
            for section in multiSectionDatum.sections {
                for item in section.items {
                    item.fetch(completion: { [weak self] error in
                        guard let itemIdx = section.items.firstIndex(where: { controller in
                            if controller.getItem().isUser != item.getItem().isUser { //they are both the same thing
                                return false
                            } else if item.getItem().isUser { // item is user -> already implied that controller item is user
                                return (item.getItem() as! User) == (controller.getItem() as! User)
                            } else {
                                return (item.getItem() as! Event) == (controller.getItem() as! Event)
                            }
                        }) else { return }
                        
                        section.items.remove(at: itemIdx)
                        self?.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    private func getItem(for indexPath: IndexPath) -> CellItem {
        return tableData.sections[indexPath.section].items[indexPath.row].getItem()
    }
    
    private func getController(for indexPath: IndexPath) -> TableCellController {
        return tableData.sections[indexPath.section].items[indexPath.row]
    }
    
    private func removeItem(at indexPath: IndexPath) {
        tableData.sections[indexPath.section].items.remove(at: indexPath.row)
    }
    
    public func reload(cellItems: [CellItem], reloadTable: Bool = true) {
        multiSectionData = [MultiSectionData(title: nil,
                                             sections: [Self.cellControllers(with: cellItems,
                                                                            title: nil,
                                                                            cellType: .zipList)])
        ]
        
        
        tableData = multiSectionData[0]
        
        if reloadTable {
            tableView.reloadData()
            fetchAll()
        }
    }
    
    public func reload(multiSectionData: [MultiSectionData]) {
        self.multiSectionData = multiSectionData
        tableData = multiSectionData[0]
        tableView.reloadData()
        fetchAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return multiSectionData[superSection].sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData.sections.count-1 < section { return 0 }
        return tableData.sections[section].items.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = tableData.sections[indexPath.section]
        let cellType = section.cellType
        var controller = section.items[indexPath.row]
        controller.delegate = self
        let cell = controller.cellFromTableView(tableView, forIndexPath: indexPath, cellType: cellType)
//        cell.contentView.backgroundColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableData.sections[indexPath.section].items[indexPath.row].didSelectCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableData.sections[indexPath.section].items[indexPath.row].heightForRowAt(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let controller = getController(for: indexPath)
        let item = controller.getItem()

        guard let configs = trailingCellSwipeConfiguration else { return nil }
        
        var contextualActions = [UIContextualAction]()
        for config in configs {
            if let exclude = config.exclude {
                if exclude.contains(where: { controller.itemEquals(cellItem: $0)}) { continue }
            }
            
            let action = UIContextualAction(style: config.style, title: config.title, handler: { [weak self] _,_,completion in
                if config.style == .destructive {
                    guard let strongSelf = self else {
                        completion(false)
                        return
                    }
                    strongSelf.removeItem(at: indexPath)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
                
                config.action(item)
                completion(true)
            })
            contextualActions.append(action)
        }
        if contextualActions.isEmpty { return nil }
        return UISwipeActionsConfiguration(actions: contextualActions)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let controller = getController(for: indexPath)
        let item = controller.getItem()

        guard let configs = leadingCellSwipeConfiguration else { return nil }
        
        var contextualActions = [UIContextualAction]()
        for config in configs {
            if let exclude = config.exclude {
                if exclude.contains(where: { controller.itemEquals(cellItem: $0)}) { continue }
            }
            
            let action = UIContextualAction(style: config.style, title: config.title, handler: { [weak self] _,_,completion in
                if config.style == .destructive {
                    guard let strongSelf = self else {
                        completion(false)
                        return
                    }
                    strongSelf.removeItem(at: indexPath)
                    tableView.deleteRows(at: [indexPath], with: .right)
                }
                
                config.action(item)
                completion(true)
            })
            contextualActions.append(action)
        }
        if contextualActions.isEmpty { return nil }
        return UISwipeActionsConfiguration(actions: contextualActions)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // no section tabs or sections
        if multiSectionData.count == 1 && multiSectionData[superSection].sections.count == 1 {
            if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0
            }
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "empty") else {
                let v =  UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 1))
                return v
            }
            view.contentView.frame =  CGRect(x: 0, y: 0, width: 50, height: 1)
            return view
        }
        
        let sectionData = multiSectionData[superSection].sections[section]
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: MasterTableSectionHeader.identifier) as! MasterTableSectionHeader
        sectionHeader.section = section
        sectionHeader.configure(title: sectionData.title)
        sectionHeader.backgroundColor = .zipVeryLightGray
        return sectionHeader
    }
}


extension MasterTableViewController :  TableControllerDelegate {
    func openVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MasterTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        filter(textSearched: textSearched)
    }
    
    func filter(textSearched: String) {
        if textSearched == "" {
            tableData = multiSectionData[superSection]
            tableView.reloadData()
        } else {
            tableData = MultiSectionData(title: multiSectionData[superSection].title, sections: [])
            for section in multiSectionData[superSection].sections {
                let itemsInSection = section.items.filter({ $0.filterResult(searchText: textSearched.lowercased())})
                tableData.sections.append(CellSectionData(title: section.title, items: itemsInSection, cellType: section.cellType))
            }
            
            tableView.reloadData()
        }
    }
}







extension MasterTableViewController {
    fileprivate class MasterTableSectionHeader: UITableViewHeaderFooterView {
        static let identifier = "MasterTableSectionHeader"
        weak var delegate: NotificationSectionHeaderDelegate?
        var section: Int?
        var sectionLabel: UILabel
        
        override init(reuseIdentifier: String?) {
            sectionLabel = UILabel.zipTextFill()
            super.init(reuseIdentifier: reuseIdentifier)
            let bg = UIView()
            addSubview(bg)
            bg.addSubview(sectionLabel)

            bg.backgroundColor = .zipLightGray
            bg.translatesAutoresizingMaskIntoConstraints = false
            bg.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            bg.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            bg.heightAnchor.constraint(equalTo: sectionLabel.heightAnchor,constant: 8).isActive = true
            
            sectionLabel.translatesAutoresizingMaskIntoConstraints = false
            sectionLabel.centerYAnchor.constraint(equalTo: bg.centerYAnchor).isActive = true
            sectionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        }
        
        public func configure(title: String?){
            sectionLabel.text = title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



