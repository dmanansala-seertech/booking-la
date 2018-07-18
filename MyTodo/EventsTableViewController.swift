//
//  EventsTableViewController.swift
//  MyTodo
//
//  Created by Diego Karlo Manansala on 09/07/2018.
//  Copyright © 2018 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var flightSearchBar: UISearchBar!
    var todoItems = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UINib(nibName: "FlightTableViewCell", bundle: nil), forCellReuseIdentifier: "user_todo")
        flightSearchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        flightSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        flightSearchBar.showsCancelButton = false
        flightSearchBar.text = ""
        flightSearchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        print("http://52.221.214.215/flights/?source=\(searchText)")
        if let urlComponents = URLComponents(string: "http://52.221.214.215/flights/?source=\(searchText)") {
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let defaults = UserDefaults.standard
            let accessToken = defaults.string(forKey: "accessToken")
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
                        print("dataDict")
                        print(dataDict)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        
        if let urlComponents = URLComponents(string: "http://52.221.214.215/flights/") {
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let defaults = UserDefaults.standard
            let accessToken = defaults.string(forKey: "accessToken")
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 139
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_todo", for: indexPath) as! FlightTableViewCell
        if indexPath.row < todoItems.count
        {
            let strToDateFormatter = DateFormatter()
            strToDateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
            let dateToStrFormatter = DateFormatter()
            dateToStrFormatter.dateFormat = "YYYY-MM-dd hh:mm a"
            
            let item = todoItems[indexPath.row]
            let booking_date_from = item["booking_date_from"] as! String
            let formatted_booking_date_from = strToDateFormatter.date(from:booking_date_from)!
            
            let booking_date_to = item["booking_date_to"] as! String
            let formatted_booking_date_to = strToDateFormatter.date(from:booking_date_to)!
            
            cell.flightName?.text = item["name"] as? String
            cell.flightDetails?.text = "From: \(String(describing: item["source"] as! String))"
            cell.flightDestination?.text = "To: \(String(describing: item["destination"] as! String))"
            cell.departureTime?.text = "Departure Time:\(dateToStrFormatter.string(from: formatted_booking_date_from))"
            cell.arrivalTime?.text = "Arrival Time:\(dateToStrFormatter.string(from: formatted_booking_date_to))"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < todoItems.count
        {
            
            var confirmation = UIAlertController(
                title: "Book Flight",
                message: "Are you sure you want to book this flight?",
                preferredStyle: .alert)
            
            
            confirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            confirmation.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
                let item = self.todoItems[indexPath.row]
                
                let defaultSession = URLSession(configuration: .default)
                var dataTask: URLSessionDataTask?
                
                
                if let urlComponents = URLComponents(string: "http://52.221.214.215/user_flights/") {
                    guard let url = urlComponents.url else { return }
                    
                    var json = [String:Any]()
                    
                    json["flight"] = item["id"] as! Int
                    
                    do {
                        
                        let data = try JSONSerialization.data(withJSONObject: json, options: [])
                        
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
                                do {
                                    let dataDict = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String:Any]
                                    if (response.statusCode == 201) {
                                        
                                        DispatchQueue.main.async {
                                            self.tabBarController?.selectedIndex = 0
                                        }
                                    } else {
                                        var alert:UIAlertController?
                                        
                                        if let val = (dataDict as AnyObject)["flight"] {
                                            let messageArr = val as! [String]
                                            alert = UIAlertController(
                                                title: "Booking Error",
                                                message: messageArr[0],
                                                preferredStyle: .alert)
                                        } else {
                                            alert = UIAlertController(
                                                title: "Booking Error",
                                                message: "An error ocurred while trying to book this flight.",
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
            }))
            
            DispatchQueue.main.async {
                self.present(confirmation, animated: true, completion: nil)
            }
        }
    }
}
