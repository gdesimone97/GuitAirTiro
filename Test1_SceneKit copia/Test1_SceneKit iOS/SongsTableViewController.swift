//
//  SongsTableViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 16/09/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class SongsTableViewController: UITableViewController {
    
    let dic = Songs.songs
    
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
        return dic.capacity
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songsIdentifier", for: indexPath)
        let key = indexPath.row + 1
        cell.textLabel?.text = dic[key]?.title
        cell.textLabel?.textColor = .white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var song: Songs!
        let value = userDefault.integer(forKey: SONG_SELECTED)
        switch value {
        case SongEnum.canzonedelsole.rawValue:
            song = Songs.LaCanzoneDelSole
        case SongEnum.knockinOnHeavensDoor.rawValue:
            song = Songs.KnockinOnHeavensDoor
        case SongEnum.peppoegay.rawValue:
            song = Songs.PeppeGay
        default:
            break
        }
        let dic = Songs.songs
        var key: Int!
        for k in dic.keys {
            if dic[k] == song {
                key = k
                break
            }
        }
        if (indexPath.row + 1) == key {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = indexPath.row
        userDefault.set(indexPath.row, forKey: SONG_SELECTED)
        let cell = tableView.cellForRow(at: indexPath)
        let cells = tableView.visibleCells
        for c in cells {
            if c != cell {
                c.accessoryType = .none
            }
            else {
                c.accessoryType = .checkmark
            }
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
