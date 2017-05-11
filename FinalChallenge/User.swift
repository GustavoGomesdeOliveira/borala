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
    var name: String!
    var friends: [ String ]?
    var pic: Data?
    var rate: Int?
    var preference: [ String ]?
    var location: Location?
    
    init(withId: String, name:String?, friends:[String]?, pic: Data?, rate: Int?, preference: [String]?) {
        self.id = withId
        self.name = name
        self.friends = friends
        self.pic = pic
        self.rate = rate
        self.preference = preference
    }
    
    init(withId: String, name:String!, pic: Data!) {
        self.id = withId
        self.name = name
        self.pic = pic
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.friends = aDecoder.decodeObject(forKey: "friends") as? [String]
        self.pic = aDecoder.decodeObject(forKey: "pic") as? Data
        self.rate = aDecoder.decodeObject(forKey: "rate") as? Int
        self.preference = aDecoder.decodeObject(forKey: "preference") as? [String]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.friends, forKey: "friends")
        aCoder.encode(self.pic, forKey: "pic")
        aCoder.encode(self.rate, forKey: "rate")
        aCoder.encode(self.preference, forKey: "preference")
    }

}
