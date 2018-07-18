//
//  AddEventViewController.swift
//  MyTodo
//
//  Created by Diego Karlo Manansala on 09/07/2018.
//  Copyright © 2018 Diego Karlo Manansala. All rights reserved.
//


import UIKit

class AddEventViewController: UIViewController {
    var selected_carrier_id : String?
    
    @IBOutlet weak var sourceLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    @IBOutlet weak var eventStart: UITextField!
    @IBOutlet weak var eventEnd: UITextField!
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Flight"
    
        createStartDatePicker()
        createEndDatePicker()
    }
    
    func createStartDatePicker() {
        startDatePicker.datePickerMode = .dateAndTime
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneStart))
        toolbar.setItems([doneButton], animated: true)
        eventStart.inputAccessoryView = toolbar
        
        eventStart.inputView = startDatePicker
        
    }
    
    func createEndDatePicker() {
        endDatePicker.datePickerMode = .dateAndTime
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEnd))
        toolbar.setItems([doneButton], animated: true)
        eventEnd.inputAccessoryView = toolbar
        
        eventEnd.inputView = endDatePicker
        
    }
    
    @objc func doneStart() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm a"
        let dateString = dateFormatter.string(from: startDatePicker.date)
        
        eventStart.text = dateString
        self.view.endEditing(true)
    }
    
    @objc func doneEnd() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm a"
        let dateString = dateFormatter.string(from: endDatePicker.date)
        
        eventEnd.text = dateString
        self.view.endEditing(true)
    }
    
    @IBAction func submitNewEvent(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:00'Z'" // 2018-07-09T00:00:00Z
        
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        
        if let urlComponents = URLComponents(string: "http://52.221.214.215/flights/") {
            guard let url = urlComponents.url else { return }
            
            var json = [String:Any]()
            json["carrier"] = String(describing: selected_carrier_id!)
            json["source"] = sourceLocation.text
            json["destination"] = destinationLocation.text
            json["booking_date_from"] = dateFormatter.string(from: startDatePicker.date)
            json["booking_date_to"] = dateFormatter.string(from: endDatePicker.date)
            
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
                                message: "Could not create event",
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

