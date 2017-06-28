//
//  PinPopupViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 25/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

protocol PinPopupViewControllerDelegate{
    
    func transitionToProfile( userId: String)
    func transitionToChat( id: String)
    
}

class PinPopupViewController: UIViewController {
    
    var delegate: PinPopupViewControllerDelegate!
    var event: Event!
    
    var userNotLogged = false
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var eventScheduleLabel: UILabel!

    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var MessageBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !userNotLogged {
            
            self.profileBtn.isHidden = true
            self.MessageBtn.isHidden = true
        }
        
        self.popupView.layer.masksToBounds = false
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOpacity = 0.8
        self.popupView.layer.shadowOffset = CGSize(width: 1, height: 15)
        self.popupView.layer.shadowRadius = 15
        
        self.popupView.layer.shadowPath = UIBezierPath(rect: self.popupView.bounds).cgPath
        self.popupView.layer.shouldRasterize = true
        
        self.userNameLabel.text = event?.creatorName
        self.userImageView.image = UIImage(named: (event?.preference)!)
        
        self.makeTimeLabel(eventBegin: (event?.beginHour)!, eventEnd: (event?.endHour)!)
        
//        if let hora: String = event?.endHour{
//
//            self.eventScheduleLabel.text = hora
//        }
        
    }
    
    func makeTimeLabel(eventBegin: Date, eventEnd: Date){
        
        let date = Date(timeIntervalSince1970: 1498651384.56429)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        print(dateFormatter.string(from: date))
        
        self.eventScheduleLabel.text = dateFormatter.string(from: eventBegin) + " - " + dateFormatter.string(from: eventEnd)
            
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view == self.view {
            
            self.view.removeFromSuperview()

        }
    }
    

    @IBAction func goToProfile(_ sender: UIButton) {
        delegate.transitionToProfile(userId: self.event.creatorId)
    }
    
    @IBAction func goToChat(_ sender: UIButton) {
        FirebaseHelper.createChat(partnerId: self.event.creatorId, completionHandler: {
            chatId in
            if let chatIdCreated = chatId{
                self.delegate.transitionToChat(id: chatIdCreated)
            }
        })
    }

}
