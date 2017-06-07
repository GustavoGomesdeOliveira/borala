//
//  ChatViewController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 23/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var chatTableView: UITableView!
    
    var flagToReload = false
    var chats = [Chat](){
        willSet{
            if !newValue.isEmpty{
                FirebaseHelper.getPicToChat(chatId: (newValue.last?.id)!, completionHandler: {
                    picData in
                    if let picData = picData{
                        newValue.last?.pic = picData
                        DispatchQueue.main.async {
                            self.chatTableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        self.chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseHelper.getChats(completionHandler: {
            chatFromFirebase in
            let newChat = self.chats.filter{ $0.id == chatFromFirebase.id}
            if newChat.isEmpty{ self.chats.append(chatFromFirebase)}
            else{
                self.chats = self.chats.filter{$0.id != chatFromFirebase.id}
                self.chats.append(chatFromFirebase)
            }
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseHelper.removeChatObserver()
        self.chats.removeAll()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! CustomChatCell
        if let picData = self.chats[indexPath.row].pic{
            cell.personImage.image = UIImage.init(data: picData )
        }
        cell.personName.text = self.chats[indexPath.row].lastMessage.text
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "chatController") as! ChatController
        chatViewController.chatId = self.chats[indexPath.row].id
        self.present(chatViewController, animated: true, completion: nil)
        
    }
}
