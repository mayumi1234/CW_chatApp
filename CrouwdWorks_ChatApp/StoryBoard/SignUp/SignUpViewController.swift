//
//  SignUpViewController.swift
//  InstagramCloneApp
//
//  Created by m.yamanishi on 2020/08/08.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class SignUpViewController: UIViewController, UITextFieldDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyMemberButton: UIButton!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpViews() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        emailTextField.delegate = self
        passwdTextField.delegate = self
        userNameTextField.delegate = self
        
        passwdTextField.isSecureTextEntry = true
        registerButton.isEnabled = false
        registerButton.backgroundColor = UIColor.lightGray
    }
    
    private func checkRegisterButton() {
        if userNameTextField.text != "" && emailTextField.text != "" && passwdTextField.text != "" && profileImageView.imageView?.image != nil {
            registerButton.isEnabled = true
            registerButton.backgroundColor = blueColor
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.lightGray
        }
    }
    
    //    キーボード以外をタップしてキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        checkRegisterButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkRegisterButton()
        return true
    }
    
    @IBAction func pushOnImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func uploadImageToStorage() {
        guard let image = profileImageView.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let strageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        strageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firestorageへの情報の保存に失敗しました。\(err)")
                HUD.flash(.labeledError(title: "会員登録に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                HUD.hide()
                return
            }
            print("Firestorageへの情報の保存に成功しました。")
            strageRef.downloadURL { (url, err) in
                if let err = err {
                    print("FireStorageからのダウンロードに失敗しました。")
                    HUD.flash(.labeledError(title: "会員登録に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                    HUD.hide()
                    return
                }
                
                guard let urtString = url?.absoluteString else { return }
                self.createUserToFirestore(profileImageUrl: urtString)
            }
        }
    }
    
    @IBAction func pushOnRegisterButton(_ sender: Any) {
        HUD.show(.progress)
        uploadImageToStorage()
    }
    
    private func createUserToFirestore(profileImageUrl: String) {
        guard let email = emailTextField.text else { return }
        guard let passwd = passwdTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: passwd) { (res, err) in
            if let err = err {
                print("認証情報の取得に失敗しました。\(err)")
                HUD.hide()
                HUD.flash(.labeledError(title: "会員登録に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                return
            }
            print("認証情報の保存に成功しました。")
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.userNameTextField.text else { return }
            
            let docData = [
                "email": email,
                "username": username,
                "profileImageUrl": profileImageUrl
                ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                if let err = err {
                    print("Firestoreへの保存に失敗しました。\(err)")
                    HUD.hide()
                    HUD.flash(.labeledError(title: "会員登録に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                    return
                }
                print("Firestoreへの保存が成功しました。")
                
                self.dismiss(animated: true, completion: nil)
                
                HUD.hide()
            }
        }
    }
    
    @IBAction func pushOnAlreadyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        let signinViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signinViewController, animated: true)
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate {
    
    //    写真を設定するときの関数
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            profileImageView.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageView.setTitle("", for: .normal)
        profileImageView.imageView?.contentMode = .scaleAspectFill
        profileImageView.contentHorizontalAlignment = .fill
        profileImageView.contentVerticalAlignment = .fill
        profileImageView.clipsToBounds = true
        
        checkRegisterButton()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
