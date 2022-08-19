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
    var loadedData: [SearchObject] = []
    var returnData: [SearchObject] = []
//    var unfinishedUsers: [User] = []
//    var unfinishedEvents: [Event] = []
//    var tempData = NSDictionary
    var searchVal: [String] = []
    var presQuery: String = ""
    
    init(){
    }
    
    public func StartSearch(searchString: String, event: Bool = false, user: Bool = false, finishedLoadingCompletion: @escaping (Result<SearchObject, Error>) -> Void, allCompletion: @escaping (Result <[SearchObject], Error>) -> Void){
        let queryText = searchString.lowercased()
        var index = -1
        var newq = true
        for i in 0..<searchVal.count {
            if (queryText.contains(searchVal[i])) {
                newq = false
                index = i
                print("Data Exists in previous query")
            }
        }
        
        if(index != -1 || newq){
            updateSearch(ss: queryText)
            print(presQuery + " in index -1")
            DatabaseManager.shared.getSearchBarData(queryText: presQuery, event: event, user: user, finishedLoadingCompletion: { [weak self] res in
                switch res{
                case .success(let data):
                    print("here in ln 41")
                    let prints = data.getSearch()
                    for i in prints {
                        print(i)
                    }
                    if let testing = data.user?.profilePicUrl {
                        print(testing)
                    } else {
                        print("lost url")
                    }
                    if let ind = self?.loadedData.firstIndex(of: data){
                        if (self?.loadedData[ind].isEvent() as! Bool) {
                            let event = (self?.loadedData[ind].event!)!
                            event.imageUrl = data.event?.imageUrl
                            if let cell = event.tableViewCell,
                                event.imageUrl != nil {
                                
                                cell.configureImage(event)
                            }
                        } else if (self?.loadedData[ind].isUser() as! Bool) {
                            let user = (self?.loadedData[ind].user!)!
                            user.profilePicUrl = data.user!.profilePicUrl
                            user.pictureURLs = data.user!.pictureURLs
                            if let cell = user.tableViewCell,
                                user.profilePicUrl != nil {
                                
                                cell.configureImage(user)
                            }
                        }
                    } else {
                        self?.loadedData.append(data)
                        self?.returnData.append(data)
                        print(data.getId() + " is the Ids of data " + data.getSearch()[0] )
                    }
                    
                    finishedLoadingCompletion(.success(data))
                case .failure(let err):
                    finishedLoadingCompletion(.failure(err))
                }
            }, allCompletion: { [weak self] res in
                switch res{
                case .success(let data):
                    print("here in ln 64")
                    self?.loadedData.append(contentsOf: data)
                    let finalData = self?.sortSearch(returns: data)
                    print("FINAL DATA = \n\(finalData)")
                    allCompletion(.success(finalData ?? []))
                case .failure(let err):
                    allCompletion(.failure(err))
                }
            })
        } else if (searchVal[index] == presQuery){
            print("here in ln 73")
            updateSearch(ss: queryText)
            allCompletion(.success(returnData))
            finishedLoadingCompletion(.success(SearchObject(User(userId: "0"))))
        } else {
            print("here in ln 78")
            updateSearch(ss: queryText)
            returnData = sortSearch(empty: true)
            allCompletion(.success(returnData))
            finishedLoadingCompletion(.success(SearchObject(User(userId: "0"))))
        }
        
    }
    
    private func updateSearch(ss: String, new: Bool = true){
        presQuery = ss
        if (new){
            searchVal.append(ss)
        }
    }
    
    private func sortSearch(returns: [SearchObject] = [], empty: Bool = false) -> [SearchObject] {
        var local: [SearchObject] = []
        var front: [SearchObject] = []
        print("sorting search")
        let friends = User.getMyZips().map({SearchObject($0)})
        let invitedEvents = User.getInvitedEvents().map({SearchObject($0)})
        
        let Priority = friends+invitedEvents
//        var
        if(returns.count == 0 || empty){
            for i in loadedData{
                for j in i.getSearch() {
                    if (j.contains(presQuery)){
                        if (i.isEvent()) {
                            if invitedEvents.contains(i){
                                front.append(i)
                            } else {
                                local.append(i)
                            }
                        } else if (i.isUser()) {
                            if friends.contains(i){
                                front.append(i)
                            } else {
                                local.append(i)
                            }
                        }
                    }
                }
            }
        } else {
            for i in returns{
                if (Priority.contains(i)){
                    front.append(i)
                } else {
                    local.append(i)
                }
            }
        }
        front.append(contentsOf: local)
        returnData = front
        return returnData
    }
    
}
