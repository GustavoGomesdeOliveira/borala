//
//  Event.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 10/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class Event {
    
    var id: String!
    var name: String!
    var location: Location!
    var creatorId: String!
    var creatorName: String!
    var beginHour: Date!
    var endHour: Date!
    var preference: String?
    var description: String?
    var chatId: String?
    
    init(name: String, location: Location, creatorId: String, creatorName: String, beginHour: Date, endHour: Date, preference: String, description: String?) {
        
        self.name = name
        self.location = location
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.beginHour = beginHour
        self.endHour   = endHour
        self.preference = preference
        self.description = description
    }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String!
        self.name = dict["name"] as! String!
        let locationDict = dict["location"] as! [String: Float]
        self.location = Location( latitude: locationDict["latitude"]!, longitude: locationDict["longitude"]!)
        self.creatorId = dict["creatorId"] as! String?
        self.creatorName = dict["creatorName"] as! String?
        self.beginHour = Date.init(timeIntervalSince1970: TimeInterval(dict["beginHour"] as! Double) )
        self.endHour   = Date.init(timeIntervalSince1970: TimeInterval(dict["endHour"] as! Double) )
        self.preference = dict["preference"] as! String?
        self.description = dict["description"] as! String?
        self.chatId = dict["chatId"] as! String!
    }
    
    
    
}
