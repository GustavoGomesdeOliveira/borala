//
//  ProfileViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var backRoundView: UIView!
    @IBOutlet weak var backUserView: UIView!
    @IBOutlet weak var backGenderView: UIView!
    @IBOutlet weak var backAgeView: UIView!
    @IBOutlet weak var backPreferencesView: UIView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        


        self.backRoundView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        self.backUserView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        
        self.backAgeView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        
        self.backGenderView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        self.backPreferencesView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        
        
        let userData = UserDefaults.standard.object(forKey: "user") as! Data
        let user = NSKeyedUnarchiver.unarchiveObject(with: userData)
//        print("\(user)")
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
