//
//  SettingViewController.swift
//  CrouwdWorks_ChatApp
//
//  Created by m.yamanishi on 2020/06/10.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MediaPlayer

class SettingViewController: UIViewController {
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    
    var message: Message?
    var chatroom: ChatRoom?
    
    var mpMediapicker: MPMediaPickerController!
    var controller: UIDocumentInteractionController! = nil
    
    var messages = [Message]()
    
    var documentId: String?
    var imageUrl: String?
    var soundUrl: URL?
    
    var iconFlag = false
    var backImageFrag = false
    var soundFlag = false
    
    var settingIconFlag = false
    var settingBackImageFrag = false
    var settingSoundFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconButton.layer.cornerRadius = 75
        self.iconButton.layer.borderColor = UIColor.gray.cgColor
        self.iconButton.layer.borderWidth = 1
        
        self.backgroundButton.layer.cornerRadius = 75
        self.backgroundButton.layer.borderColor = UIColor.gray.cgColor
        self.backgroundButton.layer.borderWidth = 1
        
        self.musicButton.layer.cornerRadius = 75
        self.musicButton.layer.borderColor = UIColor.gray.cgColor
        self.musicButton.layer.borderWidth = 1
        
        self.changeButton.layer.cornerRadius = 5
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func iconSelectButton(_ sender: Any) {
        self.iconFlag = true
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func backGroundSelectButton(_ sender: Any) {
        self.backImageFrag = true
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func musicSelectButton(_ sender: Any) {
        self.soundFlag = true
        
        let soundPicker = UIDocumentPickerViewController(documentTypes: ["public.mp3" as String], in: UIDocumentPickerMode.open)
        soundPicker.delegate = self
        self.present(soundPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func settingButton(_ sender: Any) {
        if self.settingIconFlag == true {
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
        } else if self.settingBackImageFrag == true {
            guard let backgroundImage = backgroundButton.imageView?.image else { return }
            guard let uploadBackgroundImage = backgroundImage.jpegData(compressionQuality: 0.3) else { return }
            
            let backgroundFileName = NSUUID().uuidString
            let backgroundStrageRef = Storage.storage().reference().child("background_image").child(backgroundFileName)
            
            backgroundStrageRef.putData(uploadBackgroundImage, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Firestorageへの情報の保存に失敗しました。\(err)")
                    return
                }
                print("Firestorageへの情報の保存に成功しました。")
                backgroundStrageRef.downloadURL { (url, err) in
                    if let err = err {
                        print("FireStorageからのダウンロードに失敗しました。")
                        return
                    }
                    
                    guard let urtString = url?.absoluteString else { return }
                    self.backgroundUrlFunction(backgroundImageUrl: urtString)
                }
            }
        } else if self.settingSoundFlag == true {
            guard let pushSound = self.soundUrl else { return }
            guard let uploadPushSound: Data = pushSound.dataRepresentation else { return }
            
            let soundFileName = NSUUID().uuidString
            let soundStrageRef = Storage.storage().reference().child("push_sound").child(soundFileName)
            
            soundStrageRef.putData(uploadPushSound, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Firestorageへの情報の保存に失敗しました。\(err)")
                    return
                }
                print("Firestorageへの情報の保存に成功しました。")
                soundStrageRef.downloadURL { (url, err) in
                    if let err = err {
                        print("FireStorageからのダウンロードに失敗しました。")
                        return
                    }
                    
                    guard let urtString = url?.absoluteString else { return }
                    self.soundUrlFunction(pushSoundUrl: urtString)
                }
            }
            
        }
    }
    
    private func soundUrlFunction(pushSoundUrl: String) {
        guard let chatroomDocId = self.documentId else { return }
        
        let soundUrl = [
            "soundUrl": pushSoundUrl
        ]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(soundUrl) { (err) in
            if let err = err {
                print("最新イメージの保存に失敗しました。\(err)")
                return
            }
            print("最新イメージの保存に成功しました。")
        }
        
        chatroom?.soundUrl = pushSoundUrl
//        chatroom?.flag = "1"
        
        self.dismiss(animated: true, completion: nil)
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
        
//        message?.imageUrl = profileImageUrl
        chatroom?.profileImageUrl = profileImageUrl
//        chatroom?.flag = "1"
        
        messages.forEach { message in
        message.imageUrl = profileImageUrl
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func backgroundUrlFunction(backgroundImageUrl: String) {
        guard let chatroomDocId = self.documentId else { return }
        
        let ImageUrl = [
            "backgroundImageUrl": backgroundImageUrl
        ]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(ImageUrl) { (err) in
            if let err = err {
                print("最新イメージの保存に失敗しました。\(err)")
                return
            }
            print("最新イメージの保存に成功しました。")
        }
        
        //        message?.imageUrl = profileImageUrl
        chatroom?.backgroundImageUrl = backgroundImageUrl
//        chatroom?.flag = "1"
//
//        messages.forEach { message in
//            message.imageUrl = profileImageUrl
//        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url) // ここにURLが入っている
        
        if soundFlag == true {
            let theFileName: String = url.lastPathComponent
            musicButton.titleLabel?.text = theFileName
            
            self.soundFlag = false
            self.settingSoundFlag = true
            self.changeButton.backgroundColor = .blue
            self.soundUrl = url
            
//            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if iconFlag == true {
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
            
            self.iconFlag = false
            self.settingIconFlag = true
            self.changeButton.backgroundColor = .blue
            
//            dismiss(animated: true, completion: nil)
        } else if backImageFrag == true {
            if let editImage = info[.editedImage] as? UIImage {
                backgroundButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
            } else if let originalImage = info[.originalImage] as? UIImage {
                backgroundButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
            backgroundButton.setTitle("", for: .normal)
            backgroundButton.imageView?.contentMode = .scaleAspectFill
            backgroundButton.contentHorizontalAlignment = .fill
            backgroundButton.contentVerticalAlignment = .fill
            backgroundButton.clipsToBounds = true
            
            self.backImageFrag = false
            self.settingBackImageFrag = true
            self.changeButton.backgroundColor = .systemBlue
            
//            dismiss(animated: true, completion: nil)
        }
        
    }
    
}
