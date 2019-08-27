//
//  FriendList ViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 21/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class FriendList_ViewController: UIViewController {

    let game = GuitAirGameCenter.share;
    var friendList = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let res = game.getFriendList();
        
        if(res.0 == 200){
            

            let ffString = res.1["req"] as! String;
            self.friendList = try! JSONSerialization.jsonObject(with: ffString.data(using: .unicode)!) as! Array<String>;
            print(friendList);
            
            
        }
        
        
        // Do any additional setup after loading the view.
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
