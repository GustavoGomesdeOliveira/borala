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

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var facebookLoginBtn: FBSDKLoginButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        facebookLoginBtn.delegate = self
        facebookLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        
        if let token = FBSDKAccessToken.current(){
            
            fetchProfile()
            performSegue(withIdentifier: "segue", sender: nil)

        }
        
    }
    
    func fetchProfile(){
        
        let parameters = ["fields" : "email, first_name, last_name, picture.type(large), gender"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
        }
        
        
        
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        performSegue(withIdentifier: "segue", sender: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signIn(_ sender: UIButton) {
    }
    @IBAction func singUp(_ sender: UIButton) {
    }


}

