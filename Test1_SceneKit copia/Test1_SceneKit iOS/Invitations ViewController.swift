//
//  Invitations ViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 23/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Invitations_ViewController: UIViewController {

    
    var sentInvList = [[String:String]]();
    var rcvdInvList = [[String:String]]();
    let game = GuitAirGameCenter.share;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         //Prendo i mandati
        let sentRes = game.readSentInvitation();
        if(sentRes.0 == 200 ){
            
            let sentString : String = sentRes.1["invitations"] as! String
            
            //print(sentRes);
            let sentData = sentString.data(using: .unicode)!;
            
            let sentArray = try! JSONSerialization.jsonObject(with: sentData) as! Array<String>
            
            for invS in sentArray{
                
                let invData = invS.data(using: .unicode)!
                
                let invDiz = try! JSONSerialization.jsonObject(with:invData) as! Dictionary<String,String>;
                
                sentInvList.append(invDiz);
 
            }
            
            
            let rcvdRes = game.readReceivedInvitation();
            if(rcvdRes.0 == 200 ){
                
                let rcvdString : String = rcvdRes.1["invitations"] as! String
                
                //print(sentRes);
                let rcvdData = sentString.data(using: .unicode)!;
                
                let rcvdArray = try! JSONSerialization.jsonObject(with: rcvdData) as! Array<String>
                
                for invR in rcvdArray{
                    
                    let rcvdData = invR.data(using: .unicode)!
                    
                    let invDiz = try! JSONSerialization.jsonObject(with:rcvdData) as! Dictionary<String,String>;
                    
                    rcvdInvList.append(invDiz);
                    
                }
            print(self.rcvdInvList);
            print(self.sentInvList);
            
            //Campi a cui accedere ? gamertag, id, status, timestamp, message, turns
                
                
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
}
