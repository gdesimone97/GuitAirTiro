//
//  Matches ViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 23/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Matches_TableViewCell: UITableViewCell {
    
    @IBOutlet weak var gamertagLabel: UILabel!
    @IBOutlet weak var matchIDLabel: UILabel!
    
}

class Matches_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(segmentedC.selectedSegmentIndex == 0) {
            return self.progrMatches.count
        } else {
            return self.endedMatches.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Matches_TableViewCell
        
        if(segmentedC.selectedSegmentIndex == 0) {
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Matches_TableViewCell

            //let index = progrMatches.keys[indexPath.row];

            //k = indice per accedere ai cazzarielli
            print("Indice iniziale = \(progrMatches.startIndex)");
            

            let kArr = Array(progrMatches.keys);
            
            //print(kArr);
            
            let k = kArr[indexPath.row]
            print(k);
            //let gamertag = (progrMatches[k][0]["gamertag"] == PersistanceManager.retriveGamerTag() ? progrMatches[k][1]["gamertag"] : progrMatches[k][0]["gamertag"];
            
            let arrays = progrMatches[k]!;
            //let arr2 = progrMatches[k]![1];
            
            
            //print("Per la chiave \(k) ho trovato -> \(arrays)");
            let g1 = arrays[0]["gamertag"]!;
            let g2 = arrays[1]["gamertag"]!;
            
            let gamertag = g1 == PersistanceManager.retriveGamerTag() ? g2 : g1;
            cell0.gamertagLabel!.text = gamertag
            cell0.matchIDLabel!.text = k;
            return cell0
        } else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Matches_TableViewCell

            cell1.gamertagLabel?.text = "Christian"
            cell1.matchIDLabel?.text = "13"
            
            return cell1
        }
        

        
    }
    
  
    let game = GuitAirGameCenter.share;
    var progrMatches = [String:Array<[String:String]>]();
    var endedMatches = [String:Array<[String:String]>]();
    
    
    @IBAction func SegmentedControlActionChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedC: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
            
            print(tempMM);
            
            let progrMatchesTEMP = tempMM.filter({
                
                return $0["match_status"] == "active"
                
            })
            
            print(progrMatches)
            
            let endedMatchesTEMP = tempMM.filter({
                return $0["match_status"] == "inactive"
            })
            
            for matchPlayer in progrMatchesTEMP{
                
                let keyForDS = String(matchPlayer["match_id"]!);
                if self.progrMatches[keyForDS] == nil{
                    print("inizializzo l'array")
                    self.progrMatches[keyForDS] = Array<[String:String]>()
                }
                progrMatches[keyForDS]!.append(matchPlayer)
                //print(self.progrMatches[keyForDS])
             
            }
            
            for matchPlayer in endedMatchesTEMP{
                
                let keyForDS = String(matchPlayer["match_id"]!);
                //self.endedMatches[keyForDS] = Array<[String:String]>()
                if self.endedMatches[keyForDS] == nil{
                    print("inizializzo l'array")
                    self.endedMatches[keyForDS] = Array<[String:String]>()
                }
                
                self.endedMatches[keyForDS]!.append(matchPlayer)
                //progrMatches[keyForDS].append(matchPlayer)
                //print(self.progrMatches[keyForDS])
                
            }
            
            //print(progrMatches);
            //print(endedMatches);
            
            self.tableView.reloadData()
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
