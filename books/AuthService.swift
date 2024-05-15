//
//  AuthService.swift
//  books
//
//  Created by user on 15.05.24.
//

import Foundation
import Firebase

class InAppAuth{
    
    func signUp(email: String, password: String, name: String){
        Firebase.Auth.auth().createUser(withEmail: email, password: password,
                                        completion: {user, error in
            if let error = error as NSError? {
                print(error)
            } else{
                let uid = Firebase.Auth.auth().currentUser?.uid;
                
                let user = User(name: name, email: email, dateOfBirth: "", gender: "", occupation: "", city: "", country: "", phoneNumber: "", age: 10, maritalStatus: "free");
                
                var db = Database.database().reference().child(uid!);
                db.setValue(user.toJson());
                
                db = Database.database().reference().child("prefs");
                
                if let uid = Auth.auth().currentUser?.uid {
                    let userRef = db.child(uid)
                    userRef.setValue([])
                }
                
            }
        })
    }
    
    
    func signIn(email: String, password: String){
        Firebase.Auth.auth().signIn(withEmail: email, password: password, completion: {user, error in
            if let error = error as NSError? {
                print(error)
            }
        })
    }
}
