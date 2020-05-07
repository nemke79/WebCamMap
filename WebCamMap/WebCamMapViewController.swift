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
import AMPopTip

class WebCamMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, NetworkSpeedProviderDelegate {
    
    // ContainerView for TutorialPageViewController.
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        sender.removeFromSuperview()
        containerView.removeFromSuperview()
        mapView.isUserInteractionEnabled = true
        citiesTableView.isUserInteractionEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        mapView.alpha = 1.0
        citiesTableView.alpha = 1.0
    }
    
    private var favouriteCities: [FavouriteCities]?
    
    private var tutorialScreen = WelcomePageViewController()
    
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
    
    var activityIndicator = UIActivityIndicatorView()
    
    var tgr = UITapGestureRecognizer()
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    func callWhileSpeedChange(networkStatus: NetworkStatus) {
        switch networkStatus {
        case .poor:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Web Cams Info", message: "You have network problem. User interaction with the app is limited. Please try again later.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    return
                }))
                self.present(alert, animated: true, completion: nil)
                
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
                self.citiesTableView.isUserInteractionEnabled = false
                self.mapView.isUserInteractionEnabled = false
                self.tgr.isEnabled = false
                self.searchButton.isEnabled = true
            }
        case .good:
            DispatchQueue.main.async {
                self.citiesTableView.isUserInteractionEnabled = true
                self.mapView.isUserInteractionEnabled = true
                self.tgr.isEnabled = true
                self.searchButton.isEnabled = true
            }
        case .disConnected:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Web Cams Info", message: "You have network problem. User interaction with the app is limited. Please try again later.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    return
                }))
                self.present(alert, animated: true, completion: nil)
                
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
                self.citiesTableView.isUserInteractionEnabled = false
                self.mapView.isUserInteractionEnabled = false
                self.tgr.isEnabled = false
                self.searchButton.isEnabled = true
            }
        }
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        citiesTableView.isUserInteractionEnabled = false
        mapView.isUserInteractionEnabled = false
        searchButton.isEnabled = false
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = mapView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .darkGray
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        
        mapView.addSubview(activityIndicator)
        
        //Hide searchbar.
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create search request.
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            if response != nil {
                self.activityIndicator.stopAnimating()
                self.citiesTableView.isUserInteractionEnabled = true
                self.mapView.isUserInteractionEnabled = true
                self.searchButton.isEnabled = true
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //Zooming.
                let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.addAnotation(with: coordinate)
                let viewRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                self.mapView.setRegion(viewRegion, animated: false)
            } else if response == nil {
                self.activityIndicator.stopAnimating()
                self.citiesTableView.isUserInteractionEnabled = true
                self.mapView.isUserInteractionEnabled = true
                self.searchButton.isEnabled = true
            }
        }
    }
    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    let context = persistentContainer.viewContext
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // Adding outlet for map
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            tgr = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
            tgr.delegate = self
            mapView.addGestureRecognizer(tgr)
            
        }
    }
    
    
    // List of cities added.
    @IBOutlet weak var citiesTableView: UITableView!
    
    // MARK: ViewController lifecycle methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.isHidden = true
        // Do any additional setup after loading the view.
        
        // If application is first time launched, then show tutorial screen.
        if UIApplication.isFirstLaunch() {
            mapView.alpha = 0.2
            citiesTableView.alpha = 0.2
            containerView.isHidden = false
            mapView.isUserInteractionEnabled = false
            citiesTableView.isUserInteractionEnabled = false
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            closeButton.isHidden = true
        }
        
        spinner?.stopAnimating()
        
        let test = NetworkSpeedTest()
        
        test.delegate = self
        test.networkSpeedTestStop()
        test.networkSpeedTestStart(UrlForTestSpeed: "https://api.windy.com")
        
        citiesTableView.dataSource = self
        citiesTableView.delegate = self
        citiesTableView.rowHeight = 44
        citiesTableView.backgroundView = UIImageView(image: UIImage(named: "OrangeGradientBackground.png"))
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
                
                let indexPath = NSIndexPath(row: 0, section: 0)
                self.citiesTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func addAnotation(with coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        arrayOfAnotations.append(annotation)
        
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error.localizedDescription))")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Web Cams Info", message: "We don't have enough information about this location, please choose another location.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    if placemark.country != nil {
                        self.arrayOfPinsNames.append("\(placemark.locality ?? placemark.name ?? placemark.country ?? placemark.ocean ?? "Unknown location"), \(placemark.country ?? "")")
                    } else {
                        self.arrayOfPinsNames.append("\(placemark.locality ?? placemark.name ?? placemark.country ?? placemark.ocean ?? "Unknown location") \(placemark.country ?? "")")
                    }
                    
                    self.arrayOfPinsCLLocations.append(placemark.location!)
                    
                    self.arrayOfFavourites.append(false)
                    
                    self.citiesTableView.reloadData()
                    
                    let indexPath = NSIndexPath(row: self.arrayOfPinsNames.count-1, section: 0)
                    self.citiesTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    // Gesture for adding pins to map
    @objc func tapGestureHandler(tgr: UITapGestureRecognizer)
    {
        let touchPoint = tgr.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        addAnotation(with: touchMapCoordinate)
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(18.0))
    }
    
    // MARK: TableView methods.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfPinsNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityName", for: indexPath)
        
        if let cityNameCell = cell as? CityNameCell {
            
            let attrText = NSAttributedString(string: arrayOfPinsNames[indexPath.row], attributes: [.font: font])
            
            cityNameCell.cityName.attributedText = attrText
            
            if arrayOfFavourites[indexPath.row] == true {
                cityNameCell.favouriteButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
            } else {
                cityNameCell.favouriteButton.setImage(UIImage(systemName: "video"), for: .normal)
            }
            
            // Action when user taps favourite button on cell.
            cityNameCell.actionBlock = {
                if cityNameCell.favouriteButton.currentImage! == UIImage(systemName: "video"){
                    cityNameCell.favouriteButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
                    FavouriteCities.addFavouriteCity(name: cityNameCell.cityName.text!, latitude: self.arrayOfAnotations[indexPath.row].coordinate.latitude, longitude: self.arrayOfAnotations[indexPath.row].coordinate.longitude, context: self.context)
                    self.arrayOfFavourites[indexPath.row] = true
                    
                    try? self.context.save()
                } else if cityNameCell.favouriteButton.currentImage! == UIImage(systemName: "video.fill") {
                    cityNameCell.favouriteButton.setImage(UIImage(systemName: "video"), for: .normal)
                    FavouriteCities.deleteFavouriteCity(latitude: self.arrayOfAnotations[indexPath.row].coordinate.latitude, longitude: self.arrayOfAnotations[indexPath.row].coordinate.longitude, into: self.context)
                    self.arrayOfFavourites[indexPath.row] = false
                    try? self.context.save()
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if arrayOfFavourites[indexPath.row] == true {
                FavouriteCities.deleteFavouriteCity(latitude: arrayOfAnotations[indexPath.row].coordinate.latitude, longitude: arrayOfAnotations[indexPath.row].coordinate.longitude, into: self.context)
                try? self.context.save()
            }
            mapView.removeAnnotation(arrayOfAnotations[indexPath.row])
            arrayOfAnotations.remove(at: indexPath.row)
            arrayOfPinsNames.remove(at: indexPath.row)
            arrayOfPinsCLLocations.remove(at: indexPath.row)
            arrayOfFavourites.remove(at: indexPath.row)
            citiesTableView.deleteRows(at: [indexPath], with: .fade)
            citiesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        baseURL = "https://api.windy.com/api/webcams/v2/list/nearby=\(arrayOfPinsCLLocations[indexPath.row].coordinate.latitude),\(arrayOfPinsCLLocations[indexPath.row].coordinate.longitude),20/orderby=distance/limit=50?show=webcams:player,image&key=BWCdRgohrnZPoVqrPYWcyU7N1sbR4ko4"
        
        let viewRegion = MKCoordinateRegion(center: arrayOfPinsCLLocations[indexPath.row].coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(viewRegion, animated: false)
        
        spinner?.startAnimating()
        
        
        // Disable user interaction while spinner is active.
        citiesTableView.isUserInteractionEnabled = false
        mapView.isUserInteractionEnabled = false
        searchButton.isEnabled = false
        
        requestWebCam{ (data, success) in
            
            guard let _ = data else {return}
            
        }
    }
    
    //MARK: Segues.
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
            case "showInfo":
                if let popoverHelpENoteVC = segue.destination as? InfoViewController {
                    popoverHelpENoteVC.popoverPresentationController?.delegate = self
                }
            default: break
            }
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneInfo))
        let nav = UINavigationController(rootViewController: controller.presentedViewController)
        nav.topViewController!.navigationItem.rightBarButtonItem = btnDone
        return nav
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 1)
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 0.7)
    }
    
    func setAlphaOfBackgroundViews(alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = alpha;
            self.navigationController?.navigationBar.alpha = alpha;
        }
    }
    
    @objc func doneInfo(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func requestWebCam(completion: @escaping (Any?, Bool) -> ()) {
        let url = URL(string: baseURL)
        
        let dataTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if response != nil {
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
                    self.mapView.isUserInteractionEnabled = true
                    self.searchButton.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.spinner?.stopAnimating()
                    let alert = UIAlertController(title: "Web Cams Info", message: "You have network problem. User interaction with the app is limited. Please try again later.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.citiesTableView.isUserInteractionEnabled = true
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
                
                let imageURL = URL(string: currentDict["thumbnail"] as! String)!
                let data = NSData(contentsOf: imageURL)
                
                let image = UIImage(data: data! as Data)
                
                self.webCamInfo.link = dayDict["embed"] as! String
                
                self.webCamInfo.image = image!
                
                self.webCamInfo.title = jsonWebCam["title"] as! String
                
                self.webCamsInfo.append(self.webCamInfo)
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

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}

extension UIApplication {
    static func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "HasLaunched") {
            UserDefaults.standard.set(true, forKey: "HasLaunched")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}
