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
    var eventDescription = "default description"
    
    let pickerData:[UIImage] = [UIImage(named: "pizza.jpg")!,
                                UIImage(named: "beer.jpg")!, UIImage(named: "food.jpg")!]
    let invitation: [String] = ["Hello, wanna share a meal?", "Hi, lets go dinner?", "Hello, do you want to eat pizza?", "Hi, are you up to go lunch?"]
    
    var imageIndex = 0
    var invitationIndex = 0
    var textFieldToChange = 0
    
    //outlets
    
    @IBOutlet weak var imagePicker: UIPickerView!
    
    @IBOutlet weak var beginHourTextField: UITextField!
    
    @IBOutlet weak var endHourTextField: UITextField!
    
    @IBOutlet weak var invitationPickerView: UIPickerView!
    
    //--------------

    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        self.dateFormatter.dateFormat = "HH:mm"
        
        imagePicker.delegate = self
        invitationPickerView.delegate = self
        self.beginHourTextField.delegate = self
        self.endHourTextField.delegate = self
//        self.addDoneButtonOnKeyboard()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)

    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func createEvent(_ sender: UIButton) {
        let preference = self.imageNames[self.imageIndex]
        self.eventDescription = self.invitation[invitationIndex]
//        if self.beginHourTextField.text == "" {
//            let beginHour = self.beginHourTextField.placeholder
//            print(beginHour)
//        }else{
//        }
        
        delegate?.sendEvent(preference: preference, description: eventDescription)
        
        self.view.removeFromSuperview()
    }
    

    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.imagePicker {
            //pickerView1
            return self.pickerData.count
        } else {
            //pickerView2
            return self.invitation.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        if pickerView == self.imagePicker {
            //pickerView1
            return CGFloat(100)
        } else {
            //pickerView2
            return CGFloat(20)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
   
        if pickerView == self.imagePicker {

            let myView = UIView(frame: CGRect(x: 0 , y: 0, width: pickerView.bounds.width, height: 75))
            
            let myImageView = UIImageView(frame: CGRect(x: (pickerView.bounds.width/2)-30, y: 3, width: 65, height: 65))
            
            myImageView.image = pickerData[row]
            myView.addSubview(myImageView)
            return myView
            
        } else {
            
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.black
            pickerLabel.text = invitation[row]
            pickerLabel.font = UIFont(name: "Arial-BoldMT", size: 14)
            pickerLabel.textAlignment = NSTextAlignment.center
            return pickerLabel
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if pickerView == self.imagePicker {
            self.imageIndex = row
        }else {
            self.invitationIndex = row
        }
    }
 
    
     // MARK: textFields Delegate
//    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        if textField == self.beginHourTextField {
            beginHourTextField.inputView = datePickerView
            self.beginHourTextField.text = dateFormatter.string(from: datePickerView.date)
            self.textFieldToChange = 0
        }else{
            endHourTextField.inputView = datePickerView
            self.endHourTextField.text = dateFormatter.string(from: datePickerView.date)

            self.textFieldToChange = 1
        }
        
        datePickerView.addTarget(self, action: #selector(EventViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
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
    
    
    // MARK: functions
//    func addDoneButtonOnKeyboard()
//    {
//        
//        
//        var doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//        doneToolbar.barStyle = UIBarStyle.blackTranslucent
//        
//        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(EventViewController.doneButtonAction))
//        
//        var items = NSMutableArray()
//        items.add(flexSpace)
//        items.add(done)
//        
//        doneToolbar.items = items as! [UIBarButtonItem]
//        doneToolbar.sizeToFit()
//        
////        self.textView.inputAccessoryView = doneToolbar
//        self.endHourTextField.inputAccessoryView = doneToolbar
//        self.beginHourTextField.inputAccessoryView = doneToolbar
////        self.textField.inputAccessoryView = doneToolbar
//        
//    }
//    
//    func doneButtonAction()
//    {
//        self.endHourTextField.resignFirstResponder()
//        self.beginHourTextField.resignFirstResponder()
//    }

//    func done(){
//        self.endHourTextField.resignFirstResponder()
//        self.beginHourTextField.resignFirstResponder()
//    }
//    
//    func keyboardWillShow(_ note : Notification) -> Void{
//        DispatchQueue.main.async { () -> Void in
//            self.button.isHidden = false
//            let keyBoardWindow = UIApplication.shared.windows.last
//            self.button.frame = CGRect(x: 0, y: (keyBoardWindow?.frame.size.height)!-53, width: 106, height: 53)
//            keyBoardWindow?.addSubview(self.button)
//            keyBoardWindow?.bringSubview(toFront: self.button)
//            UIView.animate(withDuration: (((note.userInfo! as NSDictionary).object(forKey: UIKeyboardAnimationCurveUserInfoKey) as AnyObject).doubleValue)!, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
//                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: 0)
//            }, completion: { (complete) -> Void in
////                print("Complete")
//            })
//        }
//    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
 
        dateFormatter.timeStyle = .short
        if self.textFieldToChange == 0{
            self.beginHourTextField.text = dateFormatter.string(from: sender.date)
        }else {
            self.endHourTextField.text = dateFormatter.string(from: sender.date)
        }
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
