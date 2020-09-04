//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/25.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    var message: Message?
    var chatroom: ChatRoom?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var myMessageWidth: NSLayoutConstraint!
    @IBOutlet weak var partnerName: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 20
        textView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkWhichUserMessage()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    private func checkWhichUserMessage() {
//        自分が入力した時
        if message?.myname != "" {
            textView.isHidden = true
            label.isHidden = true
            userImageView.isHidden = true
            partnerName.isHidden = true
            
            myMessageTextView.isHidden = false
            myTimeLabel.isHidden = false
//            myName.isHidden = false
            readLabel.isHidden = false
            
            if let message = message {
//                myName.text = message.myname
                myMessageTextView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                myMessageWidth.constant = witdh
                myTimeLabel.text = UIView.dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
            
        } else {
//    相手が入力した時
            textView.isHidden = false
            label.isHidden = false
            userImageView.isHidden = false
            partnerName.isHidden = false

            myMessageTextView.isHidden = true
            myTimeLabel.isHidden = true
            myName.isHidden = true
            readLabel.isHidden = true
            
            if let urlString = message?.imageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }

            if let message = message {
                partnerName.text = message.partnername
                textView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                textViewWidth.constant = witdh

                label.text = UIView.dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        }
    }
    
//    テキスト量に反映して、高さを調整
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }

}
