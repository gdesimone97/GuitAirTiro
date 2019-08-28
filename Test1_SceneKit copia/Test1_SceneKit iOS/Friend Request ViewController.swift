//
//  Friend Request ViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 26/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Friend_Request_ViewController: UIViewController {

    
    var sentFriendRequestDataSource = [[String:String]]();
    var rcvdFriendRequestDataSource = [[String:String]]();
    let game = GuitAirGameCenter.share;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sent = game.getSentFriendRequest();
        if(sent.0 == 200 ){
            //Converto stringa in array
            
            let sentString = sent.1["req"] as! String;
            let data = sentString.data(using: .unicode)!;
            let sentArr = try! JSONSerialization.jsonObject(with: data) as! Array<String>;
            
            
            
            for  sentFR in sentArr {
            
                let data = sentFR.data(using: .unicode)!
                let sentDiz = try! JSONSerialization.jsonObject(with: data) as! Dictionary<String,String>;
                
                self.sentFriendRequestDataSource.append(sentDiz);
                //print(sentDiz);
                
            }
            
            let rcvd = game.getReceivedFriendRequest();
            if(rcvd.0 == 200 ){
                //Converto stringa in array
                
                let rcvdString = sent.1["req"] as! String;
                let data = rcvdString.data(using: .unicode)!;
                let rcvdArr = try! JSONSerialization.jsonObject(with: data) as! Array<String>;
                
                
                
                for  rcvdFR in rcvdArr {
                    
                    let data = rcvdFR.data(using: .unicode)!
                    let rcvdDiz = try! JSONSerialization.jsonObject(with: data) as! Dictionary<String,String>;
                    
                    self.rcvdFriendRequestDataSource.append(rcvdDiz);
                    //print(sentDiz);
                    
                    //campi a cui accedere -> sender/receiver // message // timestamp
                    
                }
            //Converto stringa in ogni posizione dell'array in array associativo
        }
            
        
        // Do any additional setup after loading the view.
    }
    
    
    func updateDataSourceSentFriendRequests(res: Any){
        
        //print(arr);
    }

    func updateDataSourceRcvdFriendRequests(res: Any){
        print(res);
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
