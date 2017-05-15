//
//  Location.swift
//  FinalChallenge
//
//  Created by C. Williamberg on 11/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class Location: NSObject, NSCoding{
    
    var latitude: Float
    var longitude: Float
    
    init(latitude: Float, longitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
    }
    required public init?(coder aDecoder: NSCoder){
        self.latitude = (aDecoder.decodeObject(forKey: "latitude") as? Float)!
        self.longitude = (aDecoder.decodeObject(forKey: "longitude") as? Float)!
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
    }
}
