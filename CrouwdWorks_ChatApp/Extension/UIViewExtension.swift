//
//  UIViewExtension.swift
//  CrouwdWorks_ChatApp
//
//  Created by m.yamanishi on 2020/08/13.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit

extension UIView {
    static func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
