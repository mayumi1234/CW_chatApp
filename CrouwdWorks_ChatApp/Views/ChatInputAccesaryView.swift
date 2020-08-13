//
//  ChatInputAccesaryView.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/25.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

protocol ChatInputAccesaryViewDelegate: class {
    func tappedMySendButton(text: String)
    func tappedPartnerSendButton(text: String)
}

class ChatInputAccesaryView: UIView {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var partnerButton: UIButton!
    weak var delegate: ChatInputAccesaryViewDelegate?
    var audioPlayerInstance : AVPlayer! = nil
    var chatroom: ChatRoom?
    
    convenience init(chatroom: ChatRoom?) {
        self.init(frame: .zero)
        
        self.chatroom = chatroom
        
        nibInit()
        setUpViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupSound() {
        guard let urlString = chatroom?.soundUrl else { return }
        guard let url = URL(string: urlString) else { return }
        
        do {
            audioPlayerInstance = AVPlayer(url: url)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
    }
    
    func removeText() {
        textView.text = ""
        myButton.isEnabled = false
        partnerButton.isEnabled = false
    }
    
    private func setUpViews() {
        
        textView.layer.cornerRadius = 15
        textView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        textView.layer.borderWidth = 1
        textView.text = ""
        textView.delegate = self
        
        myButton.layer.cornerRadius = 15
        myButton.isEnabled = false
        
        partnerButton.layer.cornerRadius = 15
        partnerButton.isEnabled = false
        
        autoresizingMask = .flexibleHeight
        
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccesaryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    @IBAction func pushOnMyButton(_ sender: Any) {
        guard let text = textView.text else { return }
        delegate?.tappedMySendButton(text: text)
        let time = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
        audioPlayerInstance.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        audioPlayerInstance.play()
    }
    
    @IBAction func pushOnPartnerButton(_ sender: Any) {
        guard let text = textView.text else { return }
        delegate?.tappedPartnerSendButton(text: text)
        let time = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
        audioPlayerInstance.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        audioPlayerInstance.play()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ChatInputAccesaryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            myButton.isEnabled = false
            partnerButton.isEnabled = false
        } else {
            myButton.isEnabled = true
            partnerButton.isEnabled = true
        }
    }
    
}
