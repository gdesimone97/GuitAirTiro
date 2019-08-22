//
//  GuitAirGameCenter.swift
//  WebServiceGuitAirMP
//
//  Created by Christian Marino on 19/08/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import Foundation

class GuitAirGameCenter{
    
    private let session : URLSession = {
        
        let config = URLSessionConfiguration.default;
        return URLSession(configuration:config);
        
    }();
    
    func registerScore(params:[String:String], jwt:String)->(Int,[String:String]){
        let url = GuitAirAPI.GuitAirURL(method: .turns);
        
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "PATCH";
        

        
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        let semaphore = DispatchSemaphore.init(value: 0);
        
        
        var result : (Int,[String:String]) = (0,[:]);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                var respCode : Int = 0;
                
                if let httpResp = response as? HTTPURLResponse{
                    respCode = httpResp.statusCode;
                }
                
                result = (respCode, json);
                semaphore.signal();
                //print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
    }
    
    func registerTurn(params:[String:String],jwt:String)->(Int,[String:String]){
        
        let url = GuitAirAPI.GuitAirURL(method: .turns);
        
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "POST";
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        let semaphore = DispatchSemaphore.init(value: 0);
        
        
        var result : (Int,[String:String]) = (0,[:]);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                var respCode : Int = 0;
                
                if let httpResp = response as? HTTPURLResponse{
                    respCode = httpResp.statusCode;
                }
                
                result = (respCode, json);
                semaphore.signal();
                //print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
        
    }
    
