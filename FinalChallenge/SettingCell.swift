//
//  SettingCell.swift
//  teste side bar
//
//  Created by Daniel Dias on 19/06/17.
//  Copyright © 2017 Daniel.Dias. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SettingCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1) : UIColor.white
            
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
            
            iconImageView.tintColor = isHighlighted ? UIColor.white : UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
        }
    }
    
    var setting: Setting? {
        didSet {
            nameLabel.text = setting?.name
            nameLabel.textColor = UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
            
            if let imageName = setting?.imageName {
                iconImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
            }
        }
    }
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Setting"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "settings")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(nameLabel)
        addSubview(iconImageView)
        
        addConstraintsWithFormat("H:|-9-[v0(30)]-9-[v1]|", views: iconImageView, nameLabel)
        addConstraintsWithFormat("V:|[v0]|", views: nameLabel)
        addConstraintsWithFormat("V:[v0(20)]", views: iconImageView)
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }

}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
