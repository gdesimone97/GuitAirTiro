//
//  GuitAirAPI.swift
//  WebServiceGuitAirMP
//
//  Created by Christian Marino on 19/08/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import Foundation

enum Method : String {
    
    case register = "accounts.phpX"
    case login = "accounts.php"
    case fetchProfile = "players.php"
    case myProfile = "players.php ";
    case invitation = "invitations.php";
    case readSentInv = "invitations.php?type=sent";
    case readRecInv = "invitations.php?type=received";
    case turns = "turns.php";
    case sendFriendRequest, getFriendRequest, acceptFriendRequest, declineFriendRequest, deleteFriendRequest = "friends.php";
    case match = "matches.php"
    case test = "test.php"
}

struct GuitAirAPI{
    
    //Da cambiare con indirizzo del server
    
    private static let baseURLString = "http://193.205.163.50/GuitAir/api/";
    
    //Costruisco URL per comunicare con la mia API
    
    
    static func GuitAirURL(method : Method) -> URL {
        
        let fullURLString = baseURLString + method.rawValue;
        //print(fullURLString);
        //print(Method.fetchProfile.rawValue);
        //print(method);
        print(fullURLString);
        var components = URLComponents(string: fullURLString)!;
        return components.url!;
        
    }
    
    
    
    
    
}
