//
//  loginViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 01/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        passwordText.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBAction func signIn(_ sender: Any) {
        let user = usernameText.text
        let pass = passwordText.text
        let game = GuitAirGameCenter.share
        if user != nil && pass != nil {
            let res = game.login(gamertag: user!, password: pass!)
            print(res)
            if res.0 == 200 {
                print("Sono entrato")
                userDefault.set(1, forKey: LOGIN)
                performSegue(withIdentifier: "login", sender: nil)
            }
            else {
                print("Non sei entrato")
            }
        }
    
    }
    
    
    @IBAction func SignUpButton(_ sender: Any) {
        
    }
    
}

extension LoginViewController: UITextFieldDelegate {
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
