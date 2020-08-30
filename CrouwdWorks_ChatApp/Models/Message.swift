//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/29.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//
import FirebaseFirestore

class Message {
    
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    let flag: String
    
    var imageUrl: String
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.flag = dic["flag"] as? String ?? ""
        self.imageUrl = dic["imageUrl"] as? String ?? ""
    }
    
}
