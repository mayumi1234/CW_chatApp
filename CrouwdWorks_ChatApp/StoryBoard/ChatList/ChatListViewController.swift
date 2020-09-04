//
//  ChatListViewController.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/24.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD
import Nuke

class ChatListViewController: UIViewController {

    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var chatRoomListener: ListenerRegistration?

    @IBOutlet weak var chatListTableView: UITableView!
    @IBOutlet weak var startCnversationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil { // ログインしてない時
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            let nav = UINavigationController(rootViewController: signUpViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
        self.chatListTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.chatrooms.removeAll()
        
        setupViews()
        fetchUserInfoFromFirestore()
        
        self.chatListTableView.reloadData()
        
        if let indexPathForSelectedRow = chatListTableView.indexPathForSelectedRow {
            chatListTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func fetchUserInfoFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("chatRooms")
            .addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("chatrooms情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    self.handleAddedDocumentChange(documentChange: documentChange)
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }

    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        self.chatrooms.insert(chatroom, at: 0)
        self.chatrooms.sort { (m1, m2) -> Bool in
            let m1Date = m1.latestMessage.dateValue()
            let m2Date = m2.latestMessage.dateValue()
            return m1Date > m2Date
        }
        self.chatListTableView.reloadData()
    }

    func setupViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self

        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNaviPrivateRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        let leftBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedNaviPrivateLeftBarButton))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    @objc private func tappedNaviPrivateLeftBarButton() {
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
        } catch {
            print("ログアウトに失敗しました。 \(error)")
            HUD.flash(.labeledError(title: "ログアウトに失敗しました。", subtitle: "\(error)"), delay: HUDTime)
        }
    }
    
    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signupViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signupViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    @objc private func tappedNaviPrivateRightBarButton() {
        let storyboard = UIStoryboard.init(name: "MadeChatroom", bundle: nil)
        let MadeChatroomViewController = storyboard.instantiateViewController(withIdentifier: "MadeChatroomViewController")
        let nav = UINavigationController(rootViewController: MadeChatroomViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

class ChatListTableViewCell: UITableViewCell {
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                nameLabel.text = chatroom.partnername
                if let url = URL(string: chatroom.profileImageUrl ) {
                    Nuke.loadImage(with: url, into: userImageView)
                }
            }
        }
    }

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.layer.cornerRadius = 35
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
