//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/25.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ChatRoomViewController: UIViewController {
    
    var user: User?
    var chatroom: ChatRoom?
    var message: Message?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    private var users = [User]()
    private var chatrooms = [ChatRoom]()
    
    private lazy var chatInputAccessoryView: ChatInputAccesaryView = {
        let view = ChatInputAccesaryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        
        chatRoomTableView.allowsSelection = false
        
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        
        chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 80, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 80, right: 0)
        
        fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.chatRoomTableView.reloadData()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Setting", bundle: nil)
        let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        settingViewController.documentId = chatroom?.documentId
//        settingViewController.message? = self.messages
        let nav = UINavigationController(rootViewController: settingViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
//    private func fetchUserInfoFromFirestore() {
//        Firestore.firestore().collection("chatRooms")
//            .addSnapshotListener { (snapshots, err) in
//            if let err = err {
//                print("chatrooms情報の取得に失敗しました。\(err)")
//                return
//            }
//
//            snapshots?.documentChanges.forEach({ (documentChange) in
//                switch documentChange.type {
//                case .added:
//                    self.handleAddedDocumentChange(documentChange: documentChange)
//                case .modified, .removed:
//                    print("nothing to do")
//                }
//            })
//        }
//    }
//
//    private func handleAddedDocumentChange(documentChange: DocumentChange) {
//        let dic = documentChange.document.data()
//        let chatroom = ChatRoom(dic: dic)
//        chatroom.documentId = documentChange.document.documentID
//
//        self.chatrooms.insert(chatroom, at: 0)
//        self.chatRoomTableView.reloadData()
//    }
    
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    message.imageUrl = self.chatroom?.profileImageUrl
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                    self.chatRoomTableView.reloadData()
                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
        
}

extension ChatRoomViewController: ChatInputAccesaryViewDelegate {
    
    func tappedMySendButton(text: String) {
        addMyMessageToFirestore(text: text)
    }
    
    func tappedPartnerSendButton(text: String) {
        addPartnerMessageToFirestore(text: text)
    }
    
    private func addMyMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = chatroom?.username else { return }
        chatInputAccessoryView.removeText()
        
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "message": text,
            "flag": "0" // ０のとき自分が送った
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            let latestMessageData = [
                "latestMessageId": messageId
            ]
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                if let err = err {
                    print("最新メッセージの保存に失敗しました。\(err)")
                    return
                }
                print("メッセージの保存に成功しました。")
            }
        }
    }
    
    private func addPartnerMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = chatroom?.username else { return }
        chatInputAccessoryView.removeText()
        
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "message": text,
            "flag": "1" //1のとき相手が送った
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            
            let latestMessageData = [
                "latestMessageId": messageId
            ]
            
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                if let err = err {
                    print("最新メッセージの保存に失敗しました。\(err)")
                    return
                }
                
                print("メッセージの保存に成功しました。")
                
            }
        }
        
    }
    
    func randomString(length: Int) -> String {
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

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
}
