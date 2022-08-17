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
        self.selfFriends = []
        self.selfBlocked = []
        self.selfEvents = []
        self.zipRequests = []
        self.selfUser = User()
        
        guard AppDelegate.userDefaults.value(forKey: "userId") != nil else {
            return
        }
        
        updateUser()
    }

    public func updateUser() {
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
              let username = AppDelegate.userDefaults.value(forKey: "username") as? String,
              let firstname = AppDelegate.userDefaults.value(forKey: "firstName") as? String,
              let lastname = AppDelegate.userDefaults.value(forKey: "lastName") as? String,
              let picNum = AppDelegate.userDefaults.value(forKey: "picNum") as? Int,
              let pfpString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String,
//              let picIndices = AppDelegate.userDefaults.value(forKey: <#T##String#>)
              let birthday = AppDelegate.userDefaults.value(forKey: "birthday") as? Date else {
                  return
        }
       
        let pfpURL = URL(string: pfpString)!

        selfUser.userId = userId
        selfUser.username = username
        selfUser.firstName = firstname
        selfUser.lastName = lastname
        selfUser.birthday = birthday
        selfUser.picNum = picNum
        selfUser.pictureURLs = [pfpURL]
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
