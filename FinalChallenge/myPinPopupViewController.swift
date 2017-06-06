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

    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
 
    @IBOutlet weak var eventScheduleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.myView.layer.masksToBounds = false
        self.myView.layer.shadowColor = UIColor.black.cgColor
        self.myView.layer.shadowOpacity = 0.8
        self.myView.layer.shadowOffset = CGSize(width: 1, height: 15)
        self.myView.layer.shadowRadius = 15
        
        self.myView.layer.shadowPath = UIBezierPath(rect: self.myView.bounds).cgPath
        self.myView.layer.shouldRasterize = true
        
        
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
