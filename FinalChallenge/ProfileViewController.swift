//
//  ProfileViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController, PopUpViewControllerDelegate {
    
    
    @IBOutlet weak var backRoundView: UIView!
    @IBOutlet weak var backUserView: UIView!
    @IBOutlet weak var backGenderView: UIView!
    @IBOutlet weak var backAgeView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!

    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var userGenderLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dislikeLabel: UILabel!
    
    @IBOutlet weak var friendListBtn: UIButton!
    
    
    var user: User!
    var currentUser: User?
    
    var tempIdLikeList = ["Teste", "Teste"]
    var tempIdDislikeList = ["Teste", "Teste"]


    override func viewDidLoad() {
        super.viewDidLoad()

        self.likeBtn.isHidden = false
        self.dislikeBtn.isHidden = false
        self.likeLabel.isHidden = false
        self.dislikeLabel.isHidden = false
        loadTotalOfLikeAndDislike()

        
        self.backRoundView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        self.backUserView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        
        self.backAgeView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        
        self.backGenderView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        if currentUser == nil{
            
            getUser()
            self.editButton.isEnabled = true
            self.editButton.tintColor = UIColor.white
            
            self.likeBtn.isHidden = true
            self.dislikeBtn.isHidden = true
            self.likeLabel.isHidden = true
            self.dislikeLabel.isHidden = true
            
        } else {
            
            self.friendListBtn.isHidden = true
            self.user = self.currentUser
            self.editButton.isEnabled = false
            self.editButton.tintColor = UIColor.clear
//            self.editButton.
            self.userNameLabel.text = user?.name
            let age = NSNumber(value: user.age!)
            self.userAgeLabel.text = age.stringValue
            self.userGenderLabel.text = user?.gender
            self.profileImage.image = UIImage(named: "profileImage")
            
            self.tempIdLikeList.append(user.id)
            
            if self.tempIdLikeList.contains(user.id) {
                
                self.likeBtn.isEnabled = false
                
            }
            
            if self.tempIdDislikeList.contains(user.id) {
                
                self.dislikeBtn.isEnabled = false
                
            }
            
//             print(currentUser?.name)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editProfile(_ sender: UIBarButtonItem) {
        
        let popUpOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editProfilePopUp") as! PopUpViewController
        
        self.addChildViewController(popUpOverVC)
        popUpOverVC.userToChange = self.user
        popUpOverVC.delegate = self
        popUpOverVC.view.frame = self.view.frame
        self.view.addSubview(popUpOverVC.view)
        popUpOverVC.didMove(toParentViewController: self)
        
    }
    
    
    func getUser(){
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            
            user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User
            
            self.userNameLabel.text = user?.name
            self.userGenderLabel.text = user?.gender
            
            self.profileImage.image = UIImage(data:(user?.pic)!,scale:1.0)
        }

    }
    
    func didUpdateUser() {
        
        self.getUser()
    }

    
    @IBAction func openChat(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let newViewController = storyboard.instantiateViewController(withIdentifier: "chatController")
        self.present(newViewController, animated: true, completion: nil)
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
        
        
            self.tempIdLikeList.append((self.currentUser?.id)!)
            self.tempIdDislikeList.remove(at: self.tempIdDislikeList.index(of: (self.currentUser?.id)!)!)
        
            FirebaseHelper.likeListAdd(id: (self.currentUser?.id)!)
        
            self.dislikeBtn.isEnabled = true
            self.likeBtn.isEnabled = false
            loadTotalOfLikeAndDislike()
        
        
    }
    
    @IBAction func dislikeUser(_ sender: Any) {
        
        
            self.tempIdDislikeList.append((self.currentUser?.id)!)
            self.tempIdLikeList.remove(at: self.tempIdLikeList.index(of: (self.currentUser?.id)!)!)
        
            FirebaseHelper.dislikeListAdd(id: (self.currentUser?.id)!)
        
            self.dislikeBtn.isEnabled = false
            self.likeBtn.isEnabled = true
            loadTotalOfLikeAndDislike()
            
    }
    
    func loadTotalOfLikeAndDislike() {
        
        self.likeLabel.text = String(self.tempIdLikeList.count)
        self.dislikeLabel.text = String(self.tempIdDislikeList.count)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.likeBtn.isHidden = false
        self.dislikeBtn.isHidden = false
        self.likeLabel.isHidden = false
        self.dislikeLabel.isHidden = false
        self.friendListBtn.isHidden = false

    }
    
    @IBAction func friendListSegue(_ sender: Any) {
        
        let barViewControllers = self.tabBarController?.viewControllers
        let newViewController = barViewControllers![3] as! FriendListController
        
        newViewController.friendList = [String]()
        
        newViewController.friendList?.append("teste")
        newViewController.friendList?.append("teste")
        newViewController.friendList?.append("teste")
        newViewController.friendList?.append("teste")
        newViewController.friendList?.append("teste")
        
        self.tabBarController?.selectedIndex = 3
        
    }
    

}

