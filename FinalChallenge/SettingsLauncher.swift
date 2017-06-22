//
//  SettingsLauncher.swift
//  teste side bar
//
//  Created by Daniel Dias on 19/06/17.
//  Copyright © 2017 Daniel.Dias. All rights reserved.
//

import UIKit

class Setting: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class SettingsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    var parentview : UIView?
    let blackview = UIView()
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    var tabBarheight: CGFloat = 0
    let cellID = "cellID"
    let cellHeight: CGFloat = 55
    
    let settings: [Setting] = {
        return [Setting(name: "Filter by persons", imageName: "filter"), Setting(name: "Filter by distance", imageName: "distance"), Setting(name: "Cancel", imageName: "cancel")]
    }()
    
    //var homeController: FinderViewController?
    
    func handleDismiss(_ setting: Setting) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackview.alpha = 0
            
            if let window = UIApplication.shared.keyWindow{
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
            
        }) { (completed: Bool) in
            
            
            if setting.name != "" && setting.name != "Cancel" {
                //é aqui que acontece a magica de chamar a outra modal
                if setting.name == "Filter by persons" {
                    //filter by friends
                    let parent = UIApplication.shared.keyWindow?.rootViewController as! TabBarViewController
                    
                    let mycontroller = parent.selectedViewController as! FinderViewController
                    mycontroller.showControllerForSetting(setting)
//                    print(self.homeController?.myID)
                 
                }else {
                    //filter by distance
                
                
                }
            }
        }
    }
    
    
    func showSettings() {
        
        if let window = UIApplication.shared.keyWindow{
            
            
            self.blackview.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.blackview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackview)
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(settings.count) * cellHeight
            let y = window.frame.height - height //- tabBarheight
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            self.blackview.frame = window.frame
            self.blackview.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { 
                self.blackview.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SettingCell
        
        let setting = settings[indexPath.item]
        cell.setting = setting
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let setting = self.settings[indexPath.item]
        handleDismiss(setting)
    }
    

    override init() {
        super.init()
        //
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    
}
