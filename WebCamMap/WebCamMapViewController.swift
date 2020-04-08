//
//  WebCamMapViewController.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 03/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class WebCamMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    let locationManager = CLLocationManager()
    
    var arrayOfPinsCLLocations = [CLLocation]()
    
    var arrayOfPinsNames = [String]()
    
    var arrayOfAnotations = [MKAnnotation]()
    
    private var currentLocation: CLLocation?
    
    let myPin = MKPointAnnotation()
    
    var baseURL = String()
    
    var webCamsInfo = [WebCamInfo]()
    
    var webCamInfo = WebCamInfo()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // Adding outlet for map
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            let tgr = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
            tgr.delegate = self
            mapView.addGestureRecognizer(tgr)
            
        }
    }
    
    
    // List of cities added.
    @IBOutlet weak var citiesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        spinner?.stopAnimating()
        
        citiesTableView.dataSource = self
        citiesTableView.delegate = self
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webCamsInfo.removeAll()
    }
    
    // Gesture for adding pins to map
    
    @objc func tapGestureHandler(tgr: UITapGestureRecognizer)
    {
        let touchPoint = tgr.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
        
        arrayOfAnotations.append(annotation)
        
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    self.arrayOfPinsNames.append("\(placemark.locality ?? placemark.name ?? placemark.country ?? placemark.ocean ?? "Unknown location") \(placemark.country ?? "")")
                    self.arrayOfPinsCLLocations.append(placemark.location!)
                    
                    self.citiesTableView.reloadData()
                    
                    let indexPath = NSIndexPath(row: self.arrayOfPinsNames.count-1, section: 0)
                    self.citiesTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                    
                }
            }
        }
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(18.0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfPinsNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityName", for: indexPath)
        
        let attrText = NSAttributedString(string: arrayOfPinsNames[indexPath.row], attributes: [.font: font])
        
        cell.textLabel?.attributedText = attrText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mapView.removeAnnotation(arrayOfAnotations[indexPath.row])
            arrayOfAnotations.remove(at: indexPath.row)
            arrayOfPinsNames.remove(at: indexPath.row)
            arrayOfPinsCLLocations.remove(at: indexPath.row)
            citiesTableView.deleteRows(at: [indexPath], with: .fade)
            citiesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        baseURL = "https://api.windy.com/api/webcams/v2/list/nearby=\(arrayOfPinsCLLocations[indexPath.row].coordinate.latitude),\(arrayOfPinsCLLocations[indexPath.row].coordinate.longitude),20/orderby=distance/limit=50?show=webcams:player,image&key=BWCdRgohrnZPoVqrPYWcyU7N1sbR4ko4"
        
        spinner?.startAnimating()
        
        requestWebCam{ (data, success) in
            
            guard let _ = data else {return}
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showWebCamInfo":
                if let webCamInfoVC = segue.destination.contents as? WebCamInfoTableViewController {
                    if let indexPath = citiesTableView.indexPathForSelectedRow {
                        webCamInfoVC.names = arrayOfPinsNames[indexPath.row]
                        
                        webCamInfoVC.webCams = self.webCamsInfo
                        
                         spinner?.stopAnimating()
                    }
                }
                
            default: break
            }
        }
    }
    
    func requestWebCam(completion: @escaping (Any?, Bool) -> ()) {
        let url = URL(string: baseURL)

        let dataTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            self.fetchData(data: data, response: response!, error: error, completion: completion)
            if error == nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showWebCamInfo", sender: self)
                }
            }
            
        }
        
        dataTask.resume()
        
    }
    
    private func fetchData(data: Data?, response: URLResponse, error: Error?, completion: @escaping (Any?, Bool) -> ()) {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            
            let info = jsonData
            let result = info!["result"] as! [String: AnyObject]
            let jsonWebCams = result["webcams"] as! [AnyObject]
            
            for jsonWebCam in jsonWebCams {
                
                let imageDict = jsonWebCam["image"] as! [String: AnyObject]
                let currentDict = imageDict["current"] as! [String: AnyObject]
                
                let playerDict = jsonWebCam["player"] as! [String: AnyObject]
                let dayDict = playerDict["day"] as! [String: AnyObject]
                
                DispatchQueue.main.async {
                    
                    self.webCamInfo.link = dayDict["embed"] as! String
                    
                    self.webCamInfo.image = currentDict["thumbnail"] as! String
                    
                    self.webCamInfo.title = jsonWebCam["title"] as! String
                    
                    self.webCamsInfo.append(self.webCamInfo)
                }
            }
        } catch let error as NSError {
            print("Decoding error \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: false)
                
                myPin.coordinate = userLocation.coordinate
                
                mapView.addAnnotation(myPin)
                
                arrayOfAnotations.append(myPin)
                
                let location = CLLocation(latitude: myPin.coordinate.latitude, longitude: myPin.coordinate.longitude)
                
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    // Process Response
                    if let error = error {
                        print("Unable to Reverse Geocode Location (\(error))")
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first {
                            
                            self.arrayOfPinsNames.append("\(placemark.locality ?? placemark.name ?? placemark.country ?? placemark.ocean ?? "Unknown location") \(placemark.country ?? "")")
                            self.arrayOfPinsCLLocations.append(placemark.location!)
                            self.citiesTableView.reloadData()
                            
                            let indexPath = NSIndexPath(row: self.arrayOfPinsNames.count-1, section: 0)
                            self.citiesTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
