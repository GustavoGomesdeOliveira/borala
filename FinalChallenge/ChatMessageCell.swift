//
//  ChatMessageCell.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 24/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        return tv
    }()
    
    
    static let blueColor = UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 178, green: 66, blue: 100, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true

        return view
        
    }()
    
    let profileImageChat: UIImageView = {
       
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "profileImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1).cgColor
        
        return imageView
        
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()

    }
    
    func setup(){
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageChat)
        
        profileImageChat.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageChat.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageChat.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageChat.heightAnchor.constraint(equalToConstant: 32).isActive = true

        
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor?.isActive = true
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageChat.rightAnchor, constant: 8)
        
        bubbleViewLeftAnchor?.isActive = false

        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        
        //textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
}
