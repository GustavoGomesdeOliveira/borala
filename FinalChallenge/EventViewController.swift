//
//  EventViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 22/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

protocol EventViewControllerDelegate{
    func sendEvent( preference : String, description: String?)
}

class EventViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    var delegate:EventViewControllerDelegate!
    let imageNames = ["pizza","beer","food"]
    let eventDescription = "default description"
    
    let pickerData:[UIImage] = [UIImage(named: "pizza.jpg")!,
                                UIImage(named: "beer.jpg")!, UIImage(named: "food.jpg")!]
    var index = 0
    
    //outlets
    
    @IBOutlet weak var imagePicker: UIPickerView!
    
    @IBOutlet weak var beginHourTextField: UITextField!
    
    @IBOutlet weak var endHourTextField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    //--------------
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        self.beginHourTextField.delegate = self
        self.endHourTextField.delegate = self
        self.addDoneButtonOnKeyboard()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func createEvent(_ sender: UIButton) {
        let preference = self.imageNames[self.index]
        
        delegate?.sendEvent(preference: preference, description: eventDescription)
        
        self.view.removeFromSuperview()
    }
    

    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(70)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
   
        
        let myView = UIView(frame: CGRect(x: 0 , y: 0, width: pickerView.bounds.width, height: 60))
        
        let myImageView = UIImageView(frame: CGRect(x: (pickerView.bounds.width/2)-20, y: 0, width: 50, height: 50))
        
        myImageView.image = pickerData[row]
        myView.addSubview(myImageView)
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.index = row
    }
 
    
     // MARK: textFields Delegate
    
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
    
    
    // MARK: functions
    func addDoneButtonOnKeyboard()
    {
        
        
        var doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(EventViewController.doneButtonAction))
        
        var items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        
        doneToolbar.items = items as! [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
//        self.textView.inputAccessoryView = doneToolbar
        self.endHourTextField.inputAccessoryView = doneToolbar
        self.beginHourTextField.inputAccessoryView = doneToolbar
//        self.textField.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.endHourTextField.resignFirstResponder()
        self.beginHourTextField.resignFirstResponder()
    }

}
