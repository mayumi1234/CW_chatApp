//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/29.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class ChatRoom {
    
//    let latestMessageId: String
//    let memebers: [String]
//    let createdAt: Timestamp
    
    var username: String
    var profileImageUrl: String
    
    var latestMessage: Message?
    var partnerUser: User?
    var documentId: String?
    
    init(dic: [String: Any]) {
        self.username = dic["username"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
//        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
