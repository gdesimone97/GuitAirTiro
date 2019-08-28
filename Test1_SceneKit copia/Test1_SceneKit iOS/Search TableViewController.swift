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
        flag = true
        guard let text = searchController.searchBar.text else { return }
        print(text)
        self.filterContent(searchedText: text)
    }
    
    
    
    var flag: Bool = false
    var filteredDataSource: Array<String> = []
    var playersTableViewDataSource: Array<String> = []
    var result : (Int,[String:Any]) = (0,[:]);
    let dispatchGroup = DispatchGroup();
    let game = GuitAirGameCenter.share;
    var search: UISearchController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Search controlling
        self.search = UISearchController(searchResultsController: nil)
        self.search?.searchResultsUpdater = self
        self.search?.obscuresBackgroundDuringPresentation = false
        self.search?.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        self.search?.searchBar.barStyle = .black
        
        // Updating players array...
        self.updatePlayerArray()
        

        
        self.tableView.reloadData()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func filterContent(searchedText: String) {
        print("Filtering..")
        filteredDataSource.removeAll(keepingCapacity: true)
        for x in playersTableViewDataSource {
            var justOne = false
       
            if((x.lowercased().range(of:searchedText.lowercased()) != nil) && justOne == false) {
                        print("aggiungo \(x) alla listaFiltrata")
                        filteredDataSource.append(x)
                        justOne = true
                    }
        
            
            self.tableView.reloadData()
        }
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
 

//    // MARK: - Table view data source
//
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if search!.isActive {
            return self.filteredDataSource.count
        } else {
            return self.playersTableViewDataSource.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

 
        var player : String
        
        // se viene la Search Bar è attiva allora utilizza l'elemento con indice visualizzato a partire dalla listra Filtrata
        if search!.isActive {
            player = self.filteredDataSource[indexPath.row]
        } else {
            //ricavo un elemento della lista in posizione row (il num di riga) e lo conservo
            player = self.playersTableViewDataSource[indexPath.row]
        }
        
        //riempio la cella assegnando ad una label testuale il nome dell'alimento
        cell.textLabel?.text = player
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
