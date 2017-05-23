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
import GoogleSignIn

let token = FBSDKAccessToken.current()
var parameters = ["":""]
var facebookFriendsID = [String]()


class FinderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate,UIPopoverPresentationControllerDelegate,EventViewControllerDelegate {
    
    

    @IBOutlet weak var notLoggedView: UIView!
    @IBOutlet weak var facebookLoginBTN: FBSDKLoginButton!
    
    var eventVC: EventViewController?
    
    var pin: CustomPin?
    var myAnnotation: CustomPin?

    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    var annotationView: MKAnnotationView?

    var event: Bool = false
    
    //User initial location
    var myLocation : CLLocationCoordinate2D?
    var coordenate: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var events = [Event]()
    var pins = [CustomPin]()
    var myID: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
                //FirebaseHelper.saveMessage(chatId: "567", text: "nbl")
        FirebaseHelper.createChat()
        
        facebookLoginBTN.delegate = self
        facebookLoginBTN.readPermissions = ["public_profile", "email", "user_friends"]
        self.notLoggedView.isHidden = true

      //------
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(FinderViewController.addMyPoint))
        
        longGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longGesture)
        
        
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.eventVC?.delegate = self
        //Requesting user location authorization
        self.locationManager.requestAlwaysAuthorization()
        
        //if user give permission we'll get the current location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
            self.mapView.showsUserLocation = true
        }
        
        facebookLoginBTN.delegate = self
        
        facebookLoginBTN.readPermissions = ["public_profile", "email", "user_friends"]
        self.notLoggedView.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self

        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            
            self.notLoggedView.isHidden = true

        }
        
        //
//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(FinderViewController.addMyPoint))
//        
//        longGesture.minimumPressDuration = 1.0
//        self.mapView.addGestureRecognizer(longGesture)
        
    
        
        
        let user = getUser()
                    
        self.myID = user.id

        
        
        //FirebaseHelper.saveEvent()
        FirebaseHelper.getEvents(completionHandler: {
            eventsFromFirebase in
            self.events = eventsFromFirebase
            self.pins.removeAll()
            if let annotation = self.myAnnotation{
                self.pins.append(annotation)
            }
            for event in self.events{
//                print(self.myID)
//                print("-=>-")
//                print(event.creatorId)
                if (event.creatorId != self.myID){
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(event.location.latitude), longitude: CLLocationDegrees(event.location.longitude))
                    
                    var imageName = event.preference
                    if imageName == nil {
                        imageName = "mypin1"
                    }else{
                        imageName?.append("pin")
                    }
                    
                    let eventPin = CustomPin(coordinate: coordinate)
                    eventPin.title = "teste"
                    self.pins.append(eventPin)
                }
            }

            self.mapView.addAnnotations(self.pins)
            
        })
      
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
    
    func showPopup(sender: UIButton!) {
        
        let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "Popup")
        popupVC?.preferredContentSize = CGSize(width: 250, height: 150)
        popupVC?.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let rect = sender.superview?.convert(sender.frame, to: self.view)
        popupVC?.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate
        popupVC?.popoverPresentationController?.sourceView = self.view
        popupVC?.popoverPresentationController?.sourceRect = rect!
        popupVC?.popoverPresentationController?.backgroundColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1)
        
        self.present(popupVC!, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // This *forces* a popover to be displayed on the iPhone
        return .none
    }
    
    // MARK: - CoreLocation

     //Updating user location on the mapView
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.myLocation = locations.first?.coordinate
        
        let distanceSpan: CLLocationDegrees = 2000
        
        let myRegion = MKCoordinateRegionMakeWithDistance(myLocation!, distanceSpan, distanceSpan)
        
         myAnnotation = CustomPin(coordinate: myLocation!)
        //mandar adicionar o pin agora
        self.pins.append(myAnnotation!)
        
        self.mapView.setRegion(myRegion, animated: true)
       
        self.myAnnotation?.pinImage = UIImage(named: "mypin1")
        
