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
    var date: Date?
    var locationLatitude: Float?
    var locationLongitude: Float?
    var locationDescription: String?
    var description: String?
    
    init(id: String, name: String, date: Date, locationLatitude: Float, locationLongitude: Float,
         locationDescription: String, description: String) {
        
        self.id = id
        self.name = name
        self.date = date
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.description = description
    }
    
}
