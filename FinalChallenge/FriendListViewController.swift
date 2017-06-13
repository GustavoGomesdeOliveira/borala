//
//  FriendListViewController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 30/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class FriendListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var friendList = [ [String: Any] ]()
    var friendImageList = [UIImage]()
    var flagToReload = false
    var flagToRemove = true
    var flagToAppear = true
    var currentUser: User?

    
    @IBOutlet weak var friendTableView: UITableView!
    
    
    override func viewDidLoad() {
        flagToReload = true

    }
    
    
    func getfriends(){
        
        FirebaseHelper.getFriends(userId: (FirebaseHelper.firebaseUser?.uid)!, completionHandler: {
            friend in
            if let friend = friend{
                self.friendList.append(friend)
                print(friend["id"] as! String)
                FirebaseHelper.getPictureProfile(picAddress: friend["picUrl"] as! String, completitionHandler: {
                    picData in
                    if let picDataReceived = picData{
                        let friendIndex = self.friendList.index(where: {
                            ($0["picUrl"] as! String == friend["picUrl"] as! String)})
                        self.friendList[friendIndex!]["picData"] = picDataReceived
                        DispatchQueue.main.async {
                            if self.flagToReload {
                                sleep(1)

                                self.friendTableView.reloadData()
                            }
                            
                        }
                    }
                })
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        flagToRemove = false

//        if flagToAppear {
//            
//            getfriends()
//            
//            flagToAppear = !flagToAppear
//        }
        


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if flagToRemove {
            
            self.friendList.removeAll()
            self.friendImageList.removeAll()

            
        }
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendCell
        
        if let picData = self.friendList[indexPath.row]["picData"] as? Data{
            cell.friendImage.image = UIImage(data: picData)
            self.friendImageList.insert(UIImage(data: picData)!, at: indexPath.row)
        }
        cell.friendName.text = self.friendList[indexPath.row]["name"] as! String
        
        cell.mainBackground.layer.cornerRadius = 20
        cell.mainBackground.layer.masksToBounds = true
        
        cell.shadownLayer.layer.masksToBounds = false
        cell.shadownLayer.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.shadownLayer.layer.shadowColor = UIColor.black.cgColor
        cell.shadownLayer.layer.shadowOpacity = 0.23
        cell.shadownLayer.layer.shadowRadius = 4
        
        cell.shadownLayer.layer.shadowPath = UIBezierPath(roundedRect: cell.shadownLayer.bounds, byRoundingCorners: [UIRectCorner.allCorners], cornerRadii: CGSize(width: 8, height: 8)).cgPath
        cell.shadownLayer.layer.shouldRasterize = true
        cell.shadownLayer.layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(self.friendList.count)
        return self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        flagToRemove = false
        let friendId = friendList[indexPath.row]["id"] as! String
        
        FirebaseHelper.getUserData(userID: (friendId), completionHandler: {
            userFromFirebase in
            if userFromFirebase.name != nil{
                
                self.currentUser = userFromFirebase
            }
            
            
            let barViewControllers = self.tabBarController?.viewControllers
            let newViewController = barViewControllers![0] as! ProfileViewController
            
            newViewController.currentUser = self.currentUser
            self.currentUser?.pic = UIImagePNGRepresentation(self.friendImageList[indexPath.row])

            //newViewController. = self.friendImageList[indexPath.row]
            
            self.tabBarController?.selectedIndex = 0
        })
        
        
        
    }
    
    

}
