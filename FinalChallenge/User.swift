//
//  User.swift
//  FinalChallenge
//
//  Created by padrao on 09/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class User{
    
    var id: String!
    var name: String!
    var friends: [ String ]?
    var pic: Data!
    var rate: Int
    var preference: [ String ]?
    
    init(withId: String, name:String, friends:[String]?, pic: Data, rate: Int, preference: [String]?) {
        self.id = withId
        self.name = name
        self.friends = friends
        self.pic = pic
        self.rate = rate
        self.preference = preference
    }

}
