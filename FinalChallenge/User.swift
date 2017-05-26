//
//  User.swift
//  FinalChallenge
//
//  Created by padrao on 09/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding{
    
    var id: String!
    var socialNetworkID: String!
    var name: String!
    var gender: String!
    var age: Int?
    var friendsId: [ String ]?
    var pic: Data?
    var picUrl: String?
    var rate: Int?
    var preferences: [ String ]?
    var chatsIds:[String: Any]?
 
    override init() {
        
    }
    
    init(withId: String, socialNetworkID: String, name:String?, gender: String, friends:[String]?, pic: Data?, rate: Int?, preference: [String]?, location: Location?) {
        self.id = withId
        self.socialNetworkID = socialNetworkID
        self.name = name
        self.gender = gender
        self.friendsId = friends
        self.pic = pic
        self.rate = rate
        self.preferences = preference
    }
    
    init(withId: String, name:String!, pic: Data!, socialNetworkID: String, gender: String) {
        self.id = withId
        self.socialNetworkID = socialNetworkID
        self.name = name
        self.pic = pic
        self.gender = gender
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.socialNetworkID = aDecoder.decodeObject(forKey: "socialNetworkID") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.age = aDecoder.decodeObject(forKey: "age") as? Int
        self.friendsId = aDecoder.decodeObject(forKey: "friendsId") as? [String]
        self.pic = aDecoder.decodeObject(forKey: "pic") as? Data
        self.rate = aDecoder.decodeObject(forKey: "rate") as? Int
        self.preferences = aDecoder.decodeObject(forKey: "preferences") as? [String]
        self.chatsIds = aDecoder.decodeObject(forKey: "chatsIds") as? [String: Any]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.gender, forKey: "gender")
        aCoder.encode(self.age, forKey: "age")
        aCoder.encode(self.friendsId, forKey: "friendsId")
        aCoder.encode(self.pic, forKey: "pic")
        aCoder.encode(self.rate, forKey: "rate")
        aCoder.encode(self.preferences, forKey: "preference")
        aCoder.encode(self.chatsIds, forKey: "chatsIds")
    }
    
    
    func toDictionary() -> [String: Any] {
        var friendsDictionary = [String: Any]()
        var preferenceDictionary = [String: Any]()
        if let friends = self.friendsId{
            for friend in friends{
                friendsDictionary.updateValue(true, forKey: friend)
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
        return ["id": self.id, "socialNetworkID": socialNetworkID, "name": self.name, "gender": self.gender,
                "age": self.age ?? -1, "friendsId": friendsDictionary,"rate": self.rate ?? -1, "preferences": preferenceDictionary,"chatsIds": preferenceDictionary]
    }
}
