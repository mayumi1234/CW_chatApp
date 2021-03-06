//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/25.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD
import AVFoundation

class ChatRoomViewController: UIViewController {
    
    var chatroom: ChatRoom?
    var message: Message?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    private var chatrooms = [ChatRoom]()
    
    private let accessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 100, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 100, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    private lazy var chatInputAccessoryView: ChatInputAccesaryView = {
        let view = ChatInputAccesaryView(chatroom: chatroom)
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMessages()
        setupChatRoomTableView()
        setupNotification()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBackgroundImage()
        self.chatInputAccessoryView.setupSound()
        self.chatRoomTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
    }
    
    private func setupNavigationBar() {
//        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = chatroom?.partnername
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func setupBackgroundImage() {
        guard let urlString = chatroom?.backgroundImageUrl else { return }
        guard let url = URL(string: urlString) else { return }
        do {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.chatRoomTableView.frame.width, height: self.chatRoomTableView.frame.height))
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            imageView.image = image
            imageView.alpha = 0.5
            self.chatRoomTableView.backgroundView = imageView
            self.chatRoomTableView.backgroundView?.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
         }catch let err {
              print("Error : \(err.localizedDescription)")
         }
    }
    
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.allowsSelection = false
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 176, green: 224, blue: 230)
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        chatRoomTableView.reloadData()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessoryHeight { return }
            
            let bottom = keyboardFrame.height - safeAreaBottom
            var moveY = -(bottom - chatRoomTableView.contentOffset.y)
            if chatRoomTableView.contentOffset.y != -60 { moveY += 60 }
            let contentInset = UIEdgeInsets(top: bottom, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            if moveY > -500 {
                chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
            }
        }
    }
    
    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
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
        settingViewController.chatroom = chatroom
        settingViewController.messages = messages
        let nav = UINavigationController(rootViewController: settingViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    let chatroom = ChatRoom(dic: dic)
                    message.imageUrl = self.chatroom?.profileImageUrl as! String
                    chatroom.profileImageUrl = self.chatroom?.profileImageUrl as! String
                    chatroom.backgroundImageUrl = self.chatroom?.backgroundImageUrl as! String
                    chatroom.soundUrl = self.chatroom?.soundUrl as! String
                    self.messages.append(message)
                    self.chatrooms.append(chatroom)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.chatRoomTableView.reloadData()
//                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom , animated: false)
                    
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
        chatInputAccessoryView.removeText()
        
        let docData = [
            "myname": valueString().1,
            "createdAt": Timestamp(),
            "message": text
            ] as [String : Any]
        
        messageFirestore(messageId: valueString().2, docData: docData, chatroomDocId: valueString().3)
        
    }
    
    private func addPartnerMessageToFirestore(text: String) {
        chatInputAccessoryView.removeText()
        
        let docData = [
            "partnername": valueString().0,
            "createdAt": Timestamp(),
            "message": text
            ] as [String : Any]
        
        messageFirestore(messageId: valueString().2, docData: docData, chatroomDocId: valueString().3)
    }
    
    private func valueString()  -> (String, String, String, String){
        let chatroomDocId = chatroom?.documentId
        let parnername = chatroom?.partnername
        let myname = chatroom?.myname
        let messageId = UIViewController.randomString(length: 20)
        
        return (parnername!, myname!, messageId, chatroomDocId!)
    }
    
    private func messageFirestore(messageId: String, docData: [String : Any], chatroomDocId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            let latestMessageData = [
                "latestMessage": Timestamp()
            ]
            db.collection("users").document(uid).collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                if let err = err {
                    print("最新メッセージの保存に失敗しました。\(err)")
                    return
                }
                print("メッセージの保存に成功しました。")
            }
        }
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
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messages[indexPath.row]
        return cell
    }
}
