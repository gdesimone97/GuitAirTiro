//
//  Multiplayer TableViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 22/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Multiplayer_TableViewController: UITableViewController, UISearchBarDelegate{

    var result : (Int,[String:Any]) = (0,[:]);
    let dispatchGroup = DispatchGroup();
    let game = GuitAirGameCenter.share;
    var searchActive : Bool = true;
    @IBOutlet weak var searchPlayer : UISearchBar!
    @IBOutlet weak var resultSearchView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchPlayer.delegate = self
        waitingIndicator.isHidden = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    // MARK: - Table view data source

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    @IBOutlet var waitingIndicator: UIActivityIndicatorView!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchActive){
            
            DispatchQueue.global(qos: .background).async(execute: {
                let res = self.game.searchPlayer(gamertag: searchText);
                
                
                DispatchQueue.main.async(execute: {
                    
                    self.waitingIndicator.isHidden = true;
                    
                    self.updatePlayersView(res : res.0==200 ? res.1 : [:]);
                })
                
            })
            
        }
        
    }
    
    
    func updatePlayersView( res : [String:Any] ){
        
        if(res.count == 1 ){
            //trovati 0 giocatori
        }else{
            let gamertags = res["gamertags"] as! String;
                    let data = gamertags.data(using: .unicode)!;
                    let gsArr = try! JSONSerialization.jsonObject(with: data) as? Array<String>;
                        print(gsArr);

        }
        
        
        
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    
/*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return
    }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

