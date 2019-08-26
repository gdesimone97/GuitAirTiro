//
//  GuitAirGameCenter.swift
//  WebServiceGuitAirMP
//
//  Created by Christian Marino on 19/08/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import Foundation

class GuitAirGameCenter{
    
 
    //Singleton -> costruttore con JWT, altrimenti automaticamente impostato quando si fa il login
    
    private var JWT:String="";
    static let share = GuitAirGameCenter()
    
    private init() {
        if let jwt = userDefault.string(forKey: JWT_STRING) {
            self.JWT = jwt
        }
    }
    
    public func setJWT( JWT:String){
        self.JWT = JWT;
    }
    
    private let session : URLSession = {
        
        let config = URLSessionConfiguration.default;
        return URLSession(configuration:config);
        
    }();
    
    //Costruisco la richiesta
    private func buildAPIRequest( httpMethod : String, method : Method, queryItems : [String:String] = [:], params : [String:String] = [:])->URLRequest{

        
        //Creazione URL
        let url = GuitAirAPI.GuitAirURL(method: method, queryIts: queryItems);
        
        //Creazione richiesta
        var req = URLRequest.init(url: url);
        req.httpMethod = httpMethod;
        req.addValue("Bearer " + self.JWT, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        //Aggiungo body alla richiesta JSONificato
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        
        return req;
        
        
    }
    
    //Faccio la richiesta al server e ritorno il risultato
    private func makeAPIRequest( req : URLRequest )->(Int,[String:Any]){
        
        let semaphore = DispatchSemaphore.init(value: 0);
        
        
        var result : (Int,[String:Any]) = (0,[:]);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, Any>
                
                var respCode : Int = 0;
                
                if let httpResp = response as? HTTPURLResponse{
                    respCode = httpResp.statusCode;
                }
                
                result = (respCode, json);
                semaphore.signal();
            } catch {
                print("Error")
                return;
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
        
    }
    

    public func register(gamertag:String, password:String)->(Int,[String:String]){
        let params = ["gamertag":gamertag,"password":password];
        let urlReq = buildAPIRequest(httpMethod: "PUT", method: .account, params: params);
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    public func login(gamertag:String, password:String, devicetoken : String = "")->(Int,[String:String]){
        
        let params = ["gamertag":gamertag,"password":password, "device_token":devicetoken];
        
        let urlReq = buildAPIRequest(httpMethod: "POST", method: .account, params: params);
        let res = makeAPIRequest(req: urlReq) as! (Int,[String:String]);
        
        
        if(res.0 == 200 ){
            self.JWT = res.1["JWT"] ?? "";
            
            userDefault.set(self.JWT, forKey: JWT_STRING)
        }
        
        
        return res;
        //Esternamente, se 200 -> imposta JWT a questa classe
        
    }
    
    public func sendInvitation( gamertag : String, turns : Int, message : String = "" )->(Int,[String:Any]){
        
        let params = ["gamertag":gamertag,"turns":String(turns), message:"message"];
        
        let urlReq = buildAPIRequest(httpMethod: "POST", method: .invitation, params: params);
        
        
        
        //let urlReq = buildAPIRequest(httpMethod: "POST", method: .invitation,params: params)
        
        print(urlReq);
        
        return makeAPIRequest(req: urlReq);
        
    }
    
    public func acceptInvitation( id : Int )->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "PATCH", method: .invitation, params: ["status":"accepted","id":String(id)]);
        //print("Metodo che chiamo per accettare =");
        //print(urlReq);
        return makeAPIRequest(req: urlReq);
    }
    
    public func rejectInvitation( id : Int )->(Int,[String:String]){
        let urlReq = buildAPIRequest(httpMethod: "PATCH", method: .invitation, params: ["status":"rejected","id":String(id)]);
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    public func showAllInvitations( type : String )->(Int,[String:Any]){
        
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .invitation, queryItems: ["type":type]);
        return makeAPIRequest(req: urlReq);
        
    }
    
    public func deleteInvitation( id : Int )->(Int,[String:String]){
        let urlReq = buildAPIRequest(httpMethod: "DELETE", method: .invitation, queryItems: ["id":String(id)]);
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    public func readSentInvitation()->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .invitation, queryItems: ["type":"sent"]);
        return makeAPIRequest(req: urlReq);
    }
    
    public func readReceivedInvitation()->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .invitation, queryItems: ["type":"received"]);
        return makeAPIRequest(req: urlReq);
    }

    public func registerTurn( match : Int, turn : Int, song : String )->(Int,[String:String]){
        
        let params = ["match":String(match),"turn":String(turn),"song":song];
        
        let urlReq = buildAPIRequest(httpMethod: "POST", method: .turn, params: params);
        
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
        
    }
    
    public func registerScore( match: Int, turn: Int, score : Int )->(Int,[String:String]){
        
        let params = ["match":String(match),"turn":String(turn),"score":String(score)];
        
        let urlReq = buildAPIRequest(httpMethod: "PATCH", method: .turn, params: params);
        
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    public func abandonMatch( match: Int )->(Int,[String:String]){
        let urlReq = buildAPIRequest(httpMethod: "DELETE", method: .match, queryItems: ["match":String(match)]);
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    //Cosa manca? Fetch delle partite z, fetch degli amici, richieste di amicizia
    
    //1. fetch delle partite
    
    public func getMyMatches()->(Int,[String:Any]){
        return getMatches();
    }
    
    public func getMatches(gamertag:String="")->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .match, queryItems: gamertag.count==0 ? [:] : ["gamertag":gamertag])
        return makeAPIRequest(req: urlReq);
    }
    
    
    
    //2. parte delle amicizie
    
    public func sendFriendRequest( gamertag: String )->(Int,[String:String]){
        
        let urlReq = buildAPIRequest(httpMethod: "POST", method: .friend, params: ["gamertag":gamertag]);
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
        
    }
    
    public func acceptFriendRequest(sender : String )->(Int,[String:String]){
        let urlReq = buildAPIRequest(httpMethod: "PATCH", method: .friend, params: ["sender":sender,"status":"accepted"])
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    public func rejectFriendRequest(sender:String)->(Int,[String:String]){
        let urlReq = buildAPIRequest(httpMethod: "PATCH", method: .friend, params: ["sender":sender,"status":"rejected"])
        return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    public func deleteFriendRequest(gamertag:String)->
        (Int,[String:String]){
            let urlReq = buildAPIRequest(httpMethod: "DELETE", method: .friend, queryItems: ["gamertag":gamertag]);
            return makeAPIRequest(req: urlReq) as! (Int,[String:String]);
    }
    
    private func getFriendRequest(type:String)->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .friend, queryItems: ["type":type]);
        return makeAPIRequest(req: urlReq);
    }
    
    public func getSentFriendRequest()->(Int,[String:Any]){
        return getFriendRequest(type: "sent");
    }
    
    public func getReceivedFriendRequest()->(Int,[String:Any]){
        return getFriendRequest(type: "received");
    }
    
    public func getFriendList()->(Int,[String:Any]){
        return getFriendRequest(type: "list");
    }
    
    public func getMyProfile()->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .player);
//        print(urlReq.allHTTPHeaderFields)
        return makeAPIRequest(req: urlReq);
    }
    
    public func getProfile(gamertag:String)->(Int,[String:Any]){
        let urlReq = buildAPIRequest(httpMethod: "GET", method: .player, queryItems: ["gamertag":gamertag]);
        return makeAPIRequest(req: urlReq);
    }
    
}
