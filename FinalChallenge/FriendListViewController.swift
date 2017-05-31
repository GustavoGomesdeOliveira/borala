//
//  FriendListViewController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 30/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class FriendListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var friendList: [String]?
    
    override func viewDidLoad() {
        
        checkFriendList()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkFriendList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.friendList = nil
    }
    
    func checkFriendList(){
        
        if (friendList == nil){
            
            friendList = [String]()
            
            friendList?.append("teste")
            friendList?.append("teste")
            friendList?.append("teste")
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendCell
        
        cell.friendImage.image = #imageLiteral(resourceName: "profileImage")
        cell.friendName.text = "Teste"
        
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
        
        return (friendList?.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }

}
