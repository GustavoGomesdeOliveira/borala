//
//  ChooseFilter.swift
//  FinalChallenge
//
//  Created by Daniel Dias on 21/06/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

enum Search:Int {
    case Friends
    case NotFriend
    case Everyone
}


class ChooseFilterController: UIViewController {
    
    @IBOutlet weak var friends: UIButton!
    @IBOutlet weak var newPeople: UIButton!
    @IBOutlet weak var everyone: UIButton!
    var filterDelegate: FilterDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchMode = UserDefaults.standard.integer(forKey: "search")
        
        filterDelegate?.changeFilter(filter: Search(rawValue: searchMode)!)
        
            switch searchMode {
            
            case Search.Friends.hashValue:
                
                setBtnColors(firstBtn: self.friends, secondBtn: self.newPeople, thirdBtn: self.everyone)
                break
            case Search.NotFriend.hashValue:
                setBtnColors(firstBtn: self.newPeople, secondBtn: self.friends, thirdBtn: self.everyone)
                break
            case Search.Everyone.hashValue:
                setBtnColors(firstBtn: self.everyone, secondBtn: self.newPeople, thirdBtn: self.friends)
                break
            default:
                break
            }
    }
    
    func setBtnColors(firstBtn: UIButton, secondBtn: UIButton, thirdBtn: UIButton){
        
        firstBtn.backgroundColor = UIColor.gray
        secondBtn.backgroundColor = UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
        thirdBtn.backgroundColor = UIColor(red: (178/255), green: (66/255), blue: (100/255), alpha: 1)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch? = touches.first
        if touch?.view == self.view {
            self.view.removeFromSuperview()
        }
        
    }
    
    @IBAction func filterByFriends(_ sender: Any) {
        setBtnColors(firstBtn: self.friends, secondBtn: self.newPeople, thirdBtn: self.everyone)
        filterDelegate?.changeFilter(filter: Search.Friends)
        updateSearchMode(searchValue: Search.Friends.hashValue)
    }
    
    @IBAction func filterByNew(_ sender: Any) {
        setBtnColors(firstBtn: self.newPeople, secondBtn: self.friends, thirdBtn: self.everyone)
        filterDelegate?.changeFilter(filter: Search.NotFriend)
        updateSearchMode(searchValue: Search.NotFriend.hashValue)
    }
    
    
    @IBAction func filterByEveryone(_ sender: Any) {
        setBtnColors(firstBtn: self.everyone, secondBtn: self.newPeople, thirdBtn: self.friends)
        filterDelegate?.changeFilter(filter: Search.Everyone)
        updateSearchMode(searchValue: Search.Everyone.hashValue)
    }
    
    
    func updateSearchMode(searchValue: Int) {
        
        UserDefaults.standard.set(searchValue, forKey: "search")
        UserDefaults.standard.synchronize()
    }
    
}

protocol FilterDelegate {
    func changeFilter(filter: Search)
}

