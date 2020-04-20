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
import CoreData

class WebCamMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    private var favouriteCities: [FavouriteCities]?
    
    let cityCell = CityNameCell()
    
    let locationManager = CLLocationManager()
    
    var arrayOfPinsCLLocations = [CLLocation]()
    
    var arrayOfPinsNames = [String]()
    
    var arrayOfFavourites = [Bool]()
    
    var arrayOfAnotations = [MKAnnotation]()
    
    private var currentLocation: CLLocation?
    
    var baseURL = String()
    
    var webCamsInfo = [WebCamInfo]()
    
    var webCamInfo = WebCamInfo()
    
    var counter = 0
    
    //    @IBAction func favouriteButtonTapped(_ sender: Any) {
    //        CityNameCell.actionBlock?()
    //    }
    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    let context = persistentContainer.viewContext
    
    
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
        citiesTableView.rowHeight = 44
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
        
        reloadDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webCamsInfo.removeAll()
    }
    
    private func reloadDatabase() {
        let request: NSFetchRequest<FavouriteCities> = FavouriteCities.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        favouriteCities = try? context.fetch(request)
        
        if favouriteCities!.count > 0 {
            for favCity in favouriteCities! {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: favCity.latitude, longitude: favCity.longitude)
                mapView.addAnnotation(annotation)
                
                arrayOfAnotations.append(annotation)
                
                let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                
                self.arrayOfPinsNames.append(favCity.cityName!)
                
                self.arrayOfPinsCLLocations.append(location)
                
                self.arrayOfFavourites.append(true)
                
                self.citiesTableView.reloadData()
                
                let indexPath = NSIndexPath(row: self.arrayOfPinsNames.count-1, section: 0)
                self.citiesTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            }
        }
        
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
                    
                    self.arrayOfFavourites.append(false)
                    
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
        
        if let cityNameCell = cell as? CityNameCell {
            
            let attrText = NSAttributedString(string: arrayOfPinsNames[indexPath.row], attributes: [.font: font])
            
            cityNameCell.cityName.attributedText = attrText
            
            if arrayOfFavourites[indexPath.row] == true {
                cityNameCell.favouriteButton.setImage(UIImage(systemName: "video.circle.fill"), for: .normal)
            } else {
                cityNameCell.favouriteButton.setImage(UIImage(systemName: "video.circle"), for: .normal)
            }
            
            // Action when user taps favourite button on cell.
            
            cityNameCell.actionBlock = {
                if cityNameCell.favouriteButton.currentImage! == UIImage(systemName: "video.circle"){
                    for value in self.arrayOfFavourites {
                        if value == true {
                            self.counter += 1
                        } else {
                            break
                        }
                    }
                    cityNameCell.favouriteButton.setImage(UIImage(systemName: "video.circle.fill"), for: .normal)
                    FavouriteCities.addFavouriteCity(name: cityNameCell.cityName.text!, latitude: self.arrayOfAnotations[indexPath.row].coordinate.latitude, longitude: self.arrayOfAnotations[indexPath.row].coordinate.longitude, context: self.context)
                    self.arrayOfFavourites[indexPath.row] = true
                    
                    try? self.context.save()
                    
                    // Move row to the top of tableview when its added to favourites, below other favourites. Otherwise, remove it from favourites and put it below favourites.
                    
                    self.citiesTableView.beginUpdates()
                    
                    self.citiesTableView.moveRow(at: indexPath, to: IndexPath(row: self.counter, section: 0))
                    
                    self.citiesTableView.endUpdates()
            
                    self.arrayOfFavourites.insert(self.arrayOfFavourites.remove(at: indexPath.row), at: self.counter)
                    self.arrayOfPinsNames.insert(self.arrayOfPinsNames.remove(at: indexPath.row), at: self.counter)
                    self.arrayOfAnotations.insert(self.arrayOfAnotations.remove(at: indexPath.row), at: self.counter)
                    self.arrayOfPinsCLLocations.insert(self.arrayOfPinsCLLocations.remove(at: indexPath.row), at: self.counter)
                
                    self.citiesTableView.reloadData()
                    
                    let indxPath = NSIndexPath(row: self.counter, section: 0)
                    
                    self.citiesTableView.scrollToRow(at: indxPath as IndexPath, at: .top, animated: true)
                    
                    self.counter = 0
                    
                } else if cityNameCell.favouriteButton.currentImage! == UIImage(systemName: "video.circle.fill") {
                    for value in self.arrayOfFavourites {
                        if value == true {
                            self.counter += 1
                        } else {
                            break
                        }
                    }
                    cityNameCell.favouriteButton.setImage(UIImage(systemName: "video.circle"), for: .normal)
                    FavouriteCities.deleteFavouriteCity(matching: indexPath.row, into: self.context)
                    self.arrayOfFavourites[indexPath.row] = false
                    try? self.context.save()
                    
                    self.citiesTableView.beginUpdates()
                    
                    self.citiesTableView.moveRow(at: indexPath, to: IndexPath(row: self.counter - 1, section: 0))
                    
                    self.citiesTableView.endUpdates()
                    
                    self.arrayOfFavourites.insert(self.arrayOfFavourites.remove(at: indexPath.row), at: self.counter - 1)
                    self.arrayOfPinsNames.insert(self.arrayOfPinsNames.remove(at: indexPath.row), at: self.counter - 1)
                    self.arrayOfAnotations.insert(self.arrayOfAnotations.remove(at: indexPath.row), at: self.counter - 1)
                    self.arrayOfPinsCLLocations.insert(self.arrayOfPinsCLLocations.remove(at: indexPath.row), at: self.counter - 1)
                    
                    self.citiesTableView.reloadData()
                    
                    self.counter = 0
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mapView.removeAnnotation(arrayOfAnotations[indexPath.row])
            arrayOfAnotations.remove(at: indexPath.row)
            arrayOfPinsNames.remove(at: indexPath.row)
            arrayOfPinsCLLocations.remove(at: indexPath.row)
            if arrayOfFavourites[indexPath.row] == true {
                FavouriteCities.deleteFavouriteCity(matching: indexPath.row, into: self.context)
                try? self.context.save()
            }
            arrayOfFavourites.remove(at: indexPath.row)
            citiesTableView.deleteRows(at: [indexPath], with: .fade)
            citiesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        baseURL = "https://api.windy.com/api/webcams/v2/list/nearby=\(arrayOfPinsCLLocations[indexPath.row].coordinate.latitude),\(arrayOfPinsCLLocations[indexPath.row].coordinate.longitude),20/orderby=distance/limit=50?show=webcams:player,image&key=BWCdRgohrnZPoVqrPYWcyU7N1sbR4ko4"
        
        let viewRegion = MKCoordinateRegion(center: arrayOfPinsCLLocations[indexPath.row].coordinate, latitudinalMeters: 900000, longitudinalMeters: 900000)
        mapView.setRegion(viewRegion, animated: false)
        
        spinner?.startAnimating()
        
        
        // Disable user interaction while spinner is active.
        citiesTableView.isUserInteractionEnabled = false
        
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
            if error == nil, self.webCamsInfo.count > 0 {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showWebCamInfo", sender: self)
                }
            } else if error == nil, self.webCamsInfo.count == 0 {
                DispatchQueue.main.async {
                    self.spinner?.stopAnimating()
                    let alert = UIAlertController(title: "Web Cams Info", message: "No web cameras nearby for this location.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // Enable user interaction after fetching Data is over.
            DispatchQueue.main.async {
                self.citiesTableView.isUserInteractionEnabled = true
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
                
                let imageURL = URL(string: currentDict["thumbnail"] as! String)!
                let data = NSData(contentsOf: imageURL)
                
                let image = UIImage(data: data! as Data)
                
                DispatchQueue.main.async {
                    
                    self.webCamInfo.link = dayDict["embed"] as! String
                    
                    self.webCamInfo.image = image!
                    
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
