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
            let token = userDefault.string(forKey: TOKEN)
            let res = game.login(gamertag: user!, password: pass!,devicetoken: token ?? "")
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

extension LoginViewController : UITextFieldDelegate {
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            moveTextField(textField, moveDistance: -250, up: true)
        }
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            moveTextField(textField, moveDistance: -250, up: false)
        }
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        if textField.tag == 1 {
            let moveDuration = 0.3
            let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
            
            UIView.beginAnimations("animateTextField", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(moveDuration)
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
            UIView.commitAnimations()
        }
    }
}
