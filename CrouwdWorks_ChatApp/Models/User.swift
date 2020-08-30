//
//  User.swift
//  CrouwdWorks_ChatApp
//
//  Created by m.yamanishi on 2020/08/30.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

class User {
    var username: String
    var email: String
    var profileImageUrl: String
    
    init(dic: [String: Any]) {
        self.username = dic["username"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
    
}
