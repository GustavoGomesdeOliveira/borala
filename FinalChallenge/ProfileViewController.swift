//
//  ProfileViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController, PopUpViewControllerDelegate, SettingsLauncherDelegate {
    
    
    @IBOutlet weak var backRoundView: UIView!
    @IBOutlet weak var backUserView: UIView!
 
    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var userGenderLabel: UILabel!
    @IBOutlet weak var addFriendBtn: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dislikeLabel: UILabel!
    
    @IBOutlet weak var friendListBtn: UIButton!
    let settingsLauncher = SettingsLauncher()
    
    var friendListUserDefaults = [String]()
    
    var likeList = [String]()
    var dislikeList = [String]()
    
    var user: User!
    var currentUser: User?
    
    var friendList = [[String: Any]]()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.likeBtn.isHidden = false
        self.dislikeBtn.isHidden = false
        self.likeLabel.isHidden = false
        self.dislikeLabel.isHidden = false
        self.friendListBtn.isHidden = true
        
        self.backRoundView.layer.borderColor = UIColor(red: 167/255, green: 36/255, blue: 76/255, alpha: 1).cgColor
                
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if currentUser == nil{
            
            self.chatButton.isHidden = true
            self.user = getUser()
            setUserInterface()
            self.editButton.isEnabled = true
            self.editButton.isHidden = false
            self.likeBtn.isHidden = true
            self.likeLabel.isHidden = true
            self.likeLabel.isHidden = true
            self.dislikeBtn.isHidden = true
            self.dislikeLabel.isHidden = true
            self.likeLabel.isEnabled = false

            
        } else {
            
            //self.friendListBtn.isHidden = true
            self.user = self.currentUser
            setUserInterface()
            self.editButton.isEnabled = false
            self.editButton.isHidden = true
            self.chatButton.isHidden = false

            self.userNameLabel.text = user?.name
            if user.age! >= 0 {
                let age = NSNumber(value: user.age!)
                self.userAgeLabel.text = age.stringValue
            }else{
                self.userAgeLabel.text = ""
            }
            self.userGenderLabel.text = user?.gender
            
            
            if (user.likeIds != nil) {
                

                for likes in user.likeIds!{
                    
                    self.likeList.append(likes.key)
                }
                
                if (likeList.contains((FirebaseHelper.firebaseUser?.uid)!)){
                    
                    self.likeBtn.isEnabled = false
                }
            }
            
            if (user.dislikeIds != nil) {
                
                
                for dislikes in user.dislikeIds!{
                    
                    self.dislikeList.append(dislikes.key)
                }
                
                if (dislikeList.contains((FirebaseHelper.firebaseUser?.uid)!)){
                    
                    self.dislikeBtn.isEnabled = false
                }
                
            }

            loadTotalOfLikeAndDislike()
            getFriendList()
        }
        
    }
    
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        
        let popUpOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editProfilePopUp") as! PopUpViewController

        self.addChildViewController(popUpOverVC)
        popUpOverVC.userToChange = self.user
        popUpOverVC.delegate = self
        popUpOverVC.view.frame = self.view.frame
        self.view.addSubview(popUpOverVC.view)
        popUpOverVC.didMove(toParentViewController: self)

    }
    
    
    func getUser() -> User{
        
        var userToReturn: User!
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            
            userToReturn = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User
            
        }
        
        return userToReturn

    }

    func getFriendList(){
        
        let defaults = UserDefaults.standard
        
        let friendDefaults = defaults.object(forKey: "friendList")
        
        if friendDefaults != nil {
            
            for friend in (friendDefaults as! [String]) {
                
                self.friendListUserDefaults.append(friend)

            }

        }
        
        if !friendListUserDefaults.contains(user.socialNetworkID) {
            
            self.addFriendBtn.isHidden = false
            
        }
        
        
    }
    
    func setUserInterface(){
        
        self.userNameLabel.text = user?.name
        self.userGenderLabel.text = user?.gender
        
        if self.user.age != nil {
            
            let ageString = String(describing: user.age!)
            
            self.userAgeLabel.text = ageString
        } else {
            
            self.userAgeLabel.text = ""
        }
        
        if self.user.pic == nil {
            
            self.profileImage.image = UIImage(named: "profileImage")
        } else {
            
            self.profileImage.image = UIImage(data:(user?.pic)!,scale:1.0)
        }
        
    }
    
    func didUpdateUser() {
        
        self.user = self.getUser()
        setUserInterface()
    }

    
    @IBAction func openChat(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let newViewController = storyboard.instantiateViewController(withIdentifier: "chatController") as! ChatController
        if let creatorId = self.currentUser?.id{
            FirebaseHelper.createChat(partnerId: creatorId, completionHandler: {
                chatId in
                if let chatIdCreated = chatId{
                    newViewController.chatId = chatIdCreated
                    DispatchQueue.main.async {
                        self.present(newViewController, animated: true, completion: nil)
                    }
                }
            })
        }
        else{
            FirebaseHelper.createChat(partnerId: user.id, completionHandler: {
                chatId in
                if let chatIdCreated = chatId{
                    newViewController.chatId = chatIdCreated
                    DispatchQueue.main.async {
                        self.present(newViewController, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 80
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height - 80
            }
        }
    }
    
    
    @IBAction func likeUser(_ sender: Any) {
        
        self.likeList.append( (FirebaseHelper.firebaseUser?.uid)! )
        self.dislikeList = self.dislikeList.filter{ $0 != FirebaseHelper.firebaseUser?.uid}
        
        FirebaseHelper.likeListAdd(id: self.user.id)
        
        self.dislikeBtn.isEnabled = true
        self.likeBtn.isEnabled = false
        loadTotalOfLikeAndDislike()
    }
    
    @IBAction func dislikeUser(_ sender: Any) {
        
        self.dislikeList.append((FirebaseHelper.firebaseUser?.uid)!)
        self.likeList = self.likeList.filter{ $0 != FirebaseHelper.firebaseUser?.uid }
        
        FirebaseHelper.dislikeListAdd(id: self.user.id)
        
        self.dislikeBtn.isEnabled = false
        self.likeBtn.isEnabled = true
        loadTotalOfLikeAndDislike()
            
    }
    
    func loadTotalOfLikeAndDislike() {
        
        let like = self.likeList.count
        
        let dislike =  self.dislikeList.count
        
        self.likeLabel.text = String(describing: like)
        self.dislikeLabel.text = String(describing: dislike)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.likeBtn.isHidden = false
        self.dislikeBtn.isHidden = false
        self.likeLabel.isHidden = false
        self.dislikeLabel.isHidden = false
        //self.friendListBtn.isHidden = false
        self.likeBtn.isEnabled = true
        self.dislikeBtn.isEnabled = true
        self.likeList = []
        self.dislikeList = []
        self.currentUser = nil
        self.addFriendBtn.isHidden = true


    }
    //teste
    
    @IBAction func friendListSegue(_ sender: Any) {
        
        let barViewControllers = self.tabBarController?.viewControllers
        let newViewController = barViewControllers![3] as! FriendListController
        
        newViewController.friendList = [[String: Any]]()
        newViewController.currentUser = self.currentUser
        
        self.tabBarController?.selectedIndex = 3
        
    }
    
    @IBAction func addFriend(_ sender: Any) {
        
        self.addFriendBtn.isHidden = true

        FirebaseHelper.saveFriend(socialnetworkId: user.socialNetworkID)

        self.friendListUserDefaults.append(user.socialNetworkID)
        
        UserDefaults.standard.set(friendListUserDefaults, forKey: "friendList")
        
    }
    
    @IBAction func menuAction(_ sender: Any) {
        
        settingsLauncher.parentview = self.view
        settingsLauncher.delegate = self
        settingsLauncher.tabBarheight = (self.tabBarController?.tabBar.frame.height)!
        settingsLauncher.showSettings()
        
    }
    
    func showControllerForSetting(setting: Setting){
        

        
    }
    
    
    
}

