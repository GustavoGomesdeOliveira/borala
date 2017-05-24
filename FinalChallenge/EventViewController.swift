//
//  EventViewController.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 22/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

protocol EventViewControllerDelegate{
    func sendEvent( event : String)
}

class EventViewController: UIViewController, UIPickerViewDelegate {
    
    var delegate:EventViewControllerDelegate!
    
    let pickerData:[UIImage] = [UIImage(named: "pizza.jpg")!,
                                UIImage(named: "beer.jpg")!, UIImage(named: "food.jpg")!]

    
    @IBOutlet weak var imagePicker: UIPickerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        
        imagePicker.delegate = self
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
       // imagePicker.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        delegate?.sendEvent(event: "value")
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
 

}
