//
//  PinsTableViewCell.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 22/06/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class PinsTableViewCell: UITableViewCell {
    
    var cellEvent: Event?

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var scheduleLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let event = cellEvent {
        
            self.userName.text = event.creatorName
            
            self.scheduleLabel.text = "\(String(describing: event.beginHour)) a \(String(describing: event.endHour))"
            self.eventImageView.image = UIImage(named: (event.preference)!)
        
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
