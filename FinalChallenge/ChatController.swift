//
//  ChatController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 23/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class ChatController: UIViewController {
   
    @IBOutlet weak var chatView: UIScrollView!
    @IBOutlet weak var navigation: UINavigationBar!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigation.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton.png"), style: .plain, target: self, action: #selector(self.backAction))
    }

    
    @IBAction func send(_ sender: UIButton) {
        
        let newMessage = UILabel(frame: CGRect(x: self.chatView.frame.maxX, y: self.chatView.frame.maxY + 10, width: 20, height: 20))
        newMessage.backgroundColor = UIColor.red
        
        self.chatView.addSubview(newMessage)
        
        
    }
    
    func backAction() -> Void {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "chatList") as! ChatViewController
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
}
