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
        var queryText = searchString.lowercased()
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
            DatabaseManager.shared.getSearchBarData(queryText: presQuery, event: event, user: user, finishedLoadingCompletion: { res in
                switch res{
                case .success(let data):
                    finishedLoadingCompletion(.success(data))
                case .failure(let err):
                    finishedLoadingCompletion(.failure(err))
                }
            }, allCompletion: { [weak self] res in
                switch res{
                case .success(let data):
                    self?.loadedData.append(contentsOf: data)
                    let finalData = self?.sortSearch(returns: data)
                    allCompletion(.success(finalData ?? []))
                case .failure(let err):
                    allCompletion(.failure(err))
                }
            })
        } else if (searchVal[index] == presQuery){
            
        } else {
            
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
        let friends = User.getMyZips().map({SearchObject($0)})
        let invitedEvents = User.getInvitedEvents().map({SearchObject($0)})
        
        let Priority = friends+invitedEvents
//        var
        if(returns.count == 0 || empty){
            for i in loadedData{
                for i in loadedData{
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
        } else {
            for i in returns{
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
        front.append(contentsOf: local)
        return front
    }
    
}
