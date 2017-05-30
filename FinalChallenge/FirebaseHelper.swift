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
    
    
    static func getUserData(userID: String,completionHandler:@escaping (_ user: User) -> ()){
        rootRefDatabase.child("users").observe(.value,with:{
            snapshot in
            if let dic = snapshot.value as? [String: Any]{
                var userFromFirebase = User()
                var count = 0
                for kk in dic.keys{

                    
                    if let user = dic[kk] {
                        
                        if count == 0 {
                            count += 1

                            continue
                            
                            
                        }
                        
                        let dict = user as! NSDictionary
                            
                        let id = dict["id"] as! String
                            
                        if id == userID {
                            userFromFirebase = User(dict: dic[kk] as! [String: Any])
                            print(userFromFirebase.name)
                            completionHandler(userFromFirebase)
                        }else{
                            userFromFirebase = User()
                            completionHandler(userFromFirebase)
                        }
                        
                    }
                }
            }
        })
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
    
    static func getEvents(completionHandler:@escaping (_ events: [Event]) -> ()){
        rootRefDatabase.child("events").observe(.value,with:{
            snapshot in
            if let dic = snapshot.value as? [String: Any]{
                var eventsFromFirebase = [Event]()
                for kk in dic.keys{
                    print(dic[kk] as! [String: Any])
                    //esse que eu quero
                    eventsFromFirebase.append(Event(dict: dic[kk] as! [String: Any] ))
                    completionHandler(eventsFromFirebase)
                }
            }
        })
    }
    
    //*** Chat related methods *******************************************************************************************************
    
    //it creates a chat for the given event
    static func createChat(event: Event, completionHandler: @escaping (_ _chatId: String) -> ()){
        if let userId = firebaseUser?.uid{
            rootRefDatabase.child("users/" + userId + "/eventsWithChatsIds").observeSingleEvent(of: .value, with: {
                snapshot in
                if let eventsIdDictionary = snapshot.value as? [String: Any]{
                    if !eventsIdDictionary.keys.contains(event.id){
                        let chatId = rootRefDatabase.child("chats").childByAutoId()//it adds a unique id.
                        rootRefDatabase.child("chats").child(chatId.key).setValue(true)//it adds true as value of chats/chatId
                        rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)! + "/eventsWithChatsIds").updateChildValues([event.id: true])
                        rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)! + "/chatsId").updateChildValues([chatId.key: true])
                        
                        rootRefDatabase.child("users/" + event.creatorId + "/eventsWithChatsIds").updateChildValues([event.id: true])
                        rootRefDatabase.child("users/" + event.creatorId + "/chatsId").updateChildValues([chatId.key: true])
//                        rootRefDatabase.child("chatsMembers").child(chatId.key).updateChildValues(
//                            [(FirebaseHelper.firebaseUser?.uid)!: rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)!).value(forKey: "picURL"), event.creatorId: rootRefDatabase.child("users/" + event.creatorId).value(forKey: "picURL")])
                        completionHandler(chatId.key)
                    }
                }
                else{
                    let chatId = rootRefDatabase.child("chats").childByAutoId()//it adds a unique id.
                    rootRefDatabase.child("chats").child(chatId.key).setValue(true)//it adds true as value of chats/chatId
                    rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)! + "/eventsWithChatsIds").updateChildValues([event.id: true])
                    rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)! + "/chatsId").updateChildValues([chatId.key: true])
                    
                    rootRefDatabase.child("users/" + event.creatorId + "/eventsWithChatsIds").setValue([event.id: true])
                    rootRefDatabase.child("users/" + event.creatorId + "/chatsId").updateChildValues([chatId.key: true])
                    //rootRefDatabase.child("chatsMembers").child(chatId.key).updateChildValues(
