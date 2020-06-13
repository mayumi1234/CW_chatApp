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
    
//    var chatroom: ChatRoom?
    var message: Message?
    
    private var messages = [Message]()
    
    var documentId: String?
    
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
        
//        self.dismiss(animated: true, completion: nil)
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
        
        print(profileImageUrl)
//        profileImageUrl
//        この値には正しい値が入っています。
        message?.imageUrl = profileImageUrl
//        この部分で、message?.imageUrlにnilが入ってしまう。
        print("signupviewcontroller: ", message?.imageUrl)
        
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
