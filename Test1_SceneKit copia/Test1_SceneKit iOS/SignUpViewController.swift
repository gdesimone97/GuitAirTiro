//
//  SignUpViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 23/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet var userText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var invalidPasswordLabel: UILabel!
    @IBOutlet var invalidLogIn: UILabel!
    
    var indicator = UIActivityIndicatorView()
    let SEGUE = "return_to_login"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userText.delegate = self
        passwordText.delegate = self
        invalidPasswordLabel.text = ""
        invalidLogIn.text = ""
        indicator.center = self.view.center
        indicator.style = .whiteLarge
        indicator.hidesWhenStopped = true
        indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(indicator)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        indicator.startAnimating()
        let game = GuitAirGameCenter.share
        var flag = true
        if userText.text == "" {
            userText.layer.borderWidth = 2.5
            userText.layer.borderColor = UIColor.red.cgColor
            flag = false
        }
        else {
            userText.layer.borderWidth = 0.0
        }
        if passwordText.text == "" || passwordText.text!.count < 8 {
            passwordText.layer.borderWidth = 2.5
            passwordText.layer.borderColor = UIColor.red.cgColor
            flag = false
            if passwordText.text!.count < 8 {
                invalidPasswordLabel.text = "Min 8 characters"
                invalidPasswordLabel.text = ""
            }
        }
        else {
            passwordText.layer.borderWidth = 0.0
        }
        if flag {
            let res = game.register(gamertag: userText.text!.lowercased(), password: passwordText.text!)
            if res.0 == 200 || res.0 == 201 {
                performSegue(withIdentifier: SEGUE, sender: nil)
                //self.dismiss(animated: true, completion: nil)
            }
            else if res.0 == 409 {
                invalidLogIn.text = "This account already exists"
                indicator.stopAnimating()
            }
            else {
                invalidLogIn.text = "Username or password wrong"
                indicator.stopAnimating()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        indicator.stopAnimating()
    }
    
}



extension SignUpViewController : UITextFieldDelegate {
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
