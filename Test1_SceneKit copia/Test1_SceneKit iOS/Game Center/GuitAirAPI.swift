//
//  GuitAirAPI.swift
//  WebServiceGuitAirMP
//
//  Created by Christian Marino on 19/08/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import Foundation


enum Method : String {
    
    case account = "accounts.php"
    case player = "players.php"
    case invitation = "invitations.php";
    case turn = "turns.php";
    case friend = "friends.php";
    case match = "matches.php"
    case test = "test.php"
}

struct GuitAirAPI{
    
    //Singleton
    
    //Da cambiare con indirizzo del server
    
    private static let baseURLString = "http://193.205.163.50/GuitAir/api/";
    
    //Costruisco URL per comunicare con la mia API
    
    
    static func GuitAirURL(method : Method, queryIts : [String:String] = [:] ) -> URL {
        
        let fullURLString = baseURLString + method.rawValue;
        
        var components = URLComponents(string: fullURLString)!;
        
        if(queryIts.count > 0){
        var queryItems : [URLQueryItem] = [];
        
        
            for(key,value) in queryIts{
                
                let qi = URLQueryItem(name: key, value: value);
                queryItems.append(qi);
                
            }
        
        components.queryItems = queryItems;
        }
        
        return components.url!;
        
    }
    
    
    
    
    
}
