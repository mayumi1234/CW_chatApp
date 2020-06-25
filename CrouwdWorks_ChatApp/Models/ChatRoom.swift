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
    
    var username: String
    var profileImageUrl: String
    
    var latestMessage: Message?
    var documentId: String?
    var flag: String?
    
    init(dic: [String: Any]) {
        self.username = dic["username"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
//        self.flag = dic["flag"] as? String ?? "0" // 初期値は画像の変更なし
    }
    
}
