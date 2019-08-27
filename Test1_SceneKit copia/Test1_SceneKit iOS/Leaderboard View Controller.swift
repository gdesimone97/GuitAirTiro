//
//  Leaderboard View Controller.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 21/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Leaderboard_View_Controller: UIViewController {

    var leaderboardList = [[String:String]]()
    let game = GuitAirGameCenter.share;
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let res = game.getLeaderboard();
        
        if(res.0 == 200 ){
            
            let leadArr = res.1["leaderboard"] as! String;
            let laData = leadArr.data(using: .unicode)!;
            let lasa = try! JSONSerialization.jsonObject(with: laData) as! Array<String>;
            
            for lString in lasa{
                
                let lsData = lString.data(using: .unicode)!;
                let lead = try! JSONSerialization.jsonObject(with: lsData) as! Dictionary<String,String>
                
                leaderboardList.append(lead);
                
            }
            
            
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
