//
//  FirebaseHelper.swift
//  FinalChallenge
//
//  Created by C. Williamberg on 11/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation
import Firebase


class FirebaseHelper{

    static let rootRefStorage = FIRStorage.storage().reference()
    static let rootRefDatabase = FIRDatabase.database().reference()
    //static var databaseHand = nil
    
    static func saveProfilePic(userId : String, pic: Data, completionHandler:((_ error: Error?) -> ())? ){
        let profilePicRef = rootRefStorage.child("/users/\(userId)/profilePic.jpg")
        let _ = profilePicRef.put(pic, metadata: nil) {
            metadata, error in
            if let errorOnPutData = completionHandler{
                errorOnPutData(error)
            }
        }
    }
    
    static func saveUser(user: User){
        let idRef   = rootRefStorage.child("users/" + user.id + "/")
        let nameRef = idRef.child("name/userName")
        let facebookIdRef = idRef.child("facebookId/facebookId")
        let genderRef  = idRef.child("gender/userGender")
        let friendsRef = idRef.child("friends/userFriends")
        let picRef     = idRef.child("pic/profilePic.jpg")
        let rateRef    = idRef.child("rate/userRate")
        let preferenceRef = idRef.child("preference/userPreference")
        let locationRef   = idRef.child("location/userLocation")
        
        
        if let nameData = user.name.data(using: .utf8){
            nameRef.put(nameData)
        }
        if let facebookIdData = user.facebookID.data(using: .utf8){
            facebookIdRef.put(facebookIdData)
        }
        if let genderData = user.gender.data(using: .utf8){
            genderRef.put(genderData)
        }
        if let userFriends = user.friends{
            let friendsData = NSKeyedArchiver.archivedData(withRootObject: userFriends)
            friendsRef.put(friendsData)
        }
        picRef.put(user.pic!)
        if let userRate = user.rate{
            rateRef.put(NSKeyedArchiver.archivedData(withRootObject: userRate))
        }
        if let userPreference = user.preference{
            preferenceRef.put(NSKeyedArchiver.archivedData(withRootObject: userPreference))
        }
        if let userLocation = user.location{
            locationRef.put(NSKeyedArchiver.archivedData(withRootObject: userLocation))
        }
    }
    
    static func saveString(path : String, object: String, completionHandler:((_ error: Error?) -> ())?){
        let firebaseReference = rootRefStorage.child(path)
        
        let _ = firebaseReference.put(object.data(using: .utf8)!, metadata: nil) {
            metadata, error in
            if let errorOnPutData = completionHandler{
                errorOnPutData(error)
            }
        }
    }
    
    static func saveEvent(event: Event){
        let key = rootRefDatabase.child("events").childByAutoId().key
        let eventLocation = ["latitude": event.location.latitude, "longitude": event.location.longitude]
        let eventDict = ["id": key, "name": event.name, "location": eventLocation, "creatorId": event.creatorId, "creatorName": event.creatorName, "hour": event.hora, "preference": event.preference ?? ""] as [String : Any]
        rootRefDatabase.child("events").child(key).setValue(eventDict)
    }
    
    static func saveMessage(chatId: String, text: String){
        let key = rootRefDatabase.child("chats").childByAutoId().key//it adds a unique id.
        let msgDict = ["id": key,
                       "senderId": "",
                       "senderName": "",
                       "timeStamp": FIRServerValue.timestamp(),
                       "text": text] as [String : Any]
        rootRefDatabase.child("chats/\(chatId)").setValue(msgDict)
    }

    
    static func registerMeOnline(){
        if let currentUser = FIRAuth.auth()?.currentUser{
            let currentUserRef = rootRefDatabase.child("onlineUsers/" + currentUser.uid)
            currentUserRef.setValue(true)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    
    static func createChat(){
        let key = rootRefDatabase.child("chats").childByAutoId().key//it adds a unique id.
        rootRefDatabase.child("chats").child(key).setValue(["lastMessage": "bla bla",
                                        "senderName": "berg"])
    }
    
    static func getOnlineUsers(completionHandler:@escaping (_ onlineUsers: [String]?) -> ()){
        rootRefDatabase.child("onlineUsers").observe(.value,with:{
            snapshot in
            print("online \(snapshot.value)")
        })
        
    }
    
    static func getEvents(completionHandler:@escaping (_ events: [Event]) -> ()){
        rootRefDatabase.child("events").observe(.value,with:{
            snapshot in
            if let dic = snapshot.value as? [String: Any]{
                var eventsFromFirebase = [Event]()
                for kk in dic.keys{
                    print(kk)
                    print(dic[kk] as! [String: Any])
                    eventsFromFirebase.append(Event(dict: dic[kk] as! [String: Any] ))
                    completionHandler(eventsFromFirebase)
                }
            }
        })
        
    }
    
    static func removeOnlineUsersLister(){
        rootRefDatabase.child("onlineUsers").removeAllObservers()
    }
    
    static func removeEventLister(){
        rootRefDatabase.child("events").removeAllObservers()
    }
}







//let rootRef = FIRStorage.storage().reference()
//let profilePicRef = rootRef.child("/users/\(id)/profilePic.jpg")
//let userNameRef = rootRef.child("users/\(id)/name/username")
//let _ = profilePicRef.put(data!, metadata: nil) { metadata, error in
//    if (error != nil) {
//        // Uh-oh, an error occurred!
//    } else {
//        // Metadata contains file metadata such as size, content-type, and download URL.
//        let downloadURL = metadata!.downloadURL
//    }
//}
