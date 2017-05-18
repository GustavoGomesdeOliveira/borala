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
    var facebookID: String!
    var name: String!
    var gender: String!
    var friends: [ String ]?
    var pic: Data?
    var rate: Int?
    var preference: [ String ]?
    var location: Location?
    

    override init() {
        
    }
    
    init(withId: String, facebookID: String, name:String?, gender: String, friends:[String]?, pic: Data?, rate: Int?, preference: [String]?, location: Location?) {
        self.id = withId
        self.facebookID = facebookID
        self.name = name
        self.gender = gender
        self.friends = friends
        self.pic = pic
        self.rate = rate
        self.preference = preference
        self.location = location
    }
    
    init(withId: String, name:String!, pic: Data!, facebookID: String, gender: String) {
        self.id = withId
        self.facebookID = facebookID
        self.name = name
        self.pic = pic
        self.gender = gender
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.facebookID = aDecoder.decodeObject(forKey: "facebookID") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.friends = aDecoder.decodeObject(forKey: "friends") as? [String]
        self.pic = aDecoder.decodeObject(forKey: "pic") as? Data
        self.rate = aDecoder.decodeObject(forKey: "rate") as? Int
        self.preference = aDecoder.decodeObject(forKey: "preference") as? [String]
        self.location  = aDecoder.decodeObject(forKey: "location") as? Location
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.gender, forKey: "gender")
        aCoder.encode(self.friends, forKey: "friends")
        aCoder.encode(self.pic, forKey: "pic")
        aCoder.encode(self.rate, forKey: "rate")
        aCoder.encode(self.preference, forKey: "preference")
        aCoder.encode(self.location, forKey: "location")
    }

}
