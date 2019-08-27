//
//  Search ViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Mario De Sio on 27/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class Search_ViewController: UIViewController, UISearchBarDelegate {

   // var playersTableViewDataSource: [String] = [];
    var result : (Int,[String:Any]) = (0,[:]);
    let dispatchGroup = DispatchGroup();
    let game = GuitAirGameCenter.share;
    var searchActive : Bool = false;

    @IBOutlet var searchDisplay: UISearchController!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        // Do any additional setup after loading the view.
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
        if(searchActive){
            
            print("Effettuo ricerca");
            
//            self.waitingIndicator.isHidden = false;
            
            DispatchQueue.global(qos: .background).async(execute: {
                
                
                
                let urlReq = self.game.returnSearch(searchText: searchText);
                
                print(urlReq);
                
                self.game.getSession().dataTask(with: urlReq,completionHandler: {
                    
                    data,response,error in
                    
                    do {
                        var json: Dictionary<String,Any> = ["":""]
                        if data == nil {
                            
                            print("DATA NIl");
                            return;
                            
                        }
                        else{
                            json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, Any>
                            
                            let res = json;
                            
                            DispatchQueue.main.async(execute: {
                                
//                                self.waitingIndicator.isHidden = true;
                                
                                self.updateDataSourcePlayers(res: res);
                                
                            })
                            
                            
                            
                            print("Invocato metodo di aggiornamneto");
                        }
                        
                        
                    } catch{
                        print("Error while json")
                        return;
                    }
                    
                    
                }).resume()
                
                
                
                
            })
            
        }
        
    }
    
    
    func updateDataSourcePlayers( res : [String:Any] ){
        
        if(res.count == 1 ){
            //trovati 0 giocatori
        }else{
            let gamertags = res["gamertags"] as! String;
            let data = gamertags.data(using: .unicode)!;
            let gsArr = try! JSONSerialization.jsonObject(with: data) as? Array<String>;
            //self.playersTableViewDataSource = gsArr!
            
        }
        
        
        
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
