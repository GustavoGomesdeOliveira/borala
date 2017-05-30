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


class FinderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate,UIPopoverPresentationControllerDelegate,EventViewControllerDelegate, PinPopupViewControllerDelegate {
    
    

    @IBOutlet weak var notLoggedView: UIView!
    @IBOutlet weak var facebookLoginBTN: FBSDKLoginButton!
    
//    var eventVC: EventViewController?
    
    var pin: CustomPin?
    var myAnnotation: CustomPin?
    var selectedUserID: String?
    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil
    
    var selectedUser: User?
    
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
        
        
        
        facebookLoginBTN.delegate = self
        facebookLoginBTN.readPermissions = ["public_profile", "email", "user_friends"]
        self.notLoggedView.isHidden = true

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
        
        facebookLoginBTN.delegate = self
        
        facebookLoginBTN.readPermissions = ["public_profile", "email", "user_friends"]
        self.notLoggedView.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self

        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            
            self.notLoggedView.isHidden = true

        }
        
        
        let user = getUser()
                    
        self.myID = user.id

        
        FirebaseHelper.getEvents(completionHandler: {
            eventsFromFirebase in
            self.events = eventsFromFirebase
            self.pins.removeAll()
            
            var eventExist = false
            
            
            for event in self.events{

                if (event.creatorId != self.myID){
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(event.location.latitude), longitude: CLLocationDegrees(event.location.longitude))
                    
                    var imageName = event.preference
                    if imageName == nil {
                        imageName = "pizza"
                    }else{
                        imageName?.append("pin")
                    }
                    
                    let eventPin = CustomPin(coordinate: coordinate)
                    eventPin.title = "teste"
                    eventPin.pinImage = UIImage(named: imageName!)
                    eventPin.event = event
//                    print("testando aqui")
//                    print(event.hora)
//                    print("---------------")
                    
                    self.pins.append(eventPin)
                }
                else{
                    eventExist = true
                    self.mapView.showsUserLocation = false
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(event.location.latitude), longitude: CLLocationDegrees(event.location.longitude))
                    let myPin = CustomPin(coordinate: coordinate)
                    myPin.title = "teste"
                    myPin.pinImage = UIImage(named: "mypin2")
                    myPin.event = event
                    self.pins.append(myPin)
                }
            }
            if eventExist{
                self.mapView.showsUserLocation = false
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
    
//    func showPopup(sender: UIButton!) {
//        
//        let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "Popup")
//        popupVC?.preferredContentSize = CGSize(width: 250, height: 150)
//        popupVC?.modalPresentationStyle = UIModalPresentationStyle.popover
//        
//        let rect = sender.superview?.convert(sender.frame, to: self.view)
//        popupVC?.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate
//        popupVC?.popoverPresentationController?.sourceView = self.view
//        popupVC?.popoverPresentationController?.sourceRect = rect!
//        popupVC?.popoverPresentationController?.backgroundColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1)
//        
//        
//        self.present(popupVC!, animated: true, completion: nil)
//    }
    
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
        
        self.mapView.setRegion(myRegion, animated: true)
       
        
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
    
        //for custom pins
        
        if let dequeuedAnnotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "pins"){
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = myAnnotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pins")
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        let pinAnnotation = annotation as! CustomPin
        annotationView?.annotation = myAnnotation
        if let annotationView = annotationView {
            annotationView.canShowCallout = false
            annotationView.image = pinAnnotation.pinImage
            
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        let popUpPinVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinPopup") as! PinPopupViewController
        
        let annotation = view.annotation as! CustomPin?
//        var selectedUserID = annotation?.event?.creatorId
        
        let event = annotation?.event
        popUpPinVC.event = event
        
//        self.addChildViewController(popUpPinVC)
//        popUpPinVC.delegate = self
//        popUpPinVC.view.frame = self.view.frame
//
//        self.view.addSubview(popUpPinVC.view)
//        popUpPinVC.didMove(toParentViewController: self)
        
//        var user = User()
        
            FirebaseHelper.getUserData(userID: (annotation?.event?.creatorId)!, completionHandler: {
            userFromFirebase in
                if userFromFirebase.name != nil{
                    self.selectedUser = userFromFirebase
                }
            })
        
        self.addChildViewController(popUpPinVC)
        popUpPinVC.delegate = self
        popUpPinVC.view.frame = self.view.frame
        
        self.view.addSubview(popUpPinVC.view)
        popUpPinVC.didMove(toParentViewController: self)
        
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
    
    
//    //setar action do botao
//    @IBAction func addEvent(_ sender: Any) {
//    }
//    
    
    
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
//                    var locationOnView = press.location(in: self.mapView)
//
//                    let coordinate = self.mapView.convert(locationOnView, toCoordinateFrom: self.mapView)
//
//                    let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
//                    
//                    let northWest = mapView.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: mapView)
//                    
//                    let southEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: mapView.bounds.height), toCoordinateFrom: mapView)
//                    
//                    let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)
                    
                    let pin = CustomPin(coordinate: self.myLocation!)

                    pin.pinImage = UIImage(named: "mypin2")
                    
                    self.pins.append(pin)
                    
                    self.mapView.showsUserLocation = false
                    
                    let popUpOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "eventPopUp") as! EventViewController
                    
                    self.addChildViewController(popUpOverVC)
                    popUpOverVC.delegate = self
                    popUpOverVC.view.frame = self.view.frame
                    self.view.addSubview(popUpOverVC.view)
                    popUpOverVC.didMove(toParentViewController: self)
                    

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
    
    func sendEvent( preference : String) {
        
        
        let user = getUser()
        let location = Location(latitude: Float((self.myLocation?.latitude)!), longitude: Float((self.myLocation?.longitude)!))
        
        let event = Event(id: "", name: "teste", location: location, creatorId: user.id, creatorName: user.name, hora: getHour(), preference: preference)
        FirebaseHelper.saveEvent(event: event)
        
    }
    
    
    //MARK: - PinDelegate
    func transitionToProfile( id: String){
    
        let barViewControllers = self.tabBarController?.viewControllers
        let newViewController = barViewControllers![0] as! ProfileViewController
        if self.selectedUser != nil{
            newViewController.currentUser = self.selectedUser
        }
                
        tabBarController?.selectedIndex = 0
    }
    
    func transitionToChat( id: String){
        
        print("to indo")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let newViewController = storyboard.instantiateViewController(withIdentifier: "chatController") as! ChatController
        newViewController.chatId = id
        self.present(newViewController, animated: true, completion: nil)
    }
    
    //--------------------------------------
    
    @IBAction func addEventAction(_ sender: UIBarButtonItem) {
        
        self.mapView.showsUserLocation = false
        
        let popUpOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "eventPopUp") as! EventViewController
        
        self.addChildViewController(popUpOverVC)
        popUpOverVC.delegate = self
        popUpOverVC.view.frame = self.view.frame
        self.view.addSubview(popUpOverVC.view)
        popUpOverVC.didMove(toParentViewController: self)
        
    }
    

}

extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
        }, completion: nil)
    }
}
