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
import Firebase

let token = FBSDKAccessToken.current()
var parameters = ["":""]
var facebookFriendsID = [String]()


class FinderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FBSDKLoginButtonDelegate{
    
    

    @IBOutlet weak var notLoggedView: UIView!
    @IBOutlet weak var facebookLoginBTN: FBSDKLoginButton!
    var pin: CustomPin?

    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil

    
    @IBOutlet weak var mapView: MKMapView!
//    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil
//    var pin: CustomPin?

    
    //User initial location
    var myLocation : CLLocationCoordinate2D?
    var coordenate: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var events: [Event]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        facebookLoginBTN.delegate = self
        facebookLoginBTN.readPermissions = ["public_profile", "email", "user_friends"]

        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(FinderViewController.addMyPoint))
        
        longGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longGesture)
        
        
        
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
        
//        FirebaseHelper.getEvents(completionHandler: {
//            events in
//            if let eventsFromFirebase = events{
//            
//            }
//        })
        
        
        
        DispatchQueue.global(qos: .background).async {
            
            
            let parameters = ["fields": "name"]
            
            
            FBSDKGraphRequest(graphPath: "me/friends", parameters: parameters).start { (connection, result, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                let data = result as! NSDictionary
                
                
                for friends in data["data"] as! NSArray{
                    
                    facebookFriendsID.append((friends as! NSDictionary)["id"]! as! String)
                }
                
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
                annotationView.image = UIImage(named: "myPin1")
            }
            return annotationView
        }
        
        //Código que funciona para adicionar o pin a partir de um longpress
        if let customAnnotation = annotation as? CustomPin{
            let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            
            self.mapItem = (mapItem, customAnnotation)
            //self.showRoute.isEnabled = true
            
            return customAnnotation.annotationView!
        }else{
            return nil
        }
        
        //if i want to set the pin for an event
//        let annotationIdentifier = "Identifier"
//        var annotationView: MKAnnotationView?
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }
//        else {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        
//        if let annotationView = annotationView {
//            
//            annotationView.canShowCallout = true
//            annotationView.image = UIImage(named: "myPin")
//        }
//        return annotationView
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
            
        self.notLoggedView.isHidden = true
        if let token = result.token{

            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FIRAuth.auth()?.signIn(with: credential, completion: {
                user, error in
                if let _ = error{
                    
                    print(error.debugDescription)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.fetchProfile(id: (user?.uid)!)
                    }
                }
            })
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()//log out from firebase
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func fetchProfile(id: String){
        
        let parameters = ["fields" : "email, first_name, last_name, picture.type(large), gender, id"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let userDictionary = result! as! NSDictionary
            
            let picture = userDictionary["picture"] as! NSDictionary
            
            let data = picture["data"] as! NSDictionary
            
            let gender = userDictionary["gender"] as! String
            
            let facebookID = userDictionary["id"] as! String
            
            print(userDictionary["picture"] as! NSDictionary)
            
            let name = (userDictionary["first_name"] as! String).appending(" ").appending(userDictionary["last_name"] as! String)
            
            DispatchQueue.main.async {
                self.getImageFromURL(url: data["url"] as! String, name: name, id: id, facebookID: facebookID, gender: gender)
            }
        }
        
        
    }
    
    
    func getImageFromURL(url: String, name: String, id: String, facebookID: String, gender: String){
        
        let catPictureURL = URL(string: url)!
        
        
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        
                        let user = User(withId: id, name: name, pic: imageData, facebookID: facebookID, gender: gender)

                        let userData = NSKeyedArchiver.archivedData(withRootObject: user)
                        UserDefaults.standard.set(userData, forKey: "user")
                        // Do something with your image.
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
        
    }
    
    func addMyPoint(press : UIGestureRecognizer) {
        
        if press.state == .began{
            //Get the coordinate where the user pressed than performa segue
            
            let customY = press.location(in: self.mapView).y
            
            var locationOnView = press.location(in: self.mapView)
            locationOnView.y = customY -  30
            let coordinate = self.mapView.convert(locationOnView, toCoordinateFrom: self.mapView)

            
            let pin = CustomPin(withTitle: "teste", andLocation: coordinate, andSubtitle: "teste", andPinImage: UIImage(named: "myPin1")!)

            pin.annotationView?.image = UIImage(named: "myPin1")
            
            mapView.addAnnotation(pin)
        }
        
       
    }


}
