//
//  Matches ViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 23/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Matches_ViewController: UIViewController {
    
    let game = GuitAirGameCenter.share;
    var progrMatches = [String:Array<[String:String]>]();
    var endedMatches = [String:Array<[String:String]>]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let matchRes = game.getMatches();
        
        if(matchRes.0 == 200 ){
            
            let matchString : String = matchRes.1["matches"] as! String
            
            //print(sentRes);
            let mmData = matchString.data(using: .unicode)!;
            
            //print(matchString);
            
            
            let matchArray = try! JSONSerialization.jsonObject(with: mmData) as! Array<String>
            
            var tempMM = [[String:String]]();
            
            for mR in matchArray{
                
                let mData = mR.data(using: .unicode)!
                
                let mmDiz = try! JSONSerialization.jsonObject(with:mData) as! Dictionary<String,String>;
                
                tempMM.append(mmDiz);
            }
            
            let progrMatchesTEMP = tempMM.filter({
                
                return $0["match_status"] == "active"
                
            })
            
            
            let endedMatchesTEMP = tempMM.filter({
                return $0["match_status"] == "inactive"
            })
            
            for matchPlayer in progrMatchesTEMP{
                
                let keyForDS = String(matchPlayer["match_id"]!);
                self.progrMatches[keyForDS] = Array<[String:String]>()
                self.progrMatches[keyForDS]!.append(matchPlayer)
                //progrMatches[keyForDS].append(matchPlayer)
                //print(self.progrMatches[keyForDS])
             
            }
            
            for matchPlayer in endedMatchesTEMP{
                
                let keyForDS = String(matchPlayer["match_id"]!);
                self.endedMatches[keyForDS] = Array<[String:String]>()
                self.endedMatches[keyForDS]!.append(matchPlayer)
                //progrMatches[keyForDS].append(matchPlayer)
                //print(self.progrMatches[keyForDS])
                
            }
            
            //print(progrMatches);
            //print(endedMatches);
            
            
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
