//
//  customPin.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 10/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import MapKit


class CustomPin: NSObject,MKAnnotation{
    
    let title: String?
    let subtitle: String?
    
    let coordinate: CLLocationCoordinate2D
    let pinImage: UIImage
    
    init(withTitle title:String, andLocation location:CLLocationCoordinate2D, andSubtitle subtitle:String, andPinImage image: UIImage) {
        self.pinImage = image
        self.title = title
        self.subtitle = subtitle
        self.coordinate = location
    }
    
    var annotationView: MKAnnotationView?{
        
        let view = MKAnnotationView(annotation: self, reuseIdentifier: "event")
        view.image = self.pinImage
        view.isEnabled = true
        view.canShowCallout = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: "poke")!, for: .normal)
        
        return view
    }
    
    
}
