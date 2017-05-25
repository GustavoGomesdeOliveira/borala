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
    
    var flagParaTeste = false
    var chatConversation: ChatConversation!
    
    let containerView =  UIView()
    
    
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigation.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton.png"), style: .plain, target: self, action: #selector(self.backAction))
        
        let stringArray = ["Teste", "Teste maior", "Teste maior ainda", "Teste maior que o anterior", "Teste maior de todos que meu deus que teste grande do caramba",]
    
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.messageTextField.delegate = self
        
        self.chatCollection.alwaysBounceVertical = true
        self.chatCollection.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        self.chatCollection.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        self.chatConversation = ChatConversation(message: stringArray)
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chatConversation.message.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ChatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! ChatMessageCell
        
        
        cell.textView.text = self.chatConversation.message[indexPath.row]
        
        setupCell(cell: cell)
        
        
//        if mensagem.id == FIRAuth.auth()?.currentUser?.uid {
//            
//        }
        
        
        cell.bubbleViewWidthAnchor?.constant = estimatedFrameForText(text: self.chatConversation.message[indexPath.row]).width + 20

        flagParaTeste = !flagParaTeste
        
        return cell
    }
    
    func setupCell(cell: ChatMessageCell){
        if flagParaTeste {
            
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
        let text = self.chatConversation.message[indexPath.row]
            
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
            
            let newMessage = self.messageTextField.text
            
            self.chatConversation.message.append(newMessage!)
            
            self.chatCollection.reloadData()
            
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
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
}
