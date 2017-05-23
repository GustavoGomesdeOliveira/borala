//
//  PopUpViewController.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 23/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    
    var userToChange: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.popUpView.layer.borderColor = UIColor(red: 254/255, green: 148/255, blue: 40/255, alpha: 1).cgColor
        self.popUpView.layer.borderWidth = 3
        
        self.nameTextField.delegate = self
        self.nameTextField.text = userToChange.name
        self.genderTextField.delegate = self
        self.genderTextField.text = userToChange.gender
        self.ageTextField.delegate = self
        
    }
    
    
    @IBAction func closeUp(_ sender: Any) {
        
        userToChange.name = self.nameTextField.text
        userToChange.gender = self.genderTextField.text
        changeUser()
        self.view.superview?.reloadInputViews()
        self.view.removeFromSuperview()
    }
    
    func changeUser(){
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User
            
            user?.name = self.nameTextField.text
            user?.gender = user?.gender
            
            user?.pic = user?.pic
            let userData = NSKeyedArchiver.archivedData(withRootObject: user!)
            UserDefaults.standard.set(userData, forKey: "user")
            //Remember to save
            UserDefaults.standard.synchronize()
        }
        
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    
}
