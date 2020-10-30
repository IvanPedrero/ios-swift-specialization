//
//  RequestController.swift
//  Content Moderator
//
//  Created by Ivan Pedrero on 11/10/20.
//  Copyright © 2020 Ivan Pedrero. All rights reserved.
//  84e9353f297e45a9aed4f8f1fd17571c
//

import Foundation
import  UIKit



class RequestController {
    
    private static let subscriptionKey:String = "YOUR_AZURE_KEY"

    
    static func moderateText(data:String, completion: @escaping (Dictionary<String, AnyObject>?)->()) {
        //create the url with NSURL
        let url = URL(string: "https://westcentralus.api.cognitive.microsoft.com/contentmoderator/moderate/v1.0/ProcessText/Screen?classify=True")!

        //create the session object
        let session = URLSession.shared
        

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let parameters: [String: Any] = [
            "data": data
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }


        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["Status"] as? Dictionary<String, AnyObject>) != nil{
                        completion(json as Dictionary<String, AnyObject>)
                    }
                    else{
                        completion(nil)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
        })

        task.resume()
    }
    
    static func moderateImage(data:Data, completion: @escaping (Dictionary<String, AnyObject>?)->()) {
        //create the url with NSURL
        let url = URL(string: "https://westcentralus.api.cognitive.microsoft.com/contentmoderator/moderate/v1.0/ProcessImage/Evaluate?CacheImage=False")!

        //create the session object
        let session = URLSession.shared
        

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        request.httpBody = data

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["Status"] as? Dictionary<String, AnyObject>) != nil{
                        completion(json as Dictionary<String, AnyObject>)
                    }
                    else{
                        completion(nil)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
        })

        task.resume()
    }
}
