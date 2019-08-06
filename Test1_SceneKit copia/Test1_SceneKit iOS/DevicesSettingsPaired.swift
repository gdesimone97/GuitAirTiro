//
//  DevicesSettingsPaired.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 06/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class DevicesSettingsPaired: UITableViewController {
    
    var onlyWatchCell: UITableViewCell?
    var tvCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "watch_cell", for: indexPath)
            onlyWatchCell = cell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "without_watch_cell", for: indexPath)
            tvCell = cell
        default:
            cell = nil
        }
        
        // Configure the cell...
        cell?.accessoryType = .none
        return cell!
    }
    
     override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         let index = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        switch index {
        case 0:
            onlyWatchCell?.accessoryType = .checkmark
        case 1:
            tvCell?.accessoryType = .checkmark
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            onlyWatchCell!.accessoryType = .checkmark
            tvCell!.accessoryType = .none
            userDefault.set(0, forKey: GAME_DEVICE_SETTINGS)
        case 1:
            onlyWatchCell!.accessoryType = .none
            tvCell!.accessoryType = .checkmark
            userDefault.set(1, forKey: GAME_DEVICE_SETTINGS)
        default:
            break
        }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
