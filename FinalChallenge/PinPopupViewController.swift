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
    var event: Event?
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var eventScheduleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameLabel.text = event?.creatorName
        if let hora: String = event?.hora{
            print(hora)
            self.eventScheduleLabel.text = hora
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view == self.view {
            
            self.view.removeFromSuperview()

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
       // self.event.
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goToProfile(_ sender: UIButton) {
        delegate.transitionToProfile(id: (self.event?.creatorId)!)
    }
    @IBAction func goToChat(_ sender: UIButton) {
        delegate.transitionToChat(id: (self.event?.creatorId)!)
    }

}
