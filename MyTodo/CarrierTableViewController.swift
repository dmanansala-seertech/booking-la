//
//  ViewController.swift
//  MyTodo
//
//  Created by Diego Karlo Manansala on 05/07/2018.
//  Copyright © 2018 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class CarrierTableViewController: UITableViewController {
    var todoItems = [AnyObject]()
    var selected_carrier_name:String = ""
    var selected_carrier_id:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        
        if let urlComponents = URLComponents(string: "http://52.221.214.215/carriers/") {
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let defaults = UserDefaults.standard
            let accessToken = defaults.string(forKey: "accessToken")
            print("Token \(String(describing: accessToken!))")
            request.addValue("Token \(String(describing: accessToken!))", forHTTPHeaderField: "Authorization")
            
            dataTask = defaultSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("error")
                    print(error)
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        
                        let dataDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [AnyObject]
                        
                        DispatchQueue.main.async {
                            self.todoItems = dataDict
                            self.tableView.reloadData()
                        }
                        
                    } catch {
                        
                    }
                }
            }
            dataTask?.resume()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carrier_cell", for: indexPath)
        if indexPath.row < todoItems.count
        {
            
            let item = todoItems[indexPath.row]
            
            cell.textLabel?.text = item["carrier_name"] as? String
            cell.detailTextLabel?.text = "Code: \(String(describing: item["code"] as! String))"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if indexPath.row < todoItems.count
        {
            
            let confirmation = UIAlertController(
                title: "Delete Carrier",
                message: "Are you sure you want to delete this carrier?",
                preferredStyle: .alert)
            
            
            confirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            confirmation.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                let defaultSession = URLSession(configuration: .default)
                var dataTask: URLSessionDataTask?
                
                let item = self.todoItems[indexPath.row]
                let item_id = String(describing: item["id"] as! Int)
                
                
                if let urlComponents = URLComponents(string: "http://52.221.214.215/carriers/\(String(describing: item_id))/") {
                    guard let url = urlComponents.url else { return }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "DELETE"
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
                        
                        if let response = response as? HTTPURLResponse {
                            if(response.statusCode == 204) {
                                DispatchQueue.main.async {
                                    self.todoItems.remove(at: indexPath.row)
                                    self.tableView.deleteRows(at: [indexPath], with: .top)
                                }
                            } else {
                                let alert = UIAlertController(
                                    title: "Error",
                                    message: "Could not delete carrier",
                                    preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                DispatchQueue.main.async {
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    dataTask?.resume()
                    
                }
            }))
            
            DispatchQueue.main.async {
                self.present(confirmation, animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < todoItems.count
        {
            let item = todoItems[indexPath.row]
            selected_carrier_id = String(describing: (item["id"] as! CFNumber))
            selected_carrier_name = (item["carrier_name"] as? String)!
            
            self.performSegue(withIdentifier: "show_carrier_flights", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_carrier_flights" {
            let viewController = segue.destination as! ViewController
            viewController.selected_carrier_id = selected_carrier_id
            viewController.selected_carrier_name = selected_carrier_name
        }
    }
}

