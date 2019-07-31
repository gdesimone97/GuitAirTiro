//
//  NotationTableViewController.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 16/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit

class NotationTableViewController: UITableViewController {

   
    
    let userDefaults = UserDefaults.standard;
    let USER_DEFAULT_KEY_ROW = "PreferredNotation";
    let USER_DEFAULT_KEY_STRING = "PreferredNotation";
    var preferredNotation = "";
    
    let notationString = ["EN":"English notation","IT":"Italian notation"];
    var keyString : [String] = [];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
        let valString = notationString.keys;
        keyString = notationString.keys.sorted();
        
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notationString.count;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! NotationTableViewCell;

        // Configure the cell...
        //var n = cell.subviews[0].subviews.count;
        //print(n);
//        cell.accessoryType = cell.langName.text == notationInUse ? .checkmark : .none;
        let actKey = keyString[indexPath.row];
//        let actKey = Array(notationString.keys)[indexPath.row];
        
        
        let savNot = userDefaults.string(forKey: "PreferredNotation") as! String;
        
        cell.assocKey = actKey;
        
//        print("actKey -> \(actKey) <> saved ->  \(savNot)");
        
        cell.accessoryType = actKey == savNot ? .checkmark : .none;
        
        cell.notationStringLabel.text = notationString[actKey];
        
        
        return cell
    }
 
    
    func updateChecked(){
        

        //self.viewDidLoad();
//        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
//        self.performSegue(withIdentifier: "selectNotationSegue", sender: self)
        
//        self.viewWillAppear(true);
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
    }
    

    
    
}