    func test(){
        let url = GuitAirAPI.GuitAirURL(method: .test);
        
        print(url);
        
        var req = URLRequest.init(url: url);
        
        req.httpMethod = "PATCH";
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            print("vediamo")
            
            do {
                
                print("gooo")
                
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
    }
    
    func sendInvitation(params : [String:String], jwt : String )->(Int, [String:String]){
        
        let url = GuitAirAPI.GuitAirURL(method: .invitation);
        print(url);
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "POST";
        //Header
        //req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        req.addValue("Bearer " + jwt,forHTTPHeaderField: "Authorization")
        print(req.allHTTPHeaderFields);
        //print(req.allHTTPHeaderFields)
        //Corpo
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req.httpBody);
        //print(req.httpMethod);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        var respCode : Int = 0;
        //var json : [String:String];
        var json : [String:String] = [:] ;
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            var respCode : Int;
            
            if let httpResponse = response as? HTTPURLResponse{
                print("Prendo codice di risposta");
                print(httpResponse.statusCode);
                respCode = httpResponse.statusCode;
            }
            
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                
            } catch {
                print("error");
            }
            
        })
        
        
        
        task.resume();
        
        return (respCode,json);
        
    }
    
    
    func getAllSentInvitation(params: [String:String], jwt:String)->(Int,[String:Any]){
        
        let url = GuitAirAPI.GuitAirURL(method: .readSentInv);
        
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "GET";
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
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
                //print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
        
    }
    
    func getAllRecInvitation(params: [String:String], jwt:String)->(Int,[String:Any]){
        
        let url = GuitAirAPI.GuitAirURL(method: .readRecInv);
        
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "GET";
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
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
                //print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
        
    }
    
    func deleteInvitation(params: [String:String], jwt : String )-> (Int,[String:String]){
        
        
            
            let url = GuitAirAPI.GuitAirURL(method: .invitation);
            
            var req = URLRequest.init(url: url);
            
            //Metodo
            req.httpMethod = "DELETE";
            
            //Header
            req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
            req.addValue("application/json", forHTTPHeaderField: "Content-Type");
            
            //print(req.allHTTPHeaderFields)
            //Corpo
            
            print(params);
            
            req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
            //print(req);
            //Faccio la richiesta
            //let task = session.dataTask(with:req);
            
            let semaphore = DispatchSemaphore.init(value: 0);
            
            
            var result : (Int,[String:String]) = (0,[:]);
            
            let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                    
                    var respCode : Int = 0;
                    
                    if let httpResp = response as? HTTPURLResponse{
                        respCode = httpResp.statusCode;
                    }
                    
                    result = (respCode, json);
                    semaphore.signal();
                    //print(json);
                } catch {
                    print("error")
                }
            })
            
            
            task.resume();
            semaphore.wait();
            return result;
        
    }
    
    func login( params : [ String : String ]) -> ( Int, [String:String]) {
        let url = GuitAirAPI.GuitAirURL(method: .login);
        print(url);
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "POST";
        //Header
        //req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req.httpBody);
        //print(req.httpMethod);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        var respCode : Int = 0;
        //var json : [String:String];
        var json : [String:String] = [:] ;
        
        
        
        
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            

            
            
            
            if let httpResponse = response as? HTTPURLResponse{
                //print("Prendo codice di risposta");
                //print(httpResponse.statusCode);
                respCode = httpResponse.statusCode;
            }
            
            do {
                 json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                     print(json);
            } catch {
                print("error")
            }
        });


        task.resume();

        
        
        while(task.state != .completed){
            print("no");
        }
        
        if(task.state == .completed){
            print("task completata")
            print(json);
            print(respCode);
        }
        
        return (respCode,json);

    }
    
    func register( params : [String : String ]){
        
        let url = GuitAirAPI.GuitAirURL(method: .register);
        print(url);
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "PUT";
        //Header
        //req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        print(req.allHTTPHeaderFields)
        //Corpo
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            if let httpResponse = response as? HTTPURLResponse{
                
                print(httpResponse.statusCode);
                
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        
    }
    
    func myProfile( jwt : String ){
        
        let url = GuitAirAPI.GuitAirURL(method: .myProfile);
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "GET";
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        print(req.allHTTPHeaderFields)
        //Corpo
        //req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
    }
    
    func abandonMatch(params: [String:String],jwt:String)->(Int,[String:String]){
        
        let url = GuitAirAPI.GuitAirURL(method: .match
        );
        
        var req = URLRequest.init(url: url);
        
        //print(req);
        
        //Metodo
        req.httpMethod = "DELETE";
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        //print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        
        
        
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        let semaphore = DispatchSemaphore.init(value: 0);
        
        
        var result : (Int,[String:String]) = (0,[:]);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            
            
            do {
                /*
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                 */
                
                if let printData = String(data: data!, encoding: .utf8) {
                    print(printData);
                }
 
                
                var respCode : Int = 0;
                
                if let httpResp = response as? HTTPURLResponse{
                    respCode = httpResp.statusCode;
                }
                
                result = (respCode, ["res": "aja"]);
                semaphore.signal();
                
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
        
    }
    
    func acceptInvitation( params : [String:String], jwt : String) -> (Int,[String:String]){
        
        let url = GuitAirAPI.GuitAirURL(method: .invitation);
        
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "PATCH";
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
        let semaphore = DispatchSemaphore.init(value: 0);
        
        
        var result : (Int,[String:String]) = (0,[:]);
        
        let task = session.dataTask(with: req, completionHandler: { data, response, error -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, String>
                
                var respCode : Int = 0;
                
                if let httpResp = response as? HTTPURLResponse{
                    respCode = httpResp.statusCode;
                }
                
                result = (respCode, json);
                semaphore.signal();
                //print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
        
    }
    
    func fetchProfile( params : [String:String] , jwt : String ) -> (Int, [String:Any]){
        
        let url = GuitAirAPI.GuitAirURL(method: .fetchProfile);
        
        var req = URLRequest.init(url: url);
        
        //Metodo
        req.httpMethod = "GET";
        
        //Header
        req.addValue("Bearer "+jwt, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        //print(req.allHTTPHeaderFields)
        //Corpo
        
        print(params);
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: []);
        //print(req);
        //Faccio la richiesta
        //let task = session.dataTask(with:req);
        
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
                //print(json);
            } catch {
                print("error")
            }
        })
        
        
        task.resume();
        semaphore.wait();
        return result;
    }
    
    
    
    
    
}
