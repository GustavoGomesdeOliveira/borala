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
    
    let containerView =  UIView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigation.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton.png"), style: .plain, target: self, action: #selector(self.backAction))
    }

    
    @IBAction func send(_ sender: UIButton) {
        
        let newMessage = UILabel(frame: CGRect(x: 100, y:  110, width: self.chatView.frame.width/2, height: 70))
        newMessage.backgroundColor = UIColor.red
        newMessage.text = "Messagem Um"
        newMessage.layer.cornerRadius = 30
        newMessage.layer.masksToBounds = true

        
        containerView.addSubview(newMessage)
        
        self.chatView.addSubview(containerView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.frame = CGRect(x: self.chatView.layer.position.x - 200, y: 100, width: chatView.contentSize.width, height: chatView.contentSize.height)
        containerView.layer.cornerRadius = 30
        //containerView.layer.masksToBounds = true
    }
    
    func backAction() -> Void {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        self.present(nextViewController, animated:true, completion:nil)
        
    }

    
}
