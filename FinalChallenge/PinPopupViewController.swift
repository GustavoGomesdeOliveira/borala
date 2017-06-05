//
//  PinPopupViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 25/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

protocol PinPopupViewControllerDelegate{
    
    func transitionToProfile( id: String)
    func transitionToChat( id: String)
    
}

class PinPopupViewController: UIViewController {
    
    var delegate: PinPopupViewControllerDelegate!
    var event: Event!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var eventScheduleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameLabel.text = event?.creatorName
        self.userImageView.image = UIImage(named: (event?.preference)!)
        if let hora: String = event?.hora{

            self.eventScheduleLabel.text = hora
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view == self.view {
            
            self.view.removeFromSuperview()

        }
    }
    

    @IBAction func goToProfile(_ sender: UIButton) {
        delegate.transitionToProfile(id: (self.event?.creatorId)!)
    }
    
    @IBAction func goToChat(_ sender: UIButton) {
        FirebaseHelper.createChat(event: self.event, completionHandler: {
            chatId in
            if let chatIdCreated = chatId{
                self.delegate.transitionToChat(id: chatIdCreated)
            }
        })
    }

}
