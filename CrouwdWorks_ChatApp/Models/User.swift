//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/27.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

//このクラスは使用していないので、気にしないでください
class User {
    
    let email: String
    var username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
    
}
