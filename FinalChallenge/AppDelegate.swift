//
//  AppDelegate.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Add any custom logic here.
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        //checkFacebookLogin()
        
        return true
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error{
            print(err)
        }
        
        print("Logged google", user.profile.name)
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

 
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FinalChallenge")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

//    func checkFacebookLogin(){
//        
//        if let token = FBSDKAccessToken.current(){
//            
//            DispatchQueue.main.async{
//                
//                let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
//                FIRAuth.auth()?.signIn(with: credential, completion: {
//                    user, error in
//                    if let _ = error{
//                        
//                        print(error.debugDescription)
//                    } else {
//                        DispatchQueue.main.async {
//                            FirebaseHelper.registerMeOnline()
//                        }
//                    }
//                })
//                
//                
//            }
//            
//            
//        }
//        
//    }
//    
//    func fetchProfile(id: String){
//        
//        let parameters = ["fields" : "email, first_name, last_name, picture.type(large), gender, id"]
//        
//        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
//            
//            if error != nil {
//                print(error!)
//                return
//            }
//            
//            let userDictionary = result! as! NSDictionary
//            
//            let picture = userDictionary["picture"] as! NSDictionary
//            
//            let data = picture["data"] as! NSDictionary
//            
//            print(userDictionary["picture"] as! NSDictionary)
//            
//            let name = (userDictionary["first_name"] as! String).appending(" ").appending(userDictionary["last_name"] as! String)
//            
//            let gender = userDictionary["gender"] as! String
//            
//            let facebookID = userDictionary["id"] as! String
//            
//            DispatchQueue.main.async {
//                self.getImageFromURL(url: data["url"] as! String, name: name, id: id, facebookID: facebookID, gender: gender)
//            }
//        }
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let viewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController;
//        
//        // Then push that view controller onto the navigation stack
//        let rootViewController = self.window!.rootViewController as! UINavigationController;
//        rootViewController.pushViewController(viewController, animated: true);
//        
//    }
//    
//    func getImageFromURL(url: String, name: String, id: String, facebookID: String, gender: String){
//        
//        let catPictureURL = URL(string: url)!
//        
//        
//        let session = URLSession(configuration: .default)
//        
//        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
//        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
//            // The download has finished.
//            if let e = error {
//                print("Error downloading cat picture: \(e)")
//            } else {
//                // No errors found.
//                // It would be weird if we didn't have a response, so check for that too.
//                if let res = response as? HTTPURLResponse {
//                    print("Downloaded cat picture with response code \(res.statusCode)")
//                    if let imageData = data {
//                        if let userData = UserDefaults.standard.object(forKey: "user") as? Data{
//                            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as! User
//                            if (imageData != user.pic){
//                                //save on firebase
//                                FirebaseHelper.saveProfilePic(userId: id, pic: imageData, completionHandler: nil)
//                            }
//                        }
//                        else{
//                            let user = User(withId: id, name: name, pic: imageData, facebookID: facebookID, gender: gender)
//                            let userData = NSKeyedArchiver.archivedData(withRootObject: user)
//                            UserDefaults.standard.set(userData, forKey: "user")
//                            FirebaseHelper.saveUser(user: user)
//                        }
//                    } else {
//                        print("Couldn't get image: Image is nil")
//                    }
//                } else {
//                    print("Couldn't get response code for some reason")
//                }
//            }
//        }
//        
//        downloadPicTask.resume()
//        
//    }



