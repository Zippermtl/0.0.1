//
//  DataStorageManager.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/22/22.
//

import Foundation


class DataStorageManager {
    static internal let shared = DataStorageManager()
    
    var selfUser: User
    var selfFriends: [User]
    var selfBlocked: [User]
    var selfEvents: [Event]
    var zipRequests: [ZipRequest]
    
    private init(){
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let username = AppDelegate.userDefaults.value(forKey: "username") as! String
        let firstname = AppDelegate.userDefaults.value(forKey: "firstName") as! String
        let lastname = AppDelegate.userDefaults.value(forKey: "lastName") as! String
        let picNum = AppDelegate.userDefaults.value(forKey: "picNum") as! Int
        
        let pfpString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as! String
        let birthday = AppDelegate.userDefaults.value(forKey: "birthday") as! Date

        let pfpURL = URL(string: pfpString)!
       
        
        self.selfUser = User(userId: userId,
                             username: username,
                             firstName: firstname,
                             lastName: lastname,
                             birthday: birthday,
                             picNum: picNum,
                             pictureURLs: [pfpURL])
        
        self.selfFriends = []
        self.selfBlocked = []
        self.selfEvents = []
        self.zipRequests = []
        
    }
    
    public func getCashe() {
        getUserCashe()
        getEventCashe()
        getBlockedCashe()
    }
    
    public func getUserCashe() {
    
    }
    
    public func getEventCashe() {
    
    }
    
    public func getBlockedCashe() {
    
    }
    
}
