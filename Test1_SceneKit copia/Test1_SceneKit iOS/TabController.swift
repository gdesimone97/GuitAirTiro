//
//  TabController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 27/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class TabController: UITabBarController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let SEGUE = "return_to_login"
        if segue.identifier == SEGUE {
            print("Qui")
        }
        else {
            print("cavolo")
        }
     }
}
