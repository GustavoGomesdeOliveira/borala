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
    static var firebaseUser: FIRUser? = nil
    
    static func saveProfilePic(userId : String, pic: Data, completionHandler:((_ error: Error?) -> ())? ){
        let profilePicRef = rootRefStorage.child("/users/\(userId)/profilePic.jpg")
        let _ = profilePicRef.put(pic, metadata: nil) {
            metadata, error in
            
            if let downloadUrl = metadata!.downloadURL()?.absoluteString{
                rootRefDatabase.child("users/\(String(describing: firebaseUser?.uid))").updateChildValues(["picURL": downloadUrl])
            }
            if let errorOnPutData = completionHandler{
                errorOnPutData(error)
            }
        }
    }
    
    static func saveUser(user: User){
        let idRef   = rootRefStorage.child("users/" + user.id + "/")
        let picRef  = idRef.child("pic/profilePic.jpg")
        var userDictionary = user.toDictionary()
        userDictionary["eventsId"] = true
        let picdownloadUrl = ""
        
        if let userPic = user.pic{
            picRef.put(userPic, metadata: nil, completion: {
                metadata, error in
                
                userDictionary.updateValue(picdownloadUrl, forKey: "picURL")
                if let error = error{
                    print("An error ocurred to send pic to firebase. \(error)")
                }
                else{
                    if let downloadUrl = metadata!.downloadURL()?.absoluteString{
                        userDictionary.updateValue(downloadUrl, forKey: "picURL")
                    }
                }
                rootRefDatabase.child("users").updateChildValues([user.id: userDictionary])
            })
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
        rootRefDatabase.child("events").child(key).setValue(eventDict)//it saves the new event on firebase.
    }
    
    static func saveMessage(chatId: String, text: String){
        let key = rootRefDatabase.child("messages/" + chatId).childByAutoId()//it adds a unique id to msg.
        let timeStamp = FIRServerValue.timestamp()
        let msgDict = ["senderName": firebaseUser?.displayName! ?? "anonymous",
                       "timeStamp": timeStamp,
                       "text": text] as [String : Any]
        key.setValue(msgDict) //it added the message to firebase
        rootRefDatabase.child("chats/" + chatId).setValue(msgDict)
    }

    //*** Chat related methods *******************************************************************************************************
    
    //it creates a chat for the given event
    static func createChat(event: Event){
        if let userId = firebaseUser?.uid{
            rootRefDatabase.child("users/" + userId + "/eventsWithChatsIds").observeSingleEvent(of: .value, with: {
                snapshot in
                if let eventsIdDictionary = snapshot.value as? [String: Any]{
                    if !eventsIdDictionary.keys.contains(event.id){
                        let chatId = rootRefDatabase.child("chats").childByAutoId()//it adds a unique id.
                        rootRefDatabase.child("chats").child(chatId.key).setValue(true)//it adds true as value of chats/chatId
                        rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)! + "/eventsWithChatsIds").updateChildValues([chatId.key: true])
                        rootRefDatabase.child("users/" + event.creatorId + "/eventsWithChatsIds").updateChildValues([chatId.key: true])
                    }
                }
                else{
                    let chatId = rootRefDatabase.child("chats").childByAutoId()//it adds a unique id.
                    rootRefDatabase.child("chats").child(chatId.key).setValue(true)//it adds true as value of chats/chatId
                    rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)! + "/eventsWithChatsIds").setValue([chatId.key: true])
                    rootRefDatabase.child("users/" + event.creatorId + "/eventsWithChatsIds").setValue([chatId.key: true])
                }
            })
        }
    }
    
    static func getChats( completionHandler: @escaping (_ chats: [Chat]) -> () ){
        rootRefDatabase.child("users/" + (firebaseUser?.uid)! + "/chatsId").observe( .childAdded, with: {
            snapshot in
            var chatsFromFirebase = [Chat]()
            if let dict = snapshot.value as? [String: Bool]{
                let chatIds = Array(dict.keys)
                for chatId in chatIds{
                    let chatDict = rootRefDatabase.child("chats").value(forKey: chatId) as! [String: Any]
                    chatsFromFirebase.append(Chat.init(id: chatId,
                                                       lastMessage: Message(id: "", senderName: chatDict["senderName"] as! String,
                                                                                        text: chatDict["text"] as! String, timeStamp: chatDict["timeStamp"] as! Float)))
                }
                completionHandler(chatsFromFirebase)
            }
        })
    }
    
    static func deleteChatFromFirebase(completionHandler: @escaping (_ chatsId: String) -> ()){
        rootRefDatabase.child("users/" + (firebaseUser?.uid)! + "/chatsId").observe(.childRemoved, with: {
            snapshot in
            let chatDict = snapshot.value as! [String: Any]
            completionHandler((chatDict.first?.key)!)
        })
    }
    
    static func removeChatObserver(){
        rootRefDatabase.child("users/" + (firebaseUser?.uid)! + "/chatsId").removeAllObservers()
    }
    //**********************************************************************************************************************
    
    static func getMessages(chatId: String){
        rootRefDatabase.child("messages/" + chatId).observe(.childAdded, with: {
            snapshot in
            if let dic = snapshot.value as? [String: Any]{
                print(Array(dic.keys))
            }
        })
    }
    
    static func registerMeOnline(){
        if let currentUser = FIRAuth.auth()?.currentUser{
            let currentUserRef = rootRefDatabase.child("onlineUsers/" + currentUser.uid)
            currentUserRef.setValue(true)
            currentUserRef.onDisconnectRemoveValue()
        }
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
                    print(dic[kk] as! [String: Any])
                    eventsFromFirebase.append(Event(dict: dic[kk] as! [String: Any] ))
                    completionHandler(eventsFromFirebase)
                }
            }
        })
    }
    
    static func observerMessages(ofChatId: String, completionHandler:@escaping (_ messages: [Message]?) -> ()){
        rootRefDatabase.child("messages").observe( .childAdded , with:{
            snapshot in
            
            if let messageDictionary = snapshot.value as? [String: Any]{
                print(messageDictionary)
                for kk in messageDictionary.keys{
                    let msg = messageDictionary[kk] as! [String: Any]
                    let dateStr = msg["timeStamp"] as! Int
                    let date = Date.init(timeIntervalSince1970: Double.init(dateStr))
                    //print(date)
                }
                completionHandler(nil)
            }
        })
    }
    
    static func removeOnlineUsersLister(){
        rootRefDatabase.child("onlineUsers").removeAllObservers()
    }
    
    static func removeEventLister(){
        rootRefDatabase.child("events").removeAllObservers()
    }
    
    static func observerUser(){
        FIRAuth.auth()?.addStateDidChangeListener({
            auth, user in
            if let user = user{
                firebaseUser = user
            }
        })
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
