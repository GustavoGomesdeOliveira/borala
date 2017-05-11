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
    override func viewDidAppear(_ animated: Bool) {

        self.selectedIndex = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()        
        
//        self.tabBarController?.tabBar.backgroundColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
