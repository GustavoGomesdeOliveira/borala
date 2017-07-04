//
//  ChatController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 23/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class ChatController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
   
    @IBOutlet weak var navigation: UINavigationBar!
    @IBOutlet weak var chatCollection: UICollectionView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var messageTextField: UITextField!
    
    var chatConversation: ChatConversation!
    
    var chatId: String!
    var personImage = Data()
    var messages = [Message]()
    var keyBoardHeight: CGFloat!
    let containerView =  UIView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.navigation.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Back",style: .plain, target:self, action: #selector(self.backAction))
    
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.messageTextField.delegate = self
        
        self.chatCollection.alwaysBounceVertical = true
        self.chatCollection.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        self.chatCollection.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.keyBoardHeight = CGFloat()
        self.keyBoardHeight = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatController.handleTap))
        tap.numberOfTapsRequired = 1
        self.chatCollection.addGestureRecognizer(tap)
        if personImage == UIImagePNGRepresentation(#imageLiteral(resourceName: "profileImage")){
            FirebaseHelper.getPicToChat(chatId: chatId, completionHandler: {
                data in
                if let imageData = data{
                    self.personImage = imageData
                    DispatchQueue.main.async {
                        self.chatCollection.reloadData()
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseHelper.messageWasAdded(chatId: self.chatId, completionHandler: {
            messageFromFirebase in
            self.messages.append(messageFromFirebase)
            DispatchQueue.main.async {
                self.chatCollection.reloadData()
            }
            
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let path = IndexPath(row: self.messages.count - 1, section: 0)
        
        if path.row != -1 {
            
            self.chatCollection.scrollToItem(at: path,  at: UICollectionViewScrollPosition.top, animated: true)

        }
        
   
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseHelper.removeMessagesObserver(chatId: chatId)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ChatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! ChatMessageCell
        
        let currentMessage = self.messages[indexPath.row]
        cell.textView.text = currentMessage.text
        cell.profileImageChat.image = UIImage(data: self.personImage)
        setupCell(cell: cell, senderId: currentMessage.senderId)
        
        cell.bubbleViewWidthAnchor?.constant = estimatedFrameForText(text: self.messages[indexPath.row].text).width + 20
        
        return cell
    }
    
    func setupCell(cell: ChatMessageCell, senderId: String){
        if senderId == FirebaseHelper.firebaseUser?.uid {
            
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.profileImageChat.isHidden = true

        } else {
            
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = UIColor.black
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            cell.profileImageChat.isHidden = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Default value
        var heigth: CGFloat = 80
        
        //Get value from text
        let text = self.messages[indexPath.row].text
            
        heigth = estimatedFrameForText(text: text).height + 20
        
        return CGSize(width: self.chatCollection.frame.width, height: heigth)
        
    }
    
    private func estimatedFrameForText(text: String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    @IBAction func send(_ sender: UIButton) {
        
        handleMessage()
    
    }
    
    func handleMessage(){
        
        if (messageTextField.text?.characters.count)! > 0{
            
            let textMessage = self.messageTextField.text
            let newMessage = Message(senderId: (FirebaseHelper.firebaseUser?.uid)!, senderName: (FirebaseHelper.firebaseUser?.displayName)!, text: textMessage!)
            FirebaseHelper.saveMessage(chatId: self.chatId, message: newMessage)
            
            DispatchQueue.main.async {
                
                self.chatCollection.reloadData()
                
                let path = IndexPath(row: self.messages.count - 1, section: 0)
                
                if path.row != -1 {
                    
                    self.chatCollection.scrollToItem(at: path,  at: UICollectionViewScrollPosition.bottom, animated: true)
                    
                }
                
                

            }
            
            
            self.messageTextField.text = nil
        }
    }
    
    func backAction() -> Void {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleMessage()
        
        textField.resignFirstResponder()
        return true
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                self.keyBoardHeight = keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                self.keyBoardHeight = 0.0
            }
        }
    }

    func handleTap(){
        
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += self.keyBoardHeight
            self.keyBoardHeight = 0.0
            self.view.endEditing(true)
        }
        
    }
    
//    func viewScroll() {
//        let lastItem = self.chatCollection.numberOfItems(inSection: 0)-1
//            //collectionView(self.chatCollection!, numberOfItemsInSection: 0)-1
////        (self.chatCollection!, numberOfRowsInSection: 0) - 1
//        let indexPath: NSIndexPath = NSIndexPath.init(item: lastItem, section: 0)
//        self.chatCollection.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: false)
////        scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
//    }
    
}
