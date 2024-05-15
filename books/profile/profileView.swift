//
//  profileView.swift
//  books
//
//  Created by user on 15.05.24.
//

import SwiftUI
import Foundation
import Firebase

struct profileView: View {
    @State private var isDelete: Bool = false
    @State private var isLogOut: Bool = false
    @State private var user:User  = User()
    
    @EnvironmentObject var appPage: PageState
    @EnvironmentObject var auth: AuthState
    
    var body : some View {
        Spacer().onAppear{
            if !auth.authorized {
                appPage.page = PageEnum.SIGNIN
            }
            getProfileDataFromDB()
        }
        VStack{
            VStack{
                Image(systemName:"person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                HStack{
                    Text(user.name)
                }
            }
            VStack{
                HStack{
                    Text("Name")
                    Text(user.name)
                }
                HStack{
                    Text("Email")
                    Text(user.email)
                }
                HStack{
                    Text("Date of birth")
                    TextField("Enter your date of birth",text: $user.dateOfBirth)
                }
                HStack {
                    Text("Gender")
                    TextField("Enter your gender", text: $user.gender)
                }
                HStack {
                    Text("Occupation")
                    TextField("Enter your occupation", text: $user.occupation)
                }
                HStack {
                    Text("City")
                    TextField("Enter your city", text: $user.city)
                }
                HStack {
                    Text("Country")
                    TextField("Enter your country", text: $user.country)
                }
                HStack {
                    Text("Phone Number")
                    TextField("Enter your phone number", text: $user.phoneNumber)
                }
                HStack {
                    Text("Age")
                    TextField("Enter your age", value: $user.age, formatter: NumberFormatter())
                }
                HStack {
                    Text("Marital Status")
                    TextField("Enter your marital status", text: $user.maritalStatus)
                }
            }
        }.padding()
        
        Button(action: updateProfileData, label: {Text("Save data")})
        
        Button(action: {isDelete = true}, label: {
            Text("Delete Account")
                .foregroundColor(.white)
                .bold()
        }).alert(isPresented: $isDelete, content: {
            Alert(
                title: Text("Account deletion"),
                message: Text("Are you sure to delete your account(all information will be lost, you cannot undo this action)?"),
                primaryButton: .destructive(Text("Delete")){
                    
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let db = Firestore.firestore()
                        db.collection(user.uid).getDocuments{(snapshot,error) in
                            if let error = error {
                                print("\(error)")
                            }
                            guard let snapshot = snapshot else {
                                return
                            }
                            for document in snapshot.documents{
                                let docRef = db.collection(user.uid).document(document.documentID)
                                docRef.delete{error in
                                    if let error = error {
                                        print("\(error)")
                                    }
                                }
                            }
                        }
                        user.delete{error in
                            if let error = error {
                                print("\(error)")
                            } else {
                                
                            }
                        }
                    }else {
                    }
                    auth.authorized = false
                    appPage.page = PageEnum.SIGNIN
                },
                secondaryButton: .cancel()
            )
        })
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .background(Color(red:1,green:0,blue:0))
        .clipShape(Capsule())
        
        Button(action:{
            isLogOut = true
        },label:{
            Text("Log Out")
                .foregroundColor(.white)
                .bold()
        }).alert(isPresented: $isLogOut, content: {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure to log out of your account?"),
                primaryButton: .destructive(Text("Log Out")){
                    do {
                        try Auth.auth().signOut()
                        auth.authorized = false
                        appPage.page = PageEnum.SIGNIN
                    } catch {
                        // error alert handling
                    }
                },
                secondaryButton: .cancel()
            )
        })
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .background(Color(red:1,green:0,blue:0))
        .clipShape(Capsule())
        Spacer()
        HStack{
            Spacer()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                VStack{
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                    Text("Profile")
                        .font(.system(size:14))
                }
            }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .frame(height:50)
            Spacer()
            Button(action: {updateProfileData()
                appPage.page = PageEnum.ITEMS
            }, label: {
                VStack{
                    Image(systemName: "list.bullet")
                        .resizable()
                        .scaledToFit()
                    Text("Items")
                        .font(.system(size:14))
                }
                
            }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .frame(height:50)
            Spacer()
            Button(action: {updateProfileData()
                appPage.page = PageEnum.FEATURED
            }, label: {
                VStack{
                    Image(systemName: "star.circle")
                        .resizable()
                        .scaledToFit()
                    Text("Featured")
                        .font(.system(size:14))
                }
                
            }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .frame(height:50)
            Spacer()
        }.frame(height: 50, alignment: .bottom)
    }
    
    private func getProfileDataFromDB() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Unauthorized user")
            return
        }
        
        let uid = currentUser.uid
        let db = Database.database().reference().child("users").child(uid)
        
        db.observeSingleEvent(of: .value) { (snapshot) in
            if let profileData = snapshot.value as? [String: Any] {
                if let user = self.createUserFromData(profileData) {
                    self.user = user
                } else {
                    print("Failed to create User from data")
                }
            } else {
                print("Data not found at /users/\(uid)/")
            }
        }
    }
    
    private func createUserFromData(_ data: [String: Any]) -> User? {
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String,
            let dateOfBirth = data["dateOfBirth"] as? String,
            let gender = data["gender"] as? String,
            let occupation = data["occupation"] as? String,
            let city = data["city"] as? String,
            let country = data["country"] as? String,
            let phoneNumber = data["phoneNumber"] as? String,
            let age = data["age"] as? Int,
            let maritalStatus = data["maritalStatus"] as? String
        else {
            return nil
        }
        
        return User(name: name, email: email, dateOfBirth: dateOfBirth, gender: gender, occupation: occupation, city: city, country: country, phoneNumber: phoneNumber, age: age, maritalStatus: maritalStatus)
    }
    
    private func updateProfileData() {
        // Получаем ссылку на базу данных Firebase
        let databaseRef = Database.database().reference()
        
        // Создаем словарь с данными пользователя
        let userData = user.toJson()
        
        // Обновляем данные пользователя в Firebase
        if let userId = Auth.auth().currentUser?.uid {
            let userRef = databaseRef.child("users").child(userId)
            userRef.setValue(userData) { error, _ in
                if let error = error {
                    print("Error updating user data: \(error)")
                } else {
                    print("User data updated successfully")
                }
            }
        } else {
            print("User is not authenticated")
        }
    }
}

