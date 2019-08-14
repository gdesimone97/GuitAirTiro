//
//  SettingsTableViewController.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 16/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var tvSettingsCell: UITableViewCell!
    @IBOutlet var tvSettingsLabel: UILabel!
    
    
    let actLang = "Italiano";
    
    
    let sessionTv = SessionManager.share
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionTv.delegateSettings = self
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
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell: UITableViewCell?
     switch indexPath.row {
     case 0:
     cell = tableView.dequeueReusableCell(withIdentifier: "tv_settings",for: indexPath)
     tvSettingsCell = cell
     case 1:
     cell = tableView.dequeueReusableCell(withIdentifier: "notation_settings",for: indexPath)
     default:
     cell = nil
     }
     
     // Configure the cell...
     
     return cell!
     }
     */
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.sessionTv.showConnectedDevices() == nil {
            self.tvSettingsCell?.isUserInteractionEnabled = false
            self.tvSettingsLabel.textColor = UIColor.gray
        }
        else {
            self.tvSettingsCell?.isUserInteractionEnabled = true
            self.tvSettingsLabel.textColor = UIColor.white
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    
}

extension SettingsTableViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        return
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        if connected == 2 {
            DispatchQueue.main.async {
                self.tvSettingsCell.isUserInteractionEnabled = true
                self.tvSettingsLabel.textColor = UIColor.white
            }
        }
        if connected == 0 {
            DispatchQueue.main.async {
                self.tvSettingsCell.isUserInteractionEnabled = false
                self.tvSettingsLabel.textColor = UIColor.gray
            }
        }
        
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        return
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: Array<String>) {
        return
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        return
    }
    
    
    
}
