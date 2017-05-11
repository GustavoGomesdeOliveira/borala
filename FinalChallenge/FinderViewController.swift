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


let token = FBSDKAccessToken.current()
var id = ""
var parameters = ["":""]


class FinderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
//    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil
//    var pin: CustomPin?

    
    //User initial location
    var myLocation : CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
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
        
        if let token = FBSDKAccessToken.current() {
            self.mapView.setRegion(myRegion, animated: true)
        }else{
            //avisar o usuario que ele nao esta logado
        
        }
        
        
      }
    
     //Needs to be here
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print("ERRO: --- \(error)")
     }
    
    //adding custom Annotation
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let customAnnotation = annotation as? CustomPin{
//                let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
//                let mapItem = MKMapItem(placemark: placemark)
//    
//                self.mapItem = (mapItem, customAnnotation)
////                self.showRoute.isEnabled = true
//    
//                return customAnnotation.annotationView!
//            }else{
//                return nil
//            }
//        }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
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
