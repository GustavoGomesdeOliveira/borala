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
    
    static func saveProfilePic(userId : String, pic: Data, completionHandler:((_ error: Error?) -> ())? ){
        let profilePicRef = rootRefStorage.child("/users/\(userId)/profilePic.jpg")
        let _ = profilePicRef.put(pic, metadata: nil) {
            metadata, error in
            if let errorOnPutData = completionHandler{
                errorOnPutData(error)
            }
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
    
    static func registerMeOnline(id: String){
        let currentUserRef = rootRefDatabase.child("onlineUser/" + id)
        currentUserRef.setValue(true)
        currentUserRef.onDisconnectRemoveValue()
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
