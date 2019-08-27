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
    @IBOutlet var errorLabel: UILabel!
    var indicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        passwordText.delegate = self
        errorLabel.text = nil
        indicator.center = self.view.center
        indicator.style = .whiteLarge
        indicator.hidesWhenStopped = true
        indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.text = ""
        usernameText.text = ""
        passwordText.text = ""
    }
    
    @IBAction func signIn(_ sender: Any) {
        let user = usernameText.text
        let pass = passwordText.text
        let game = GuitAirGameCenter.share
        self.view.endEditing(true)
        if user != nil && pass != nil {
            let token = userDefault.string(forKey: TOKEN)
            self.view.endEditing(true)
            indicator.startAnimating()
            let res = game.login(gamertag: user!, password: pass!,devicetoken: token ?? "")
            if res.0 == 200 || res.0 == 201 {
                print("Sono entrato")
                userDefault.set(1, forKey: LOGIN)
                HadlerProfile.downloadProfile()
                performSegue(withIdentifier: "login", sender: nil)
            }
                
            else if res.0 == 500 {
                DispatchQueue.main.async {
                    self.errorLabel.text = "No connection"
                    self.indicator.stopAnimating()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Username or password wrong"
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    
    @IBAction func SignUpButton(_ sender: Any) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        indicator.stopAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            let tabController = segue.destination as! UITabBarController
            tabController.selectedIndex = 2
        }
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
