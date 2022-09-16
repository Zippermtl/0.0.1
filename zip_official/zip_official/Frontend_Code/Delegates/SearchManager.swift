//
//  SearchBarManager.swift
//  zip_official
//
//  Created by user on 6/27/22.
//
import Foundation
import FirebaseDatabase

class SearchManager{
    static let shared = SearchManager()
//    var loadedData: [SearchObject] = []
    var loadedData: [String:SearchObject] = [:]
    var returnData: [String] = []
//    var unfinishedUsers: [User] = []
//    var unfinishedEvents: [Event] = []
//    var tempData = NSDictionary
    var searchVal: [String] = []
    var presQuery: String = ""
    lazy var priority: [SearchObject] = {
        let friends = User.getMyZips().map({SearchObject($0)})
        let invitedEvents = User.getUDEvents(toKey: .invitedEvents).map({SearchObject($0)})
        let host = User.getUDEvents(toKey: .hostedEvents)
        let saved = User.getUDEvents(toKey: .savedEvents)
        return friends+invitedEvents
    }()
    
    init(){
    }
    
    public func updatePriority(event: Event, user: User){
//        lazy var priority: [SearchObject] = {
            let friends = User.getMyZips().map({SearchObject($0)})
            let invitedEvents = User.getUDEvents(toKey: .invitedEvents).map({SearchObject($0)})
            let host = User.getUDEvents(toKey: .hostedEvents)
            let saved = User.getUDEvents(toKey: .savedEvents)
            priority = friends+invitedEvents
    }
    
    public func newQuery(searchString: String) -> Bool {
        let queryText = searchString.lowercased()
        if (queryText == ""){
            return false
        } else {
            for i in 0..<searchVal.count {
                print("searchVal data at the start of query")
                print(searchVal[i])
                print(searchVal.count)
                if (queryText.contains(searchVal[i])) {
//                    if(queryText!.first == searchVal!.first){
                        return false
//                        index = i
//                        print("Data Exists in previous query")
//                    }
//                    addOldData = true
                }
            }
        }
        return true
    }
    
