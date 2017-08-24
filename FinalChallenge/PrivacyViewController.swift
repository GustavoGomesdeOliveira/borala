//
//  PrivacyViewController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 22/08/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    @IBOutlet weak var pdf: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: "https://www.drive.google.com/open?id=0B3ue_QXtatbJNWx1cS1TdjFUeGs")
        
        if let unrapedURL = url {
            
            let request = URLRequest(url: unrapedURL)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil{
                    
                    self.pdf.loadRequest(request)
                } else {
                    
                    print(error!)
                }
                
            }
            
            task.resume()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        print("teste sucedido")
        self.dismiss(animated: true, completion: nil)
        
    }
    
//    @IBAction func back(_ sender: Any) {
//        print("teste sucedido")
//       // self.navigationController?.popViewController(animated: true)
//        //self.removeFromParentViewController()
//    }
    
    
    
}
