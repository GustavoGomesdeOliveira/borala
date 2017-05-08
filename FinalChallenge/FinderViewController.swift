//
//  FinderViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 24/04/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit
import FBSDKCoreKit


class FinderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let token = FBSDKAccessToken.current()
        
        
        
        
        FBSDKGraphRequest(graphPath: "/\(token)/friends", parameters: nil).start { (connection, result, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            print(result!)
            
        }
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
