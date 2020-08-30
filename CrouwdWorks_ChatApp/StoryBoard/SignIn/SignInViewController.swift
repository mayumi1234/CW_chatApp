//
//  SignInViewController.swift
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

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var noMemberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.lightGray
        loginButton.layer.cornerRadius = 8
        passwdTextField.isSecureTextEntry = true
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
    
    private func checkRegisterButton() {
        if emailTextField.text != "" && passwdTextField.text != ""  {
            loginButton.isEnabled = true
            loginButton.backgroundColor = blueColor
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func pushOnLoginButton(_ sender: Any) {
        HUD.show(.progress)
        
        guard let email = emailTextField.text else { return }
        guard let password = passwdTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                HUD.hide()
                HUD.flash(.labeledError(title: "ログインに失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                return
            }
            
            print("ログインに成功しました。")
            
            self.dismiss(animated: true, completion: nil)

            HUD.hide()
        }
        
    }
    
    @IBAction func pushOnNonLoginButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
