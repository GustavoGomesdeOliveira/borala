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
import FirebaseMessaging
import GoogleSignIn
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var facebookFriendsID = [String]()


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        UINavigationBar.appearance().isTranslucent = true
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        
        FIRApp.configure()
        FIRMessaging.messaging().remoteMessageDelegate = self
        FirebaseHelper.observerUser()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        if UserDefaults.standard.data(forKey: "user") != nil{
            
            if !checkFacebookLogin(){
                
                
                GIDSignIn.sharedInstance().signInSilently()
                
                
            }
        }
        
        return true
        
    }
    
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //self.enableRemoteNotificationFeatures()
        //send token to firebase
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        print("registrou \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
        //self.disableRemoteNotificationFeatures()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Message ID: \(userInfo["gcm_message_id"])")
        print(userInfo)
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
    
    
    
    func checkFacebookLogin() -> Bool{
        
        var logged = false
        
        if let token = FBSDKAccessToken.current(){
            
            logged = true
            saveFacebookFriends()
            
            DispatchQueue.main.async{
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
                FIRAuth.auth()?.signIn(with: credential, completion: {
                    user, error in
                    if let _ = error{
                        
                    } else {
                        FirebaseHelper.registerMeOnline()
                        self.saveFacebookFriends()
                    }
                })
                
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController;
            
            self.window?.rootViewController = viewController
            
        }
        
        return logged
        
    }
    
    func checkGoogleLogin(){
        
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            
            let token = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            
            
            DispatchQueue.main.async{
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: token!)
                FIRAuth.auth()?.signIn(with: credential, completion: {
                    user, error in
                    if let _ = error{
                        
                        print(error.debugDescription)
                    } else {
                        DispatchQueue.main.async {
                            FirebaseHelper.registerMeOnline()
                        }
                    }
                })
                
                
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController;
            
            self.window?.rootViewController = viewController
            
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
            
            
            let name = (userDictionary["first_name"] as! String).appending(" ").appending(userDictionary["last_name"] as! String)
            
            let gender = userDictionary["gender"] as! String
            
            let facebookID = userDictionary["id"] as! String
            
            DispatchQueue.main.async {
                self.getImageFromURL(url: data["url"] as! String, name: name, id: id, facebookID: facebookID, gender: gender)
            }
        }
        saveFacebookFriends()
        
        
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
                            let user = User(withId: id, name: name, pic: imageData, socialNetworkID: facebookID, gender: gender)
                            let userData = NSKeyedArchiver.archivedData(withRootObject: user)
                            UserDefaults.standard.set(userData, forKey: "user")
                            FirebaseHelper.saveUser(user: user)
        

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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error{
            print(err)
            return
        }
        
        if UserDefaults.standard.data(forKey: "user") != nil{
            
            checkGoogleLogin()

        } else {
           
            let authentication = user.authentication
            let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
            FIRAuth.auth()?.signIn(with: credential, completion: {
                firebaseUser, error in
                if error != nil{
                    print("error to authentice with google \(String(describing: error))")
                    return
                }
                if user.profile.hasImage {
                    
                    self.getImageFromGoogle(catPictureURL: user.profile.imageURL(withDimension: 1), name: user.profile.name, id: (firebaseUser?.uid)!, facebookID: user.userID, gender: "")
                    
                } else {
                    
                    let url = URL(fileURLWithPath: "")
                    
                    self.getImageFromGoogle(catPictureURL: url , name: user.profile.name, id: "", facebookID: user.userID, gender: "")
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let viewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController;
                
                self.window?.rootViewController = viewController
            })
            
            
            
            
        }
     
        
    }
    
    func getImageFromGoogle(catPictureURL: URL, name: String, id: String, facebookID: String, gender: String){
        
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
                            
                        } else{
                            let user = User(withId: id, name: name, pic: imageData, socialNetworkID: facebookID, gender: gender)
                            let userData = NSKeyedArchiver.archivedData(withRootObject: user)
                            UserDefaults.standard.set(userData, forKey: "user")
                            FirebaseHelper.saveUser(user: user)
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
    
    func saveFacebookFriends(){
        
        var friendList = [String]()
        
        DispatchQueue.global(qos: .background).async {
            
            
            let parameters = ["fields": "name"]
            
            
            FBSDKGraphRequest(graphPath: "me/friends", parameters: parameters).start { (connection, result, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                let data = result as! NSDictionary
                
                
                for friends in data["data"] as! NSArray{
                    friendList.append((friends as! NSDictionary)["id"]! as! String)
                    FirebaseHelper.saveFriend(socialnetworkId: (friends as! NSDictionary)["id"]! as! String)
                }
                
                let friendListData = NSKeyedArchiver.archivedData(withRootObject: friendList)
                UserDefaults.standard.set(friendList, forKey: "friendList")

                
            }
            
        }
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
   
}
// [END ios_10_message_handling]

extension AppDelegate: FIRMessagingDelegate{
    // [START refresh_token]
    func messaging(_ messaging: FIRMessaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        connectToFcm()
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: FIRMessaging, didReceive remoteMessage: FIRMessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    //The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    // [END ios_10_data_message]
}
