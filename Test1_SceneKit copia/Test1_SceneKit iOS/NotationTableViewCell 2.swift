//
//  NotationTableViewCell.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 16/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit

class NotationTableViewCell: UITableViewCell {

    
    var assocKey : String = "";
    var i : Int = 0;
    @IBOutlet var notationStringLabel: UILabel!
    let ud = UserDefaults.standard;
    let kk = "PreferredNotation";
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
        if i != 0{
            
            print("Entro qui, selezione fatta");
            let oldNot = ud.string(forKey: "PreferredNotation")!;
            print(kk);
            ud.set(assocKey, forKey: kk);
            
            
            let itaEnMap = [
                "Do": "C",
                "Dom": "Cm",
                "Re": "D",
                "Rem": "Dm",
                "Mi": "E",
                "Mim": "Em",
                "Fa": "F",
                "Fam": "Fm",
                "Sol": "G",
                "Solm": "Gm",
                "La": "A",
                "Lam": "Am",
                "Si": "B",
                "Sim": "Bm",
            ]
            
            let enItaMap = [
                "C": "Do",
                "Cm": "Dom",
                "D": "Re",
                "Dm": "Rem",
                "E": "Mi",
                "Em": "Mim",
                "F": "Fa",
                "Fm": "Fam",
                "G": "Sol",
                "Gm": "Solm",
                "A": "La",
                "Am": "Lam",
                "B": "Si",
                "Bm": "Sim",
            ]
            
            
            if(oldNot != assocKey){
            switch(assocKey){
            case "IT":
                
                print("TRADUZIONE EN TO IT")
                
                let oldChords = ud.array(forKey: "chords_string") as! [String];
                
                var newChords = [String]();
                
                for old in oldChords{
                    
                    newChords.append(enItaMap[old]!);
                    
                }
                
                ud.set(newChords, forKey: "chords_string")
                
                
            case "EN":
                
                print("TRADUZIONE IT TO EN")

                
                let oldChords = ud.array(forKey: "chords_string") as! [String];
                
                var newChords = [String]();
                
                for old in oldChords{
                    
                    newChords.append(itaEnMap[old]!);
                    
                }
                
                ud.set(newChords, forKey: "chords_string")
                
            default:
                break;
            }
            }
            
            let tw = self.superview as! UITableView;
            let twn = tw.next as! NotationTableViewController;
            let i = twn.navigationController as! UINavigationController;
            i.popViewController(animated: false);
            
//            twn.updateChecked();
        }
        i+=1;
//        (self.superview as! NotationTableViewController).updateChecked(assocKey);
        
        
        // Configure the view for the selected state
    }

}
