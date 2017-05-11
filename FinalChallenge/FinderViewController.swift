//
//  FinderViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import MapKit
import FBSDKLoginKit

let token = FBSDKAccessToken.current()
var id = ""
var parameters = ["":""]


class FinderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    

    @IBOutlet weak var notLoggedView: UIView!
    
    
    @IBOutlet weak var mapView: MKMapView!
//    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil
//    var pin: CustomPin?

    
    //User initial location
    var myLocation : CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notLoggedView.isHidden == true
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        //Requesting user location authorization
        self.locationManager.requestAlwaysAuthorization()
        
        //if user give permission we'll get the current location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
            self.mapView.showsUserLocation = true
        }
        
        
        
        DispatchQueue.main.async {
            
            FBSDKGraphRequest(graphPath: "me", parameters: nil).start { (connection, result, error) in
                
                if error != nil {
                    print(error!)
                    return
                    
                }
                
                
                print(result!)
                
                let dict = result! as! NSDictionary
                
                id =  dict["id"] as! String
            }
            
        }
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            
            parameters = ["fields": "name"]

            
            FBSDKGraphRequest(graphPath: "/\(id)/friends", parameters: parameters).start { (connection, result, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                print(result!)
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - CoreLocation

     //Updating user location on the mapView
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.myLocation = locations.first?.coordinate
        
        let distanceSpan: CLLocationDegrees = 2000
        
        let myRegion = MKCoordinateRegionMakeWithDistance(myLocation!, distanceSpan, distanceSpan)
        
        self.mapView.setRegion(myRegion, animated: true)

        
        if let token = FBSDKAccessToken.current() {
            
            
        }else{
            
            //avisar o usuario que ele nao esta logado
            
            self.notLoggedView.isHidden = false
        
        }
        
        
      }
    
     //Needs to be here
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print("ERRO: --- \(error)")
     }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            //if i want to set my pin
            let annotationIdentifier = "mylocation"
            
            var annotationView: MKAnnotationView?
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            }
            else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            if let annotationView = annotationView {
                
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "myPin")
            }
            return annotationView
        }
        
        //if i want to set the pin for an event
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "myPin")
        }
        return annotationView
    }
    

}
