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
    var audioPlayerInstance : AVAudioPlayer! = nil
    var chatroom: ChatRoom?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setUpViews()
        setupSound()
    }
    
    private func setupSound() {
//        guard let urlString = chatroom?.soundUrl else { return }
//        guard let url = URL(string: urlString) else { return }
//        ここでchatroom?.soundUrlに値が入ってくれていない
        
        let soundFilePath = Bundle.main.path(forResource: "decision1", ofType: "mp3")!
        let sound:URL = URL(fileURLWithPath: soundFilePath)
        
        do {
            audioPlayerInstance = try AVAudioPlayer(contentsOf: sound, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        
        audioPlayerInstance.prepareToPlay()
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
        audioPlayerInstance.currentTime = 0         // 再生箇所を頭に移す
        audioPlayerInstance.play()
    }
    
    @IBAction func pushOnPartnerButton(_ sender: Any) {
        guard let text = textView.text else { return }
        delegate?.tappedPartnerSendButton(text: text)
        audioPlayerInstance.currentTime = 0         // 再生箇所を頭に移す
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
