//
//  User.swift
//  FinalChallenge
//
//  Created by Williamberg on 09/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding{
    
    var id: String!//firebase Id
    var socialNetworkID: String!
    var name: String!
    var gender: String!
    var notificationToken: String!
    var age: Int?
    var friendsId: [String: Any]?
    var pic: Data?
    var picUrl: String?
    var rate: Int?
    var dislikeIds: [String: Bool]?//ids of users that dislike me.
    var likeIds: [String: Bool]?   //ids of users that like me.
    var preferences: [ String ]?
    var chatsIds: [String: Any]?
 
    override init() {
        
    }
    
    init(withId: String, socialNetworkID: String, name:String?, gender: String, friends:[String: Any]?, pic: Data?, rate: Int?, preference: [String]?, location: Location?) {
        self.id = withId
        self.socialNetworkID = socialNetworkID
        self.name = name
        self.gender = gender
        self.friendsId = friends
        self.pic = pic
        self.rate = rate
        self.preferences = preference
        
    }
    
    init(withId: String, name:String!, pic: Data!, socialNetworkID: String, gender: String, notificationToken: String) {
        self.id = withId
        self.socialNetworkID = socialNetworkID
        self.name = name
        self.pic = pic
        self.gender = gender
        self.notificationToken = notificationToken
    }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String!
        self.name = dict["name"] as! String!
        self.picUrl = dict["picURL"] as! String!
        self.socialNetworkID = dict["socialNetworkID"] as! String!
        self.gender = dict["gender"] as! String!
        self.notificationToken = dict["notificationToken"] as! String!
        self.age = dict["age"] as! Int!
        self.rate = dict["rate"] as! Int!
        self.likeIds = dict["likeIds"] as? [String: Bool]
        self.dislikeIds = dict["dislikeIds"] as? [String: Bool]

    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.socialNetworkID = aDecoder.decodeObject(forKey: "socialNetworkID") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.notificationToken = aDecoder.decodeObject(forKey: "notificationToken") as? String
        self.age = aDecoder.decodeObject(forKey: "age") as? Int
        self.friendsId = aDecoder.decodeObject(forKey: "friendsId") as? [String: Any]
        self.pic = aDecoder.decodeObject(forKey: "pic") as? Data
        self.picUrl = aDecoder.decodeObject(forKey: "picURL") as? String
        self.rate = aDecoder.decodeObject(forKey: "rate") as? Int
        
        self.preferences = aDecoder.decodeObject(forKey: "preferences") as? [String]
        self.chatsIds = aDecoder.decodeObject(forKey: "chatsIds") as? [String: Any]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.gender, forKey: "gender")
        aCoder.encode(self.notificationToken, forKey: "notificationToken")
        aCoder.encode(self.age, forKey: "age")
        aCoder.encode(self.friendsId, forKey: "friendsId")
        aCoder.encode(self.pic, forKey: "pic")
        aCoder.encode(self.picUrl, forKey: "picURL")
        aCoder.encode(self.rate, forKey: "rate")
        aCoder.encode(self.preferences, forKey: "preference")
        aCoder.encode(self.chatsIds, forKey: "chatsIds")
    }
    
    
    func toDictionary() -> [String: Any] {
        var friendsDictionary = [String: Any]()
        var preferenceDictionary = [String: Any]()
        if let friends = self.friendsId{
            for friend in friends{
                friendsDictionary.updateValue(true, forKey: friend.key)
            }
        }
        if let preferences = self.preferences{
            for preference in preferences{
                preferenceDictionary.updateValue(true, forKey: preference)
            }
        }
        if let chatsIds = self.chatsIds{
            for chatId in chatsIds{
                preferenceDictionary.updateValue( true , forKey: chatId.key)
            }
        }
        return ["id": self.id, "socialNetworkID": socialNetworkID, "name": self.name, "gender": self.gender, "notificationToken": self.notificationToken,
                "age": self.age ?? -1, "friendsId": friendsDictionary,"rate": self.rate ?? -1,
                "dislikeIds": self.dislikeIds ?? true, "likeIds": self.likeIds ?? true,
                "preferences": preferenceDictionary,"chatsIds": preferenceDictionary]
    }
}
