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
    var date: String?
    var location: Location
    var locationDescription: String?
    var description: String?
    
    init(id: String, name: String, date: String, location: Location,
         locationDescription: String, description: String) {
        
        self.id = id
        self.name = name
        self.date = date
        self.location = location
        self.description = description
    }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String!
        self.name = dict["name"] as! String!
        self.date = dict["date"] as! String?
        let locationDict = dict["location"] as! [String: Float]
        self.location = Location( latitude: locationDict["latitude"]!, longitude: locationDict["longitude"]!)
        self.locationDescription = dict["locationDescription"] as! String?
        self.description = dict["description"] as! String?
    }
    
}
