//
//  UserCellController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/31/22.
//

import Foundation
import UIKit



class UserCellController: TableCellController {
    
    weak var delegate : TableControllerDelegate?
    
    fileprivate let user : User
    fileprivate let cellType : UserCellType
    
    func getItem() -> CellItem {
        return user
    }
    
    init(item : CellItem, cellType: CellType) {
        if item.isEvent {
            fatalError("Passed an Event to a UserCellController")
        }
        self.user = item as! User
        self.cellType = cellType.userType
    }
    
    static func registerCell(on tableView: UITableView, cellTypes: [CellType]) {
        for cellType in cellTypes {
            switch cellType.userType {
            case .abstract: tableView.register(AbstractUserTableViewCell.self, forCellReuseIdentifier: AbstractUserTableViewCell.identifier)
            case .zipRequest: tableView.register(ZipRequestTableViewCell.self, forCellReuseIdentifier: ZipRequestTableViewCell.identifier)
            case .zipList: tableView.register(MyZipsTableViewCell.self, forCellReuseIdentifier: MyZipsTableViewCell.identifier)
            case .message: tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
            case .invite: tableView.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteTableViewCell.identifier)
            case .inviteToEventNotif: break
            case .zippedBackNotif: break
            }
        }
    }
    
    func cellFromTableView(_ tableView: UITableView, forIndexPath indexPath: IndexPath, cellType: CellType) -> UITableViewCell {
        var cell : AbstractUserTableViewCell
        switch cellType.userType {
        case .abstract: cell = tableView.dequeueReusableCell(withIdentifier: AbstractUserTableViewCell.identifier, for: indexPath) as! AbstractUserTableViewCell
        case .zipRequest: cell = tableView.dequeueReusableCell(withIdentifier: ZipRequestTableViewCell.identifier, for: indexPath) as! ZipRequestTableViewCell
        case .zipList: cell = tableView.dequeueReusableCell(withIdentifier: MyZipsTableViewCell.identifier, for: indexPath) as! MyZipsTableViewCell
        case .message: cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        case .invite: cell = tableView.dequeueReusableCell(withIdentifier: InviteTableViewCell.identifier, for: indexPath) as! InviteTableViewCell
        case .inviteToEventNotif: cell = AbstractUserTableViewCell()
        case .zippedBackNotif: cell = AbstractUserTableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.configure(user)
        user.tableViewCell = cell
        return cell
    }
    
    func didSelectCell() {
        var vc : UIViewController
        if user.userId == AppDelegate.userDefaults.value(forKey: "userId") as! String {
            vc = ProfileViewController(id: user.userId)
        } else {
            vc = OtherProfileViewController(id: user.userId)
        }
        delegate?.openVC(vc)
    }
    
    func heightForRowAt(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func fetch(completion: @escaping (Error) -> Void) {
        user.load(status: .UserProfileUpdates, dataCompletion: { result in
            switch result {
            case .success(let user):
                guard let cell = user.tableViewCell else { return }
                cell.configure(user)
            case .failure(let error):
                completion(error)
            }
        }, completionUpdates: { [weak self] result in
            guard let strongSelf = self,
                  let cell = strongSelf.user.tableViewCell else {
                return
            }
            cell.configureImage(strongSelf.user)
        })
    }
    
    func filterResult(searchText: String) -> Bool {
        return user.fullName.lowercased().contains(searchText)
            || user.username.contains(searchText)
            || user.lastName.contains(searchText)
    }
    
    func itemEquals(cellItem: CellItem) -> Bool {
        if self.getItem().isUser != cellItem.isUser { return false }
        return (getItem() as! User) == (cellItem as! User)
    }
    
}
