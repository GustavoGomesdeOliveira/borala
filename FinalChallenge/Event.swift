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
    var date: String?
    var hora: String?
    var name: String!
    var location: Location
    var creatorId: String?
    var creatorName: String?
    var preference: String?
    
    init(id: String, name: String, date: String, location: Location, creatorId: String, creatorName: String, preference: String, hora: String) {
        
        self.id = id
        self.name = name
        self.date = date
        self.location = location
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.preference = preference
        self.hora = hora
    }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String!
        self.name = dict["name"] as! String!
        self.date = dict["date"] as! String?
        let locationDict = dict["location"] as! [String: Float]
        self.location = Location( latitude: locationDict["latitude"]!, longitude: locationDict["longitude"]!)
        self.creatorId = dict["creatorId"] as! String?
        self.creatorName = dict["creatorName"] as! String?
        self.preference = dict["preference"] as! String?
        self.hora = dict["hora"] as! String?


    }
    
}
