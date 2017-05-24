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
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
    }
    
    @IBAction func send(_ sender: UIButton) {
        
        let newMessage = UILabel(frame: CGRect(x: self.chatView.frame.maxX, y: self.chatView.frame.maxY + 10, width: 20, height: 20))
        newMessage.backgroundColor = UIColor.red
        
        self.chatView.addSubview(newMessage)
        
    }
    
    
}
