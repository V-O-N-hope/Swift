//
//  SignUpView.swift
//  books
//
//  Created by user on 15.05.24.
//

import Foundation
import SwiftUI
import Firebase

struct SignUpView: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @EnvironmentObject var appPage: PageState
    @EnvironmentObject var auth: AuthState
    var body: some View {
        Text("Sign Up").padding().onAppear{
            if Auth.auth().currentUser != nil {
                auth.authorized  = true
                appPage.page = PageEnum.ITEMS
            }
        }
        TextField("Enter name",text: $name).padding().overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
        ).padding()
        TextField("Enter email",text: $email).padding().overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
        ).padding()
        SecureField("Enter password",text: $password).padding().overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
        ).padding()
        Button (
        action: {
            InAppAuth().signUp(email:email,password:password, name: name)
        auth.authorized = true
        appPage.page = PageEnum.ITEMS
        },label: { Text("Sign Up").foregroundColor(.white)}).padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .background(Color(.blue))
            .clipShape(Capsule())
        
        Button(action: {appPage.page = PageEnum.SIGNIN}, label: {Text("Already have an account? Sign in")}).padding()
    }
    public init(email:String,password:String){
        self.password = password
        self.email = email
    }
}
