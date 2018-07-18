//
//  AddCarrierViewController.swift
//  MyTodo
//
//  Created by Diego Karlo Manansala on 13/07/2018.
//  Copyright © 2018 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class AddCarrierViewController: UIViewController {

    @IBOutlet weak var carrierName: UITextField!
    @IBOutlet weak var carrierCode: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addNewCarrier(_ sender: Any) {
        
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        
        if let urlComponents = URLComponents(string: "http://52.221.214.215/carriers/") {
            guard let url = urlComponents.url else { return }
            
            var json = [String:Any]()
            json["carrier_name"] = carrierName.text
            json["code"] = carrierCode.text
            
            do {
                
                print("json")
                print(json)
                
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                
                print("data")
                print(data)
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = data
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let defaults = UserDefaults.standard
                let accessToken = defaults.string(forKey: "accessToken")
                request.addValue("Token \(String(describing: accessToken!))", forHTTPHeaderField: "Authorization")
                
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
                        if (response.statusCode == 201) {
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            let alert = UIAlertController(
                                title: "Error",
                                message: "Could not create carrier",
                                preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                        
                    }
                }
                dataTask?.resume()
                
            } catch {
                
            }
        }
    }
}
