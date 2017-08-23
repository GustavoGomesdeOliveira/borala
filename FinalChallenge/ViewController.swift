//
//  ViewController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    var userNotLogged = false
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    
    @IBOutlet weak var facebookLoginBtn: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        facebookLoginBtn.delegate = self
        facebookLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
    }

    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
        if let token = result.token{
       
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FIRAuth.auth()?.signIn(with: credential, completion: {
                user, error in
                if let _ = error{
                    
                    print(error.debugDescription)
                    
                } else {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.fetchProfileFromFacebook(completionHandler: {
                        userDictionary in
                        let picture = userDictionary["picture"] as! NSDictionary
                        let data = picture["data"] as! NSDictionary
                        let picURL = data["url"] as! String
                        let gender = userDictionary["gender"] as! String
                        let facebookID = userDictionary["id"] as! String
                        appDelegate.getImageFromURL(url: picURL, completionHandler: {
                            picData in
                            let newUser = User(withId: (user?.uid)!, name: user?.displayName, pic: picData, socialNetworkID: facebookID, gender: gender, notificationToken: appDelegate.FMCToken!)
                            appDelegate.saveFacebookFriends()
                            FirebaseHelper.saveUser(user: newUser, completionHandler: {
                                error in
                                if error == nil{
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "segue", sender: nil)
                                    }
                                }
                            })
                            let userData = NSKeyedArchiver.archivedData(withRootObject: newUser)
                            UserDefaults.standard.set(userData, forKey: "user")
                            UserDefaults.standard.set(Search.Everyone.rawValue, forKey: "search")
                        })
                    })
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func start(_ sender: UIButton) {
        self.userNotLogged = true
        performSegue(withIdentifier: "segue", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if !(segue.identifier == "showTerms") {
            
            let destination = segue.destination as! TabBarViewController
            
            destination.userNotLogged = self.userNotLogged
            
        }
        
        
    }
    
    @IBAction func showTerm(_ sender: Any) {
        
        performSegue(withIdentifier: "showTerms", sender: nil)
        
        
    }

}

