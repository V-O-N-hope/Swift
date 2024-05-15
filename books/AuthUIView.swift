//
//  AuthUIView.swift
//  books
//
//  Created by user on 15.05.24.
//

import Foundation
import SwiftUI
import Firebase

struct AuthUIView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var appPage: PageState
    @EnvironmentObject var auth: AuthState
    
    var body: some View {
        ScrollView{
            Text("Sign In:").font(.system(size:25)).padding()
        VStack{
        Text("Email:").padding().onAppear{
            if Auth.auth().currentUser != nil {
                auth.authorized = true
                appPage.page = PageEnum.PROFILE
            }
        }
        TextField("Enter email",text: $email).padding().overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
        ).padding()
        Text("Password:").padding()
        SecureField("Enter password",text: $password).padding().overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
        ).padding()
        }
        Button (
        action: {
        InAppAuth().signIn(email:email,password:password)
        auth.authorized = true
        appPage.page = PageEnum.PROFILE
        },label: { Text("Sign In").foregroundColor(.white)})
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .background(Color(.blue))
            .clipShape(Capsule())
            
        Button(action: {appPage.page = PageEnum.SIGNUP}, label: {Text("No account? Sign up")}).padding()
        }
    }
    public init(email:String,password:String){
        self.password = password
        self.email = email
    }
}
