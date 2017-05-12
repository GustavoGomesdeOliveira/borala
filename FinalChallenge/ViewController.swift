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
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FIRAuth.auth()?.signIn(with: credential, completion: {
                user, error in
                if let _ = error{
                    
                    print(error.debugDescription)
                } else {
                    DispatchQueue.main.async {
                        FirebaseHelper.registerMeOnline()
                        self.performSegue(withIdentifier: "segue", sender: nil)
                    }
                }
            })
        }
        
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
            
            print(userDictionary["picture"] as! NSDictionary)
            
            let name = (userDictionary["first_name"] as! String).appending(" ").appending(userDictionary["last_name"] as! String)
            
            let gender = userDictionary["gender"] as! String
            
            let facebookID = userDictionary["id"] as! String
            
            DispatchQueue.main.async {
                self.getImageFromURL(url: data["url"] as! String, name: name, id: id, facebookID: facebookID, gender: gender)
                
                
            }
        }
        
        self.performSegue(withIdentifier: "segue", sender: nil)

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
                        if let userData = UserDefaults.standard.object(forKey: "user") as? Data{
                            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as! User
                            if (imageData != user.pic){
                                //save on firebase
                                FirebaseHelper.saveProfilePic(userId: id, pic: imageData, completionHandler: nil)
                            }
                        }
                        else{
                            let user = User(withId: id, name: name, pic: imageData, facebookID: facebookID, gender: gender)
                            let userData = NSKeyedArchiver.archivedData(withRootObject: user)
                            UserDefaults.standard.set(userData, forKey: "user")
                            FirebaseHelper.saveProfilePic(userId: id, pic: imageData, completionHandler: nil)
                            FirebaseHelper.saveString(path: "users/\(id)/name/username", object: name, completionHandler: nil)
                        }
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
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func start(_ sender: UIButton) {
        performSegue(withIdentifier: "segue", sender: nil)
        
    }


}

