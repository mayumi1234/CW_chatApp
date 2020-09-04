//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/29.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import FirebaseFirestore

class ChatRoom {
    
    var partnername: String
    var myname: String
    var profileImageUrl: String
    var documentId: String?
    var backgroundImageUrl: String?
    var soundUrl: String?
    var latestMessage: Timestamp
    
    init(dic: [String: Any]) {
        self.partnername = dic["partnername"] as? String ?? ""
        self.myname = dic["myname"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.backgroundImageUrl = dic["backgroundImageUrl"] as? String ?? ""
        self.soundUrl = dic["soundUrl"] as? String ?? ""
        self.latestMessage = dic["latestMessage"] as? Timestamp ?? Timestamp()
    }
    
}
