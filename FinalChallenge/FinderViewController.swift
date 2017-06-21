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


class FinderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate,UIPopoverPresentationControllerDelegate,EventViewControllerDelegate, PinPopupViewControllerDelegate, myPinPopupViewControllerDelegate {
    
    
    var facebookFriendsID = [String]()
    let settingsLauncher = SettingsLauncher()

    @IBOutlet weak var notLoggedView: UIView!
    @IBOutlet weak var facebookLoginBTN: FBSDKLoginButton!
    
    @IBOutlet weak var newEvent: UIButton!
   
    
    var pin: CustomPin?
    var myAnnotation: CustomPin?
    var selectedUserID: String?
    var mapItem: (map: MKMapItem, pin: CustomPin)? = nil
    var selectedAnnotation: CustomPin?
    var findEvent: Bool = false
    
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
    var searchPins = [CustomPin]()
    var myID: String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let barViewControllers = self.tabBarController?.viewControllers
        let newViewController = barViewControllers![0] as! ProfileViewController
        
        if self.selectedUser != nil{
            newViewController.currentUser = nil
        }

        DispatchQueue.main.async {
            
            self.loadFriends()

        }
        
        
    }

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
        
        facebookLoginBTN.delegate = self
        
        facebookLoginBTN.readPermissions = ["public_profile", "email", "user_friends"]
        self.notLoggedView.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self

        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            
            self.notLoggedView.isHidden = true

        }
        
        
        //let user = getUser()
        //self.myID = user.id

 //getting events
        FirebaseHelper.getEvents(completionHandler: {
            eventsFromFirebase in
            self.events = eventsFromFirebase
            self.pins.removeAll()
            
            
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
                    self.pins.append(eventPin)
                }
                else{
                    //this is my event
//                    eventExist = true
                    self.findEvent = true
//                    self.mapView.showsUserLocation = false
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(event.location.latitude), longitude: CLLocationDegrees(event.location.longitude))
                    let myPin = CustomPin(coordinate: coordinate)
                    myPin.title = "teste"
                    myPin.pinImage = UIImage(named: "mypin2")
                    myPin.event = event
                    self.pins.append(myPin)
                    self.searchPins.append(myPin)

                }
            }
            
            if self.findEvent == true {
                //ele achou o evento
                self.newEvent.isEnabled = false
                self.newEvent.tintColor = UIColor.white
                self.findEvent = false
//                self.mapView.showsUserLocation = false
            }else{
                //n existe evento
                self.newEvent.isEnabled = true
                self.newEvent.tintColor = UIColor(red: 167/255, green: 36/255, blue: 76/255, alpha: 1)
//                UIColor(red: 167/255, green: 36/255, blue: 76/255, alpha: 1).cgColor
            }
            
            
            self.mapView.addAnnotations(self.pins)
        })
        //-----------------------------------------
        
    }
    
    func loadFriends(){
        let barViewControllers = self.tabBarController?.viewControllers
        let newViewController = barViewControllers![3] as! FriendListController
        
        newViewController.getfriends()
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // This *forces* a popover to be displayed on the iPhone
        return .none
    }
    
    // MARK: - CoreLocation

     //Updating user location on the mapView
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.myLocation = locations.first?.coordinate
        
        let distanceSpan: CLLocationDegrees = 120

        
        let myRegion = MKCoordinateRegionMakeWithDistance(myLocation!, distanceSpan, distanceSpan)
        
        self.mapView.setRegion(myRegion, animated: true)
       
        
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
            annotationView?.isEnabled = false
            
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
        
        self.selectedAnnotation = view.annotation as! CustomPin?
        
        let annotation = view.annotation as! CustomPin?
        let event = annotation?.event
        
        if event?.creatorId == myID {
            let popUpPinVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myPinPopup") as! myPinPopupViewController
            popUpPinVC.event = event
            self.addChildViewController(popUpPinVC)
            popUpPinVC.delegate = self
            popUpPinVC.view.frame = self.view.frame
            
            self.view.addSubview(popUpPinVC.view)
            popUpPinVC.didMove(toParentViewController: self)
            
        }else{
            let popUpPinVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinPopup") as! PinPopupViewController
            
            let hide = self.tabBarController?.tabBar.isUserInteractionEnabled
            
            
            popUpPinVC.userNotLogged = hide!
            popUpPinVC.event = event
            
            DispatchQueue.main.async {
                
                FirebaseHelper.getUserData(userID: (annotation?.event?.creatorId)!, completionHandler: {
                    userFromFirebase in
                    if userFromFirebase.name != nil{
                        self.selectedUser = userFromFirebase
                    }
                    
                    FirebaseHelper.getPictureProfile(picAddress: (self.selectedUser?.picUrl)!, completitionHandler: {
                        
                        imageFromFirebase in
                        
                        if let imageReceived = imageFromFirebase{
                            
                            self.selectedUser?.pic = imageReceived

                        }
                        
                    })
                })
                
            }
            

            self.addChildViewController(popUpPinVC)
            popUpPinVC.delegate = self
            popUpPinVC.view.frame = self.view.frame
            
            self.view.addSubview(popUpPinVC.view)
            popUpPinVC.didMove(toParentViewController: self)
            }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
            
        self.notLoggedView.isHidden = true
        if let token = result.token{

            self.tabBarController?.tabBar.isUserInteractionEnabled = true


            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FIRAuth.auth()?.signIn(with: credential, completion: {
                user, error in
                if let _ = error{
                    
                    print(error.debugDescription)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        //appDelegate.fetchProfile(id: (user?.uid)!)
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
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = true


    }
    
    
    func addMyPoint(press : UIGestureRecognizer) {
        
//        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
//            print("tem")
//        }
        
        if ((FBSDKAccessToken.current() == nil) && (!GIDSignIn.sharedInstance().hasAuthInKeychain())){
            
            self.notLoggedView.isHidden = false
            
        } else {
            
            if press.state == .began{

                if event == false{

                    
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
    
//    func getHour() -> String{
//        
//        let date = Date()
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        
////        print("Dateobj: \(dateFormatter.string(from: date))")
//        
//        return dateFormatter.string(from: date)
//        
//    }
    
    
    func getUser() -> User?{
        
        guard let userData = UserDefaults.standard.data(forKey: "user") else{
            return nil
        }
        return (NSKeyedUnarchiver.unarchiveObject(with: userData) as? User)!
    }
    
    func sendEvent( beginHour: Date, endHour: Date, preference : String, description: String?) {
        
        if let user = getUser(){
            let location = Location(latitude: Float((self.myLocation?.latitude)!), longitude: Float((self.myLocation?.longitude)!))
        
            let event = Event(name: "teste", location: location, creatorId: user.id, creatorName: user.name, beginHour: beginHour, endHour: endHour, preference: preference, description: description)
            FirebaseHelper.saveEvent(event: event)
        }
        
    }
    
    
    //MARK: - PinDelegate
    func transitionToProfile( userId: String ){
    
        let barViewControllers = self.tabBarController?.viewControllers
        let newViewController = barViewControllers![0] as! ProfileViewController
        if let _ = self.selectedUser{
            newViewController.currentUser = self.selectedUser
        }
        tabBarController?.selectedIndex = 0
    }
    
    func transitionToChat( id: String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let newViewController = storyboard.instantiateViewController(withIdentifier: "chatController") as! ChatController
        newViewController.chatId = id
        self.present(newViewController, animated: true, completion: nil)
    }
    
    //--------------------------------------
    
    // mypin Delegate
    
    func cancelEvent( id: String){
        self.mapView.deselectAnnotation(self.selectedAnnotation, animated: false)
        FirebaseHelper.deleteEvent(eventId: id)
        print("fazer alguma coisa")
    }
    
    @IBAction func menuAction(_ sender: Any) {
        
        settingsLauncher.showSettings()
        
    }

    
    @IBAction func addEventAction(_ sender: UIButton) {
        
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
