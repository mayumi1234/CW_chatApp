//
//  SignUpViewController.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/26.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class MadeChatroomViewController: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var madeChatRoomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setUpViews() {
        imageButton.layer.borderWidth = 1
        imageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        imageButton.addTarget(self, action: #selector(pushOnImageButton), for: .touchUpInside)
        madeChatRoomButton.addTarget(self, action: #selector(pushOnRegisterButton), for: .touchUpInside)
        userNameTextField.delegate = self
        
        madeChatRoomButton.isEnabled = false
        madeChatRoomButton.backgroundColor = UIColor.rgb(red: 100, green: 100, blue: 100)
    }
    
    @objc private func pushOnImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
//    イメージをFirestoreに保存する
    @objc private func pushOnRegisterButton() {
        guard let image = imageButton.imageView?.image else { return }
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
                self.createUserToFirestore(profileImageUrl: urtString)
            }
        }

    }
    
    private func createUserToFirestore(profileImageUrl: String) {
        guard let username = self.userNameTextField.text else { return }

        let docData = [
            "username": username,
            "profileImageUrl": profileImageUrl
            ] as [String : Any]

        let documentID = UIViewController.randomString(length: 20)

        Firestore.firestore().collection("chatRooms").document(documentID).setData(docData) { (err) in
            if let err = err {
                print("Firestoreへの保存に失敗しました。\(err)")
                return
            }
            print("Firestoreへの保存が成功しました。")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension MadeChatroomViewController: UITextFieldDelegate {
    
//    TFが空欄のときのレジスターボタンの処理
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? false
        
        if userNameIsEmpty {
            madeChatRoomButton.isEnabled = false
            madeChatRoomButton.backgroundColor = UIColor.rgb(red: 100, green: 100, blue: 100)
        } else {
            madeChatRoomButton.isEnabled = true
            madeChatRoomButton.backgroundColor = UIColor.rgb(red: 0, green: 185, blue: 0)
        }
    }
    
    //    キーボード以外をタップしてキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension MadeChatroomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    写真を設定するときの関数
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            imageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            imageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        imageButton.setTitle("", for: .normal)
        imageButton.imageView?.contentMode = .scaleAspectFill
        imageButton.contentHorizontalAlignment = .fill
        imageButton.contentVerticalAlignment = .fill
        imageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