    public func StartSearch(searchString: String, event: Bool = false, user: Bool = false, finishedLoadingCompletion: @escaping (Result<String, Error>) -> Void, allCompletion: @escaping (Result <[String], Error>) -> Void){
        let queryText = searchString.lowercased()
        var index = -1
        var newq = true
        var addOldData = false
        if(queryText == ""){
            
        } else {
            for i in 0..<searchVal.count {
                print("searchVal data at the start of query")
                print(searchVal[i])
                print(searchVal.count)
                if (queryText.contains(searchVal[i])) {
//                    if(queryText!.first == searchVal!.first){
                        newq = false
                        index = i
                        print("Data Exists in previous query")
//                    }
                    addOldData = true
                }
            }
            
//            if(index == -1 || newq){
            if(index != -1 || newq){
                updateSearch(ss: queryText)
                print(presQuery + " in index -1")
                DatabaseManager.shared.getSearchBarData(queryText: presQuery, event: event, user: user, finishedLoadingCompletion: { [weak self] res in
                    let presData = self?.loadedData

                    switch res{
                    case .success(let data):
                        print("here in ln 41")
                        let prints = data.getSearch()
                        for i in prints {
                            print(i)
                        }
//                        if let testing = data.user?.profilePicUrl {
//                            print(testing)
//                        } else {
//                            print("lost url")
//                        }
                        let key = data.getId()
                        if (self?.loadedData[key] == nil) {
                            self?.loadedData[key] = data
                        } else {
    //                        if (self?.loadedData[key]?.getUrl() == nil){
    //
    //                        }
                            if(self?.loadedData[key]?.isEvent() as! Bool){
                                self?.loadedData[key]?.event?.imageUrl = data.getUrl()
                            } else if (self?.loadedData[key]?.isUser() as! Bool){
                                let fullnameCheck = self?.loadedData[key]?.user!.fullName
                                let datacheck = data.user!.fullName
                                if ((fullnameCheck == fullnameCheck?.lowercased()) && (datacheck.lowercased() == datacheck)){
                                    self?.loadedData[key]?.user?.FillSelf(user: data.user!)
                                } else {
                                    self?.loadedData[key]?.user?.updateSelfHard(user: data.user!)
                                }
                                //MARK: Problem on line above is an optimization problem due to load user profile taking
                                ///more time than not doing loaduserprofile base
                                ///possible fixes:
                                ///ignore and just set user like we do in most places
                                ///find a way to shallow copy edit the base system
                                ///use loaduserprofileupdates to have two completions in individual completion which will update the user differently
                                ///update all the necessary data and get table view version -> could cause errors in opening the profile if we assume it is fully loaded
//                                self?.loadedData[key]?.user?.profilePicUrl = data.getUrl()
                            }
                            
                            //setUrl(url: data.getUrl()!)
                        }
//                        print(data.user?.profilePicUrl as! URL)
                        if (self?.loadedData[key] != nil) {
    //                        guard let s
                            if (self?.loadedData[key]!.isEvent() as! Bool){
                                let event = (self?.loadedData[key]!.event!)!
                                event.imageUrl = data.event?.imageUrl
                                if let cell = event.tableViewCell,
                                    event.imageUrl != nil {
                                    
                                    cell.configureImage(event)
                                }
                            } else if (self?.loadedData[key]!.isUser() as! Bool){
                                let user = (self?.loadedData[key]!.user!)!
                                user.profilePicUrl = data.user!.profilePicUrl
                                user.pictureURLs = data.user!.pictureURLs
                                if let cell = user.tableViewCell,
                                    user.profilePicUrl != nil {
                                    
                                    cell.configureImage(user)
                                }
                            }
                        } else {
                            
                        }
//                        var temp: [String] = []
////                        for i in data {
////                            temp.append(i.getId())
////                        }
//                        temp.append(data.getId())
                        finishedLoadingCompletion(.success(data.getId()))
                    case .failure(let err):
                        finishedLoadingCompletion(.failure(err))

    //                    if let ind = self?.loadedData.firstIndex(of: data){
    //                        if (self?.loadedData[ind].isEvent() as! Bool) {
    //                            let event = (self?.loadedData[ind].event!)!
    //                            event.imageUrl = data.event?.imageUrl
    //                            if let cell = event.tableViewCell,
    //                                event.imageUrl != nil {
    //
    //                                cell.configureImage(event)
    //                            }
    //                        } else if (self?.loadedData[ind].isUser() as! Bool) {
    //                            let user = (self?.loadedData[ind].user!)!
    //                            user.profilePicUrl = data.user!.profilePicUrl
    //                            user.pictureURLs = data.user!.pictureURLs
    //                            if let cell = user.tableViewCell,
    //                                user.profilePicUrl != nil {
    //
    //                                cell.configureImage(user)
    //                            }
    //                        }
    //                    } else {
    //                        self?.loadedData.append(data)
    //                        self?.returnData.append(data)
    //                        print(data.getId() + " is the Ids of data " + data.getSearch()[0] )
    //                    }
                        
                        
                    }
                }, allCompletion: { [weak self] res in
                    let presData = self?.loadedData
                    switch res{
                    case .success(let data):
                        print("here in ln 64")
                        for i in data {
                            let key = i.getId()
                            if (self?.loadedData[key] == nil) {
                                self?.loadedData[key] = i
                            }
                        }
    //                    self?.loadedData.append(contentsOf: data)
                        if addOldData {
                            let finalData = self?.sortSearch(returns: data)
                            //MARK: temp fix for the edge case edited above with mark
//                            let finalData = self?.sortSearch(returns: data+self!.returnData)

                            print("FINAL DATA = \n\(finalData)")
                            allCompletion(.success(finalData ?? []))
                        } else {
                            let finalData = self?.sortSearch(returns: data)
                            print("FINAL DATA = \n\(finalData)")
                            allCompletion(.success(finalData ?? []))
                        }
                        
                    case .failure(let err):
                        allCompletion(.failure(err))
                    }
                })
            } else if (searchVal[index] == presQuery){
                print("here in ln 73")
                updateSearch(ss: queryText)
                allCompletion(.success(returnData))
                finishedLoadingCompletion(.success("0"))
            } else {
                print("here in ln 78")
                updateSearch(ss: queryText)
                returnData = sortSearch(empty: true)
                allCompletion(.success(returnData))
                finishedLoadingCompletion(.success("0"))
            }
        }
    }
    
    private func updateSearch(ss: String, new: Bool = true){
        presQuery = ss
        if (new){
            searchVal.append(ss)
        }
    }
    
    private func getPriorityLoaded() -> [SearchObject]{
        var front: [SearchObject] = []
        for (i,j) in loadedData{
            for l in j.getSearch() {
                var singleUse = true
                if (l.contains(presQuery) && singleUse){
                    singleUse = false
                    if(priority.contains(j) && j.getUrl() != nil){
                        front.append(j)
                    }
//                        if (j.isEvent()) {
//                            if invitedEvents.contains(j){
//                                front.append(j)
//                            } nnelse {
//                                local.append(j)
//                            }
//                        } else if (j.isUser()) {
//                            if friends.contains(j){
//                                front.append(j)
//                            } else {
//                                local.append(j)
//                            }
//                        }
                }
            }
        }
        return front
    }
    
    private func sortSearch(returns: [SearchObject] = [], empty: Bool = false) -> [String] {
        var local: [String] = []
        var front: [String] = []
        print("sorting search")
        let printForGabe = searchVal
//        let kms = loadedData
//        var
        if(returns.count == 0 || empty){
            for (i,j) in loadedData{
                for l in j.getSearch() {
                    var singleUse = true
                    if (l.contains(presQuery) && singleUse){
                        singleUse = false
                        if(priority.contains(j)){
                            front.append(j.getId())
                        } else {
                            local.append(j.getId())
                        }
//                        if (j.isEvent()) {
//                            if invitedEvents.contains(j){
//                                front.append(j)
//                            } nnelse {
//                                local.append(j)
//                            }
//                        } else if (j.isUser()) {
//                            if friends.contains(j){
//                                front.append(j)
//                            } else {
//                                local.append(j)
//                            }
//                        }
                    }
                }
            }
        } else {
            for i in returns{
                if (priority.contains(i)){
                    front.append(i.getId())
                } else {
                    local.append(i.getId())
                }
            }
        }
        front.append(contentsOf: local)
        returnData = front
        return returnData
    }
    
}