//        mapView.addAnnotation(self.myAnnotation!)
        
        if let token = FBSDKAccessToken.current() {
            
            
        }else{
            
            //avisar o usuario que ele nao esta logado
            
            //self.notLoggedView.isHidden = false
        
        }
        
        
      }
    
     //Needs to be here
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print("ERRO: --- \(error)")
     }
    
    // MARK: - Mapkit
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            
            //if i want to set my pin
            let annotationIdentifier = "mylocation"

            
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = myAnnotation
            }
            else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            annotationView?.annotation = myAnnotation
            if let annotationView = annotationView {
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "mypin1")

            }
            
            return annotationView
        }
    
        //aqui comeca
        
        var myannotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "mylocation") as! AnnotationView?
        
        if myannotationView == nil{
            myannotationView = AnnotationView(annotation: annotation, reuseIdentifier: "mylocation")
            myannotationView?.canShowCallout = false
        }else{
            //aqui n enentdi
            myannotationView?.annotation = annotation
        }
        
        let pinAnnotation = annotation as! CustomPin
        myannotationView?.detailCalloutAccessoryView = UIImageView(image: pinAnnotation.pinImage)
        
        let pinImage = UIImage.init(named: "pizzapin")
//        myannotationView?.image = pinImage
        myannotationView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        myannotationView?.mapPin = UIButton(frame: (myannotationView?.frame)!)
        myannotationView?.mapPin.addTarget(self, action: #selector(FinderViewController.showPopup(sender:)), for: .touchDown)
        myannotationView?.mapPin.isUserInteractionEnabled = true
        myannotationView?.addSubview((myannotationView?.mapPin)!)
        myannotationView?.mapPin.setImage(pinImage, for: .normal)
        
        
        return myannotationView
        
        //Código que funciona para adicionar o pin a partir de um longpress
//        if let customAnnotation = annotation as? CustomPin{
//            let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
//            let mapItem = MKMapItem(placemark: placemark)
//            mapView.showsUserLocation = false
//            self.mapItem = (mapItem, customAnnotation)
//            //self.showRoute.isEnabled = true
//            
//            return customAnnotation.annotationView!
//        }else{
//            return nil
//        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let coordinate = view.annotation?.coordinate
//        let myRegion: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (coordinate!.latitude), longitude: (coordinate!.longitude))
        
//        let distanceSpan: CLLocationDegrees = 2000
//        
//        let myRegion = MKCoordinateRegionMakeWithDistance(coordinate!, distanceSpan, distanceSpan)
//        
//        mapView.centerCoordinate = myRegion
//        mapView.setCenter(myRegion, animated: true)
//        mapView.animatedZoom(zoomRegion: myRegion, duration: 0.2)
        print("test")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        // The map item is the restaurant location
        let mapItem = MKMapItem(placemark: placemark)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
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
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        appDelegate.fetchProfile(id: (user?.uid)!)
                    }
                }
            })
        }
        
    }
    
    
    //setar action do botao
    @IBAction func addEvent(_ sender: Any) {
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()//log out from firebase
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func addMyPoint(press : UIGestureRecognizer) {
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            print("tem")
        }
        
        if ((FBSDKAccessToken.current() == nil) && (!GIDSignIn.sharedInstance().hasAuthInKeychain())){
            
            self.notLoggedView.isHidden = false
            
        } else {
            
            if press.state == .began{

                if event == false{
                    
                    
//                    let customY = press.location(in: self.mapView).y
//                    
                    var locationOnView = press.location(in: self.mapView)
//                    
                    let coordinate = self.mapView.convert(locationOnView, toCoordinateFrom: self.mapView)
//
//                    let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
//                    
//                    let northWest = mapView.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: mapView)
//                    
//                    let southEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: mapView.bounds.height), toCoordinateFrom: mapView)
//                    
//                    let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

                    
                    
                    let pin = CustomPin(coordinate: coordinate)

                    pin.pinImage = UIImage(named: "mypin2")
                    
                    mapView.addAnnotation(pin)
                    
                    let user = getUser()
                    
                    let location = Location(latitude: Float(coordinate.latitude), longitude: Float(coordinate.longitude))
                    
                    
                    let event = Event(id: "", name: pin.title!, location: location, creatorId: user.id, creatorName: user.name, hora: getHour(), preference: "Pizza")
                    FirebaseHelper.saveEvent(event: event)
                }
                
            }
        
        
        }
        
        
    }
    
    func getHour() -> String{
        
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        
        print("Dateobj: \(dateFormatter.string(from: date))")
        
        return dateFormatter.string(from: date)
        
    }
    
    
    func getUser() -> User{
        
        var user = User()
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            
            user = (NSKeyedUnarchiver.unarchiveObject(with: userData) as? User)!
            
            
        }
        
        return user

    }
    
    func sendEvent( event : String) {
        print(event)
    }

}

extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
        }, completion: nil)
    }
}
