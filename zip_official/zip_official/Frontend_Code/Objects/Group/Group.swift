//
//  Group.swift
//  zip_official
//
//  Created by user on 10/28/22.
//

import Foundation
import CoreAudio

public class Group: CustomStringConvertible, Equatable, Comparable {
    
    public enum GroupError: Error {
        case groupIdNotPresent
        case improperAccess
    }
    
    var users: [User] = []
    var id: String = ""
    var adm: String = ""
    var coverIndex: [Int] = []
    var pictures: [Int] = []
    var title: String = ""
//    var picNum: Int = -1
    private var hasBeenEdited : Bool {
        return history != nil
    }
    private var history : Group? = nil
    private var safeId : Bool {
        return id != ""
    }
    private var isAdmin : Bool {
        if(adm != ""){
            return (AppDelegate.userDefaults.value(forKey: "userId") as! String == adm)
        } else {
            return true
        }
    }
    var urls: [Int: URL] = [:]
    
    var coverUrl: [URL] {
        get {
            var ret: [URL] = []
            if let r = urls[coverIndex[0]] {
                ret.append(r)
                return ret
            } else {
                return []
            }
        }
        set(input) {
            urls[coverIndex[0]] = input[0]
        }
    }
    
    var pictureUrls: [URL] {
        get {
            var ret: [URL] = []
            for i in pictures {
                if let r = urls[i] {
                    ret.append(r)
                }
            }
            return ret
        }
    }
    
    var picNum : Int {
        return pictures.count + coverIndex.count
    }
    
    var size : Int {
        return users.count
    }
    
    var hasCover : Bool {
        return (coverIndex.count >= 0)
    }
    
    init(lhsGroup: Group){
        users = lhsGroup.users
        id = lhsGroup.id
        adm = lhsGroup.adm
        coverIndex = lhsGroup.coverIndex
        pictures = lhsGroup.pictures
        title = lhsGroup.title
    }
    
    init(userList:[User] = [], groupId:String = "", admin: String = "", coverPicIndex: [Int] = [], pictureIndices: [Int] = [], groupTitle: String = ""){
        users = userList
        id = groupId
        adm = admin
        coverIndex = coverPicIndex
        pictures = pictureIndices
        title = groupTitle
    }
    
    init(groupId: String){
        id = groupId
    }
    
    init(){
        
    }
    
    public static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func < (lhs: Group, rhs: Group) -> Bool {
        return lhs.users.count < rhs.users.count
    }
    
    public var description : String {
        var out = ""
        out += "GroupIdentifier = \(id) \n"
        out += "Group Name/Title = \(title) \n"
        out += "Size = \(size) \n"
        out += "CoverId = \(coverIndex) \n"
        out += "Picture Ids = \(pictures) \n"
        out += "picNum = \(picNum) \n"
        out += "Members = \(users) \n"
        return out
    }
    
    
    public func pull(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.getGroup(group: self, completion: { err in
            guard err == nil else {
                completion(err)
                return
            }
        })
    }
    
    public func push(completion: @escaping (Error?) -> Void) {
        if hasBeenEdited {
            if let a = history {
                var changeUsers = false
                var update = false
                var delete: [User] = []
                var add: [User] = []
                for i in users {
                    if !a.users.contains(i){
                        add.append(i)
                        changeUsers = true
                    }
                }
                for j in a.users {
                    if !users.contains(j) {
                        delete.append(j)
                        changeUsers = true
                    }
                }
                if (id != a.id || adm != a.adm || coverIndex != a.coverIndex || pictures != a.pictures || title != a.title) {
                    update = true
                }
                history = nil
                if (update) {
                    DatabaseManager.shared.updateGroup(group: self, completion: { [weak self] err in
                        guard let strongSelf = self else {
                            return
                        }
                        guard err == nil else {
                            strongSelf.history = a
                            completion(err)
                            return
                        }
                    })
                }
                if (changeUsers) {
                    if (add.count != 0){
                        DatabaseManager.shared.addToGroup(group: self, users: add, completion: { [weak self] err in
                            guard let strongSelf = self else {
                                return
                            }
                            guard err == nil else {
                                strongSelf.history = a
                                completion(err)
                                return
                            }
                        })
                    }
                    if (delete.count != 0){
                        DatabaseManager.shared.removeFromGroup(group: self, users: delete, completion: { [weak self] err in
                            guard let strongSelf = self else {
                                return
                            }
                            guard err == nil else {
                                strongSelf.history = a
                                completion(err)
                                return
                            }
                        })
                    }
                }
            }
        }
    }
    
    public func write(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.createGroup(group: self, completion: { err in
            guard err == nil else {
                completion(err)
                return
            }
        })
    }
    
    public func getUserList() -> [String] {
        var a: [String] = []
        for i in users {
            a.append(i.userId)
        }
        return a
    }
    
    public func getEncoder() -> GroupCoder {
        let gEnc = GroupCoder(group: self)
        return gEnc
    }
    
    public func addUsers(userList: [User]) {
        let temp = Group(lhsGroup: self)
        for i in userList {
            if (!users.contains(i)){
                users.append(i)
                if (!hasBeenEdited){
                    history = temp
                }
            }
        }
    }
    
    public func removeUsers(userList: [User]){
        let temp = Group(lhsGroup: self)
        for i in userList {
            users.removeAll(where: { j in
                if(j.userId == i.userId) {
                    if(!hasBeenEdited){
                        history = temp
                    }
                    return true
                }
                return false
            })
        }
    }
    
    public func changeAdmin(admin: User) -> Error? {
        let temp = Group(lhsGroup: self)
        if !isAdmin {
            return GroupError.improperAccess
        } else {
            if(adm != admin.userId) {
                adm = admin.userId
            }
        }
        return nil
    }
    
    public func changeTitle(text: String){
        let temp = Group(lhsGroup: self)
        if(title != text) {
            if(!hasBeenEdited){
                history = temp
            }
            title = text
        }
    }
    
    public func restore(){
        if let temp = history {
            users = temp.users
            id = temp.id
            adm = temp.adm
            coverIndex = temp.coverIndex
            pictures = temp.pictures
            title = temp.title
            history = nil
        }
    }
    
    public func loadCover() async -> [URL] {
        return await getUrls(list: pictures)
    }
    
    public func loadPictures() async -> [URL] {
        return await getUrls(list: coverIndex)
    }
    
    public func getUrls(list: [Int]) async -> [URL] {
        var j: [Int] = []
        for i in list {
            if urls[i] == nil {
                j.append(i)
            }
        }
        var tmp = await getUrlsInternal(list: j)
        for i in 0...tmp.count {
            urls[list[i]] = tmp[i]
        }
        return tmp
    }
    
    private func getUrlsInternal(list: [Int]) async -> [URL] {
        await withCheckedContinuation { cont in
            DatabaseManager.shared.getImages(Id: id, indices: list, type: DatabaseManager.ImageType.groupPicturesIndices, completion: { res in
                switch res{
                case .success(let url):
                    cont.resume(returning: url)
                case .failure(let err):
                    cont.resume(returning: [])
                }
            })
        }
    }
}
