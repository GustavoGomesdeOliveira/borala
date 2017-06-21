//
//  TabBarViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 09/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
//    
    var userNotLogged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideTabBar()
        
        self.selectedIndex = 1
        
        // Do any additional setup after loading the view.
    }
    
    
    func hideTabBar(){
        
        if ((UserDefaults.standard.data(forKey: "user") == nil) && (userNotLogged)){
            
            self.tabBar.isUserInteractionEnabled = false
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
