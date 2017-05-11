//
//  customPin.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 10/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import MapKit


class customPinAnnotation: NSObject,MKAnnotation{

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    
    init(title: String, coordinate: CLLocationCoordinate2D, imageName: String) {
        self.title = title
        self.coordinate = coordinate
        self.image = UIImage(named: imageName)
       
    }

}
