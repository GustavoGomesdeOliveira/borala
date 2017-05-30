//
//  myPinPopupViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 30/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit


protocol myPinPopupViewControllerDelegate{
    
    func cancelEvent( id: String)
    
}


class myPinPopupViewController: UIViewController {
    
    var delegate: myPinPopupViewControllerDelegate!
    var event: Event!

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
 
    @IBOutlet weak var eventScheduleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameLabel.text = event?.creatorName
        if let hora: String = event?.hora{
            //            print(hora)
            self.eventScheduleLabel.text = hora
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch? = touches.first
        if touch?.view == self.view {
            self.view.removeFromSuperview()
        }
        
    }
    
    @IBAction func cancelEventAction(_ sender: UIButton) {
        self.delegate.cancelEvent(id: self.event.id)
    }
    
}
