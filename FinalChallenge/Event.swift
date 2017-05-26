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
    var hora: String!
    var preference: String?
    var chatId: String?
    
    init(id: String, name: String, location: Location, creatorId: String, creatorName: String, hora: String, preference: String) {
        
        self.id = id
        self.name = name
        self.location = location
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.hora = hora
        self.preference = preference
    }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String!
        self.name = dict["name"] as! String!
        let locationDict = dict["location"] as! [String: Float]
        self.location = Location( latitude: locationDict["latitude"]!, longitude: locationDict["longitude"]!)
        self.creatorId = dict["creatorId"] as! String?
        self.creatorName = dict["creatorName"] as! String?
        self.hora = dict["hour"] as! String?
        self.preference = dict["preference"] as! String?
        self.chatId = dict["chatId"] as! String!
    }
    
    
    
}
