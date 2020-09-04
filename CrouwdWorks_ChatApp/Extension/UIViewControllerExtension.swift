//
//  DateExtension.swift
//  CrouwdWorks_ChatApp
//
//  Created by m.yamanishi on 2020/08/13.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import FirebaseFirestore

let HUDTime = 1.0
let db = Firestore.firestore()
let screenHeight = Int(UIScreen.main.bounds.size.height)

extension UIViewController {
    
    static func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
