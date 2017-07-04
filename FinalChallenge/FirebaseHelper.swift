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
    
//    static func saveProfilePic(userId : String, pic: Data, completionHandler:((_ error: Error?) -> ())? ){
//        let profilePicRef = rootRefStorage.child("/users/\(userId)/profilePic.jpg")
//        let _ = profilePicRef.put(pic, metadata: nil) {
//            metadata, error in
//            
//            if let downloadUrl = metadata!.downloadURL()?.absoluteString{
//                rootRefDatabase.child("users/\(String(describing: firebaseUser?.uid))").updateChildValues(["picURL": downloadUrl])
//            }
//            if let errorOnPutData = completionHandler{
//                errorOnPutData(error)
//            }
//        }
//    }
    
    static func saveThumbnail(userId : String, thumbnail: Data, completionHandler:((_ error: Error?) -> ())? ){
        let profilePicRef = rootRefStorage.child("/users/\(userId)/profileThumbnail.jpg")
        let _ = profilePicRef.put(thumbnail, metadata: nil) {
            metadata, error in
            
            if let downloadUrl = metadata!.downloadURL()?.absoluteString{
                rootRefDatabase.child("users/" + ( firebaseUser?.uid)!).updateChildValues(["thumbnailURL": downloadUrl])
            }
            if let errorOnPutData = completionHandler{
                errorOnPutData(error)
            }
        }
    }
    
    static func saveUser(user: User, completionHandler:((_ error: Error?) -> ())?){
        let idRef   = rootRefStorage.child("users/" + user.id + "/")
        let picRef  = idRef.child("pic/profilePic.jpg")
        var userDictionary = user.toDictionary()
        userDictionary["eventsId"] = true
        let picdownloadUrl = ""
        
        let defaults = UserDefaults.standard
        
        let friendDefaults = defaults.object(forKey: "friendList")
        
        if let userPic = user.pic{
            picRef.put(userPic, metadata: nil, completion: {
                metadata, error in
                
                userDictionary.updateValue(picdownloadUrl, forKey: "picURL")
                if let error = error, let completionHandler = completionHandler{
                    print("An error ocurred to send pic to firebase. \(error)")
                    completionHandler(error)
                }
                else{
                    if let downloadUrl = metadata!.downloadURL()?.absoluteString{
                        userDictionary.updateValue(downloadUrl, forKey: "picURL")
                    }
                }
                
                rootRefDatabase.child("users").updateChildValues([user.id: userDictionary])
                
                if friendDefaults != nil {
                    
                    for friend in (friendDefaults as! [String]) {
                        
                        self.saveFriend(socialnetworkId: friend)
                        
                    }
                    
                }
                if let completionHandler = completionHandler{ completionHandler(nil) }
            })
        }
        rootRefDatabase.child("socialnetworkIds").updateChildValues([user.socialNetworkID: user.id])
    }
    
    static func updateUser(userId: String, userInfo: [String: Any]){
        rootRefDatabase.child("users/" + userId + "/").updateChildValues(userInfo)
    }
    
    //save the friend on my friend list
    static func saveFriend(socialnetworkId: String){
        rootRefDatabase.child("socialnetworkIds/" + socialnetworkId).observeSingleEvent(of: .value, with: {
            snapshot in
            if let firebaseIdReceived = snapshot.value as? String{
                rootRefDatabase.child("users/" + (firebaseUser?.uid)! + "/friendsId").updateChildValues( [firebaseIdReceived: true] )
                rootRefDatabase.child("users/" + firebaseIdReceived + "/friendsId").updateChildValues( [(firebaseUser?.uid)!: true] )
            }
        })
    }
    
    static func getFriends(userId: String, completionHandler: @escaping ((_ friend: [String: Any]?) -> ())){
        rootRefDatabase.child("users/" + userId + "/friendsId").observeSingleEvent(of: .value, with: {
            snapshot in
            if let friendsIdDictionary = snapshot.value as? [String: Bool]{
                let friendsId = Array(friendsIdDictionary.keys)
                for friendId in friendsId{
                    self.getUserData(userID: friendId, completionHandler: {
                        user in
                        completionHandler(["id": user.id, "name": user.name, "picUrl": user.picUrl!, "socialNetworkID": user.socialNetworkID])
                    })
                }
            }
        })
    }
    static func likeListAdd(id: String){
        rootRefDatabase.child("users/" + (id) + "/likeIds").updateChildValues([(firebaseUser?.uid)!: true])//adds the id to likeIds node.
        rootRefDatabase.child("users/" + (id) + "/dislikeIds/" + (firebaseUser?.uid)!).setValue(nil)//removes the id from dislikeIds node.
    }
    
    static func dislikeListAdd(id: String){
        rootRefDatabase.child("users/" + (id) + "/dislikeIds").updateChildValues([(firebaseUser?.uid)!: true])//adds the id to dislikeIds node.
        rootRefDatabase.child("users/" + (id) + "/likeIds/" + (firebaseUser?.uid)!).setValue(nil)//removes the id from likeIds node.
    }

    
    static func getUserData(userID: String,completionHandler:@escaping (_ user: User) -> ()){
        rootRefDatabase.child("users/" + userID).observeSingleEvent(of: .value, with:{
            snapshot in
            if let dic = snapshot.value as? [String: Any]{
                let userFromFirebase = User(dict: dic)
                completionHandler(userFromFirebase)
            }
        })
    }
    
    static func getUserName(userID: String,completionHandler:@escaping (_ name: String?) -> ()){
        rootRefDatabase.child("users/" + userID + "/name").observeSingleEvent(of: .value, with: {
            snapshot in
            if let userName = snapshot.value as? String{
                completionHandler(userName)
            }
            completionHandler(nil)
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
    
    //MARK: Events related methods.
    static func saveEvent(event: Event){
        let key = rootRefDatabase.child("events").childByAutoId().key
        let eventLocation = ["latitude": event.location.latitude, "longitude": event.location.longitude]
        let eventDict = ["id": key, "name": event.name, "location": eventLocation,
                         "creatorId": event.creatorId, "creatorName": event.creatorName,
                         "beginHour": Double( event.beginHour.timeIntervalSince1970) ,
                            "endHour":   Double( event.endHour.timeIntervalSince1970),
                         "preference": event.preference ?? "",
                         "description": event.description ?? ""] as [String : Any]
        rootRefDatabase.child("events").child(key).setValue(eventDict)//it saves the new event on firebase.
    }
    
    static func getEvents(completionHandler:@escaping (_ events: [Event]) -> ()){
        rootRefDatabase.child("events").observe(.value,with:{
            snapshot in
            var eventsFromFirebase = [Event]()
            if let dic = snapshot.value as? [String: Any]{
                for key in dic.keys{
                    eventsFromFirebase.append(Event(dict: dic[key] as! [String: Any] ))
                }
            }
            completionHandler(eventsFromFirebase)
        })
    }
    
    static func getNotFriendsEvents(completionHandler:@escaping (_ events: [Event]) -> ()){
        rootRefDatabase.child("users/" + (self.firebaseUser?.uid)! + "/friendsId").observe(.value, with:{friendsSnapshot in
            if let friendsIdDictionary = friendsSnapshot.value as? [String: Bool]{
                rootRefDatabase.child("events").observe(.value,with:{
                    snapshot in
                    if let eventsDictionary = snapshot.value as? [String: Any]{
                        var eventsFromFirebase = [Event]()
                        eventsDictionary.forEach{
                            key, value in
                            let eventDictionary = value as! [String: Any]
                            if !friendsIdDictionary.keys.contains( eventDictionary["creatorId"] as! String ){
                                eventsFromFirebase.append(Event(dict: eventDictionary ))
                                completionHandler(eventsFromFirebase)
                            }
                        }
                    }
                })
            }
        })
    }
    
    static func getFriendsEvents(completionHandler:@escaping (_ events: [Event] ) -> ()){
        rootRefDatabase.child("users/" + (self.firebaseUser?.uid)! + "/friendsId").observe( .childAdded, with:{  friendsSnapshot in
            
            let query = rootRefDatabase.child("events/").queryOrdered(byChild: "creatorId").queryEqual(toValue: friendsSnapshot.key)
                query.observe(.value, with:{
                    snapshot in
                    if let dic = snapshot.value as? [String: Any]{
                        var eventsFromFirebase = [Event]()
                        dic.keys.forEach{ key in
                            eventsFromFirebase.append(Event(dict: dic[key] as! [String: Any] ))
                            completionHandler(eventsFromFirebase)
                        }
                    }
                })
        })
        let myEventsQuery = rootRefDatabase.child("events/").queryOrdered(byChild: "creatorId").queryEqual(toValue: (self.firebaseUser?.uid)!)
        myEventsQuery.observe(.value, with: {
            snapshot in
            if let dic = snapshot.value as? [String: Any]{
                var eventsFromFirebase = [Event]()
                dic.keys.forEach{ key in
                    eventsFromFirebase.append(Event(dict: dic[key] as! [String: Any] ))
                    completionHandler(eventsFromFirebase)
                }
            }
        })
    }
    
    
    
    static func deleteEvent(eventId: String){
        rootRefDatabase.child("events/" + eventId).setValue(nil)
    }
    
    static func removeEventObservers(){
        rootRefDatabase.child("events").removeAllObservers()
    }
    
    //MARK: Events related methods.
    /// it creates a chat between this user and a partner.
    ///
    /// - Parameters:
    ///   - partnerId: the firebase uid of the person you wish create a chat.
    ///   - completionHandler: Return the chat id just created. If the chat already exists between those people return nil.
    static func createChat(partnerId: String, completionHandler: @escaping (_ _chatId: String?) -> ()){
        
        if let userId = firebaseUser?.uid{//partnersIds, ids of people that the user has chat with.
            rootRefDatabase.child("users/" + userId + "/partnersIds").observeSingleEvent(of: .value, with: {
                snapshot in
                if let partnersIdDictionary = snapshot.value as? [String: Any]{
                    if !partnersIdDictionary.keys.contains(partnerId){
                        
                        let chatId = rootRefDatabase.child("chats").childByAutoId()//it adds a unique id.
                        rootRefDatabase.child("chats").child(chatId.key).setValue(true)//it adds true as value of chats/chatId
                        
                        rootRefDatabase.child("users/" + userId + "/partnersIds").updateChildValues([partnerId: chatId.key])
                        rootRefDatabase.child("users/" + partnerId + "/partnersIds").updateChildValues([userId: chatId.key])
                        rootRefDatabase.child("users/" + userId + "/chatsId").updateChildValues([chatId.key: true])
                        rootRefDatabase.child("users/" + partnerId + "/chatsId").updateChildValues([chatId.key: true])
                        
                        self.addChatsMembers(chatId: chatId.key, userId: partnerId)
                        self.addChatsMembers(chatId: chatId.key, userId: userId)
                        
                        completionHandler(chatId.key)
                    }
                    else{
                        completionHandler( partnersIdDictionary[partnerId] as? String)
                    }
                }
                else{
                    let chatId = rootRefDatabase.child("chats").childByAutoId()//it adds a unique id.
                    rootRefDatabase.child("chats").child(chatId.key).setValue(true)//it adds true as value of chats/chatId
                    
                    rootRefDatabase.child("users/" + userId + "/partnersIds").updateChildValues([partnerId: chatId.key])
                    rootRefDatabase.child("users/" + partnerId + "/partnersIds").updateChildValues([userId: chatId.key])
                    rootRefDatabase.child("users/" + userId + "/chatsId").updateChildValues([chatId.key: true])
                    rootRefDatabase.child("users/" + partnerId + "/chatsId").updateChildValues([chatId.key: true])
                    self.addChatsMembers(chatId: chatId.key, userId: partnerId)
                    self.addChatsMembers(chatId: chatId.key, userId: userId)

                    completionHandler(chatId.key)
                }
            })
        }
    }
    
    static func getChats(completionHandler: @escaping (_ chat: Chat) -> () ){
        rootRefDatabase.child("users/" + (firebaseUser?.uid)! + "/partnersIds").observe( .value, with: {
            snapshot in
            if let partnersDictionary = snapshot.value as? [String: String]{
                for (_, value) in partnersDictionary{
                    rootRefDatabase.child("chats/" + value).observe( .value, with: {
                        snapshotChats in
                        if let chatsDictionary = snapshotChats.value as? [String: Any]{
                            let chat = Chat(id: value, pic: nil,
                                            lastMessage: Message(id: chatsDictionary["id"] as! String, senderId: chatsDictionary["senderId"] as! String, senderName: chatsDictionary["senderName"] as! String,
                                                text: chatsDictionary["text"] as! String,
                                                timeStamp: chatsDictionary["timeStamp"] as! Float))
                            completionHandler(chat)
                        }
                    })
                }
            }
        })
    }
    
    static func getPicToChat(chatId: String, completionHandler: @escaping (_ picChat: Data?) -> ()){
        rootRefDatabase.child("chatsMembers/").child(chatId).observeSingleEvent(of: .value, with: {
            chatMembersSnapshot in
            if let chatMembersDictionary = chatMembersSnapshot.value as? [String: String]{
                let chatMembersKeys = Array(chatMembersDictionary.keys)
                for chatMembersKey in chatMembersKeys{
                    if chatMembersKey != self.firebaseUser?.uid{
                        //get pic..
                        self.getThumbnail(url: chatMembersDictionary[chatMembersKey]!, completitionHandler: {
                            pictureData in
                            completionHandler(pictureData)
                                                            
                        })
                    }
                }
            }
        })
    }
    
    static func getPartnerData(chatId: String, completionHandler: @escaping (_ partnerData:[String: String]? ) -> ()){
        rootRefDatabase.child("chatsMembers/").child(chatId).observeSingleEvent(of: .value, with: {
            chatMembersSnapshot in
            if let chatMembersDictionary = chatMembersSnapshot.value as? [String: String]{
                chatMembersDictionary.forEach{
                    userId , pictureUrl in
                    if userId != self.firebaseUser?.uid{
                        completionHandler( [userId: pictureUrl] )
                    }
                }
            }
            completionHandler(nil)
        })
    }
    
    static func getChatId(eventCreatorId: String,completionHandler: @escaping (_ chatId: String) -> ()){
        rootRefDatabase.child("chatsMembers").observeSingleEvent(of: .value, with: {
            snapshot in
            if let chatsMembersDictionary = snapshot.value as? [String: Any]{
                print(chatsMembersDictionary)
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
        rootRefDatabase.child("messages/" + chatId).observe( .childAdded, with: {
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
                print(firebaseUser?.displayName ?? "anominos")
            }
        })
    }
    
    
    static func getPictureProfile(picAddress: String, completitionHandler: @escaping (_ picture: Data?) -> ()){
        let picUrl = URL(string: picAddress)!
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: picUrl) {
            (data, response, error) in
            if let error = error {
                print("Error downloading cat picture: \(error)")
                completitionHandler(nil)
            } else {
                // It would be weird if we didn't have a response, so check for that too.
                if let _ = response as? HTTPURLResponse {
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
    
    static func getThumbnail(url: String, completitionHandler: @escaping(_ thumbnailData: Data?) -> ()){
        let range = url.startIndex..<url.endIndex
        let httpReference = FIRStorage.storage().reference(forURL: url.substring(with: range))
        httpReference.data(withMaxSize: 1 * 1024 * 1024, completion: {
            data, error in
            if error != nil || data == nil{
                print(error!.localizedDescription)
                completitionHandler(nil)
            }
            else{
                completitionHandler(data)
            }
        })
        
    }
    
    static func addChatsMembers(chatId: String, userId: String){
        rootRefDatabase.child("users/" + userId + "/picURL").observeSingleEvent(of: .value, with: {
            thumbnailURLsnapshot in
            let thumbnailURL = thumbnailURLsnapshot.value as! String
            rootRefDatabase.child("chatsMembers").child(chatId).updateChildValues(
                [userId: thumbnailURL])
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

extension UIImage
{
    func resizeToBoundingSquare(boundingSquareSideLength : CGFloat) -> UIImage
    {
        let imgScale = self.size.width > self.size.height ? boundingSquareSideLength / self.size.width : boundingSquareSideLength / self.size.height
        let newWidth = self.size.width * imgScale
        let newHeight = self.size.height * imgScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(newSize)
        
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return resizedImage!
    }
    
}

//let rawImage = UIImage(data: imageData)
//let thumbnailData = UIImageJPEGRepresentation((rawImage?.resizeToBoundingSquare(boundingSquareSideLength: 32.0))!, 0.7)
//FirebaseHelper.saveThumbnail(userId: id,
//                             thumbnail: thumbnailData!, completionHandler: nil)
