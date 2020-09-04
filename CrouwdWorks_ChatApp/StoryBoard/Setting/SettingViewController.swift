//
//  SettingViewController.swift
//  CrouwdWorks_ChatApp
//
//  Created by m.yamanishi on 2020/06/10.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD
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
    var backgroundUrl: URL?
    var soundUrl: URL?
    
    var iconFlag = false
    var backImageFrag = false
    var soundFlag = false
    
    var settingIconFlag = false
    var settingBackImageFrag = false
    var settingSoundFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    private func setupLayout () {
        self.iconButton.layer.cornerRadius = iconButton.layer.frame.width / 2
        self.iconButton.layer.borderColor = UIColor.gray.cgColor
        self.iconButton.layer.borderWidth = 1
        
        self.backgroundButton.layer.cornerRadius = backgroundButton.layer.frame.width / 2
        self.backgroundButton.layer.borderColor = UIColor.gray.cgColor
        self.backgroundButton.layer.borderWidth = 1
        
        self.musicButton.layer.cornerRadius = musicButton.layer.frame.width / 2
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
        
        let soundPicker = UIDocumentPickerViewController(documentTypes: ["public.mp3" as String], in: .import)
        soundPicker.delegate = self
        self.present(soundPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func settingButton(_ sender: Any) {
        HUD.show(.progress)
        
        if self.settingIconFlag {
            guard let image = iconButton.imageView?.image else { return }
            guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
            
            let fileName = NSUUID().uuidString
            let strageRef = Storage.storage().reference().child("profile_image").child(fileName)
            
            strageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Firestorageへの情報の保存に失敗しました。\(err)")
                    HUD.hide()
                    HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                    return
                }
                print("Firestorageへの情報の保存に成功しました。")
                strageRef.downloadURL { (url, err) in
                    if let err = err {
                        print("FireStorageからのダウンロードに失敗しました。")
                        HUD.hide()
                        HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                        return
                    }
                    
                    guard let urtString = url?.absoluteString else { return }
                    self.urlFunction(profileImageUrl: urtString)
                }
            }
        }
        if self.settingBackImageFrag {
            guard let backgroundImage = backgroundButton.imageView?.image else { return }
            guard let uploadBackgroundImage = backgroundImage.jpegData(compressionQuality: 0.3) else { return }

            let backgroundFileName = NSUUID().uuidString
            let backgroundStrageRef = Storage.storage().reference().child("background_image").child(backgroundFileName)

            backgroundStrageRef.putData(uploadBackgroundImage, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Firestorageへの情報の保存に失敗しました。\(err)")
                    HUD.hide()
                    HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                    return
                }
                print("Firestorageへの情報の保存に成功しました。")
                backgroundStrageRef.downloadURL { (url, err) in
                    if let err = err {
                        print("FireStorageからのダウンロードに失敗しました。")
                        HUD.hide()
                        HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                        return
                    }

                    guard let urtString = url?.absoluteString else { return }
                    self.backgroundUrlFunction(backgroundImageUrl: urtString)
                }
            }
        }
        if self.settingSoundFlag {
            guard let pushSound = self.soundUrl else { return }
            
            let soundFileName = NSUUID().uuidString
            let soundStrageRef = Storage.storage().reference().child("push_sound").child(soundFileName)
            
            soundStrageRef.putFile(from: pushSound, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Firestorageへの情報の保存に失敗しました。\(err)")
                    HUD.hide()
                    HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                    return
                }
                print("Firestorageへの情報の保存に成功しました。")
                soundStrageRef.downloadURL { (url, err) in
                    if let err = err {
                        print("FireStorageからのダウンロードに失敗しました。")
                        HUD.hide()
                        HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                        return
                    }
                    
                    guard let urtString = url?.absoluteString else { return }
                    self.soundUrlFunction(pushSoundUrl: urtString)
                }
            }
        }
    }
    
    private func urlFunction(profileImageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatroomDocId = self.documentId else { return }
        
        let ImageUrl = [
            "profileImageUrl": profileImageUrl
        ]
        
        db.collection("users").document(uid).collection("chatRooms").document(chatroomDocId).updateData(ImageUrl) { (err) in
            if let err = err {
                print("最新相手画像の保存に失敗しました。\(err)")
                HUD.hide()
                HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                return
            }
            print("最新相手画像の保存に成功しました。")
        }
        
        chatroom?.profileImageUrl = profileImageUrl
        
        messages.forEach { message in
        message.imageUrl = profileImageUrl
        }
        
        HUD.hide()
        HUD.flash(.labeledSuccess(title: "相手画像の変更が完了しました。", subtitle: ""), delay: HUDTime)
        
    }
    
    private func backgroundUrlFunction(backgroundImageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatroomDocId = self.documentId else { return }

        let ImageUrl = [
            "backgroundImageUrl": backgroundImageUrl
        ]

        db.collection("users").document(uid).collection("chatRooms").document(chatroomDocId).updateData(ImageUrl) { (err) in
            if let err = err {
                print("最新背景画像の保存に失敗しました。\(err)")
                HUD.hide()
                HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                return
            }
            print("最新背景画像の保存に成功しました。")
        }

        chatroom?.backgroundImageUrl = backgroundImageUrl
        
        HUD.hide()
        HUD.flash(.labeledSuccess(title: "背景画像の変更が完了しました。", subtitle: ""), delay: HUDTime)

    }
    
    private func soundUrlFunction(pushSoundUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatroomDocId = self.documentId else { return }
        
        let soundUrl = [
            "soundUrl": pushSoundUrl
        ]
        
        db.collection("users").document(uid).collection("chatRooms").document(chatroomDocId).updateData(soundUrl) { (err) in
            if let err = err {
                print("最新mp3の保存に失敗しました。\(err)")
                HUD.hide()
                HUD.flash(.labeledError(title: "設定変更に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                return
            }
            print("最新mp3の保存に成功しました。")
        }
        
        chatroom?.soundUrl = pushSoundUrl
        
        HUD.hide()
        HUD.flash(.labeledSuccess(title: "通知音の変更が完了しました。", subtitle: ""), delay: HUDTime)
    }
    
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if soundFlag == true {
            let theFileName: String = url.lastPathComponent
            musicButton.titleLabel?.text = theFileName
            
            self.soundFlag = false
            self.settingSoundFlag = true
            self.changeButton.backgroundColor = .blue
            self.soundUrl = url
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
            
            dismiss(animated: true, completion: nil)
            
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
            
            dismiss(animated: true, completion: nil)
        }
    }
    
}
