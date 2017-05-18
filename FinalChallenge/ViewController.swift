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
                    
                    DispatchQueue.main.async {
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate

                        appDelegate.fetchProfile(id: (user?.uid)!)
                    }
                }
            })
            self.performSegue(withIdentifier: "segue", sender: nil)

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
        performSegue(withIdentifier: "segue", sender: nil)
        
    }


}