//                        [(FirebaseHelper.firebaseUser?.uid)!: rootRefDatabase.child("users/" + (FirebaseHelper.firebaseUser?.uid)!).value(forKey: "picURL"), event.creatorId: rootRefDatabase.child("users/" + event.creatorId).value(forKey: "picURL")])
                    completionHandler(chatId.key)
                }
            })
        }
    }
    
    static func getChats( completionHandler: @escaping (_ chats: [Chat]) -> () ){
        rootRefDatabase.child("users/" + (firebaseUser?.uid)! + "/chatsId").observe( .value, with: {
            snapshot in
            var chatsFromFirebase = [Chat]()
            if let dict = snapshot.value as? [String: Bool]{
                let chatIds = Array(dict.keys)
                for chatId in chatIds{
                    rootRefDatabase.child("chats/").child(chatId).observeSingleEvent(of: .value, with: {
                        snapshotChat in
                        if let chatDict = snapshotChat.value as? [String: Any]{
                            rootRefDatabase.child("chatsMembers/").child(chatId).observeSingleEvent(of: .value, with: {
                                chatMembersSnapshot in
                                if let chatMembersDictionary = chatMembersSnapshot.value as? [String: Any]{
                                    let chatMembersKeys = Array(chatMembersDictionary.keys)
                                    for chatMembersKey in chatMembersKeys{
                                        if chatMembersKey != self.firebaseUser?.uid{
                                            //get pic..
                                            self.getPictureProfile(userId: chatMembersKey, completitionHandler: {
                                                pictureData in
                                                chatsFromFirebase.append(Chat.init(id: chatId, pic: pictureData,
                                                                                   lastMessage: Message(id: chatDict["id"] as! String, senderId: chatDict["senderId"] as! String, senderName: chatDict["senderName"] as! String,
                                                                                                        text: chatDict["text"] as! String,
                                                                                                        timeStamp:chatDict["timeStamp"] as! Float)))
                                                completionHandler(chatsFromFirebase)
                                                
                                            })
                                        }
                                    }
                                }
                            })
                        }
                    })
                }
            }
        })
    }
    
    static func deleteChat(completionHandler: @escaping (_ chatsId: String) -> ()){
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
    
    //**** Messages related methods   **************************************************************************************
        
    static func saveMessage(chatId: String, message: Message){
        let newRef = rootRefDatabase.child("messages/" + chatId).childByAutoId()//it adds a unique id to msg.
        let timeStamp = FIRServerValue.timestamp()
        var msgDict = message.toDictionary()
        msgDict.updateValue(newRef.key, forKey: "id")
        msgDict.updateValue(timeStamp, forKey: "timeStamp")
        newRef.setValue(msgDict) //it added the message to firebase
        rootRefDatabase.child("chats/" + chatId).setValue(msgDict)
    }

    static func messageWasAdded(chatId: String, completionHandler: @escaping(_ message: Message) -> () ){
        rootRefDatabase.child("messages/" + chatId).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let msg = Message(id: "", senderId: dict["senderId"] as! String, senderName: dict["senderName"] as! String,
                                  text: dict["text"] as! String, timeStamp: dict["timeStamp"] as! Float)
                completionHandler(msg)
            }
        })
    }
    
    static func removeMessagesObserver(chatId: String){
        rootRefDatabase.child("messages/" + chatId).removeAllObservers()
    }
    //**********************************************************************************************************************
    
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
            //print("online \(snapshot.value)")
        })
        
    }
    
//    static func observerMessages(ofChatId: String, completionHandler:@escaping (_ messages: [Message]?) -> ()){
//        rootRefDatabase.child("messages").observe( .childAdded , with:{
//            snapshot in
//            
//            if let messageDictionary = snapshot.value as? [String: Any]{
//                print(messageDictionary)
//                for kk in messageDictionary.keys{
//                    let msg = messageDictionary[kk] as! [String: Any]
//                    let dateStr = msg["timeStamp"] as! Int
//                    let date = Date.init(timeIntervalSince1970: Double.init(dateStr))
//                    //print(date)
//                }
//                completionHandler(nil)
//            }
//        })
//    }
    
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
                firebaseUser?.displayName
                print(firebaseUser?.displayName)
            }
        })
    }
    
    
    static func getPictureProfile(userId: String, completitionHandler: @escaping (_ picture: Data?) -> ()){
        let picAddress = rootRefDatabase.child("users/").child(userId).value(forKey: "picURL") as! String
        let picUrl = URL(string: picAddress)!
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: picUrl) {
            (data, response, error) in
            if let error = error {
                print("Error downloading cat picture: \(error)")
                completitionHandler(nil)
            } else {
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    if let picData = data {
                        completitionHandler(picData)
                    } else {
                        completitionHandler(nil)
                    }
                } else {
                    print("Couldn't get response code for some reason")
                    completitionHandler(nil)
                }
            }
        }
        downloadPicTask.resume()
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
