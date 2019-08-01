//
//  AccountViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 01/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  !userDefaults.bool(forKey: LOGIN) {
            self.performSegue(withIdentifier: "login_view", sender: nil)
        }
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func logOutButton(_ sender: Any) {
        userDefaults.set(false,forKey: LOGIN)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
