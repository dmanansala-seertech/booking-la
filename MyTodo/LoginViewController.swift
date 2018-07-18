//
//  LoginViewController.swift
//  MyTodo
//
//  Created by Diego Karlo Manansala on 09/07/2018.
//  Copyright © 2018 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Login"
        
    }
    @IBAction func submitLogin(_ sender: Any) {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        
        if let urlComponents = URLComponents(string: "http://52.221.214.215/get-token/") {
            guard let url = urlComponents.url else { return }
            var json = [String:Any]()
            
            json["username"] = username.text
            json["password"] = password.text
            
            do {
                print("json")
                print(json)
                
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = data
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                dataTask = defaultSession.dataTask(with: request) { data, response, error in
                    
                    // check for any errors
                    guard error == nil else {
                        return
                    }
                    // make sure we got data
                    guard let data = data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        print(response.statusCode)
                        do {
                            let dataDict = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String:Any]
                            
                            if(response.statusCode == 200) {
                                let defaults = UserDefaults.standard
                                defaults.set((dataDict as AnyObject)["token"] as! String, forKey: "accessToken")
                                DispatchQueue.main.async {
                                    if (self.username.text == "admin") {
                                        self.performSegue(withIdentifier: "admin_segue", sender: self)
                                    } else {
                                        self.performSegue(withIdentifier: "user_segue", sender: self)
                                    }
                                }
                            } else {
                                // Create an alert
                                var alert:UIAlertController?
                                
                                if let val = (dataDict as AnyObject)["non_field_errors"] {
                                    let messageArr = val as! [String]
                                    alert = UIAlertController(
                                        title: "Login Error",
                                        message: messageArr[0],
                                        preferredStyle: .alert)
                                } else {
                                    alert = UIAlertController(
                                        title: "Login Error",
                                        message: "An error ocurred while trying to login.",
                                        preferredStyle: .alert)
                                }
                                
                                // Add a "cancel" button to the alert. This one doesn't need a handler
                                alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                DispatchQueue.main.async {
                                    // Present the alert to the user
                                    self.present(alert!, animated: true, completion: nil)
                                }
                            }
                            
                        } catch {
                            
                        }
                    }
                }
                dataTask?.resume()
                
            } catch {
                
            }
        }
    }
}
