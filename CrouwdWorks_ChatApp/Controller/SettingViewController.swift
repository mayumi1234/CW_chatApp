//
//  SettingViewController.swift
//  CrouwdWorks_ChatApp
//
//  Created by m.yamanishi on 2020/06/10.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    var message: Message?
    var chatroom: ChatRoom?
    
    var documentId: String?
    var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iconSelectButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func backGroundSelectButton(_ sender: Any) {
    }
    
    @IBAction func musicSelectButton(_ sender: Any) {
    }
    
    @IBAction func settingButton(_ sender: Any) {
        guard let image = iconButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let strageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        strageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firestorageへの情報の保存に失敗しました。\(err)")
                return
            }
            print("Firestorageへの情報の保存に成功しました。")
            strageRef.downloadURL { (url, err) in
                if let err = err {
                    print("FireStorageからのダウンロードに失敗しました。")
                    return
                }

                guard let urtString = url?.absoluteString else { return }
                self.urlFunction(profileImageUrl: urtString)
            }
        }
    }
    
    private func urlFunction(profileImageUrl: String) {
        guard let chatroomDocId = self.documentId else { return }
        
        let ImageUrl = [
            "profileImageUrl": profileImageUrl
        ]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(ImageUrl) { (err) in
            if let err = err {
                print("最新イメージの保存に失敗しました。\(err)")
                return
            }
            print("最新イメージの保存に成功しました。")
        }
        
        message?.imageUrl = profileImageUrl
        chatroom?.profileImageUrl = profileImageUrl
        chatroom?.flag = "1"
//        アイコンを変えるたびに、dismissした後のチャットルームで、メッセージを送信すると、アイコン変更回数につれて表示されるセルが増えてゆく
//        また、もう一度アイコンを変えてチャットルーム画面に戻ると、表示は正しくされる
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    写真を設定するときの関数
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            iconButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            iconButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        iconButton.setTitle("", for: .normal)
        iconButton.imageView?.contentMode = .scaleAspectFill
        iconButton.contentHorizontalAlignment = .fill
        iconButton.contentVerticalAlignment = .fill
        iconButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
