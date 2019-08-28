//
//  Search TableViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 27/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Search_TableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    
    
    var playersTableViewDataSource: Array<String> = []
    var result : (Int,[String:Any]) = (0,[:]);
    let dispatchGroup = DispatchGroup();
    let game = GuitAirGameCenter.share;
    var searchActive : Bool = true;
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Search controlling
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        
        // Updating players array...
        self.updatePlayerArray()
        
//        mostrare tutti gli utenti
        
        
        self.tableView.reloadData()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func updatePlayerArray() {
        
        let res = game.listPlayer();
        if(res.0 == 200){
            let ls = res.1["gamertags"]! as String;
            let lsData = ls.data(using: .unicode)!
            self.playersTableViewDataSource = try! JSONSerialization.jsonObject(with: lsData) as! Array<String>
            self.playersTableViewDataSource.sort();
            
        }
        
        
    }
 

//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {


//        func cosaFaccioQuandoScrivo() {
//
//            print("Effettuo ricerca");
//
//
//            DispatchQueue.global(qos: .background).async(execute: {
//
//
//
//                let urlReq = self.game.returnSearch(searchText: searchText);
//
//                print(urlReq);
//
//                self.game.getSession().dataTask(with: urlReq,completionHandler: {
//
//                    data,response,error in
//
//                    do {
//                        var json: Dictionary<String,Any> = ["":""]
//                        if data == nil {
//
//                            print("DATA NIl");
//                            return;
//
//                        }
//                        else{
//                            json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, Any>
//
//                            let res = json;
//
//                            DispatchQueue.main.async(execute: {
//
//
//                                self.updateDataSourcePlayers(res: res);
//
//                            })
//
//
//
//                            print("Invocato metodo di aggiornamneto");
//                        }
//
//
//                    } catch{
//                        print("Error while json")
//                        return;
//                    }
//
//
//                }).resume()
//
//
//
//
//            })
//
//        }
//
//    }
//
//
    
//    func updateArray(){
//        if(searchActive) {
//            self.playersTableViewDataSource.append("Mario")
//            self.playersTableViewDataSource.append("Christian")
//            self.playersTableViewDataSource.append("Peppe")
//        }
//    }
//
//    func updateDataSourcePlayers( res : [String:Any] ){
//
//        if(res.count == 1 ){
//            //trovati 0 giocatori
//        }else{
//            let gamertags = res["gamertags"] as! String;
//            let data = gamertags.data(using: .unicode)!;
//            let gsArr = try! JSONSerialization.jsonObject(with: data) as? Array<String>;
//            print(gsArr);
//
//            self.playersTableViewDataSource = gsArr!
//        }
//
//
//
//    }
//    // MARK: - Table view data source
//
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.playersTableViewDataSource.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = playersTableViewDataSource[indexPath.row]
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // questo accessorio aggiunge il bottone a forma di freccia che punta verso destra (utile per indicare che cliccando la vista si sposta in un altro VC)
        cell.textLabel?.textColor = UIColor.white

        return cell
    }
//

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

//}
}
