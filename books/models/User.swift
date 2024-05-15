//
//  User.swift
//  books
//
//  Created by user on 15.05.24.
//

import Foundation

struct User {
    var name: String
    var email: String
    var dateOfBirth: String
    var gender: String
    var occupation: String
    var city: String
    var country: String
    var phoneNumber: String
    var age: Int
    var maritalStatus: String
    
    init() {
        self.name = ""
        self.email = ""
        self.dateOfBirth = ""
        self.gender = ""
        self.occupation = ""
        self.city = ""
        self.country = ""
        self.phoneNumber = ""
        self.age = 0
        self.maritalStatus = ""
    }
    
    init(name: String, email: String, dateOfBirth: String, gender: String, occupation: String, city: String, country: String, phoneNumber: String, age: Int, maritalStatus: String) {
            self.name = name
            self.email = email
            self.dateOfBirth = dateOfBirth
            self.gender = gender
            self.occupation = occupation
            self.city = city
            self.country = country
            self.phoneNumber = phoneNumber
            self.age = age
            self.maritalStatus = maritalStatus
        }
        
    
    func toJson() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            "occupation": occupation,
            "city": city,
            "country": country,
            "phoneNumber": phoneNumber,
            "age": age,
            "maritalStatus": maritalStatus
        ]
    }
}
