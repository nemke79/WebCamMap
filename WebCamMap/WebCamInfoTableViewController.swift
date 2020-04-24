//
//  WebCamInfoTableViewController.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 03/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit

class WebCamInfoTableViewController: UITableViewController {
    
    
    // Initializing webCams dictionary.
    var webCams = [WebCamInfo]()
    var names = String()
    
    var heightForHeader = 5

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner?.startAnimating()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "OrangeGradientBackground.png"))
        
        self.title = names
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return webCams.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(heightForHeader)
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(16.0))
      }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebCamInfoCell", for: indexPath)
    
        let attrText = NSAttributedString(string: webCams[indexPath.section].title, attributes: [.font: font])
        cell.textLabel?.attributedText = attrText

        cell.imageView!.image = webCams[indexPath.section].image

        cell.imageView?.layer.borderWidth = 1.0
        cell.imageView?.layer.borderColor = UIColor.darkGray.cgColor

        cell.imageView?.layer.cornerRadius = 10
  

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: webCams[indexPath.section].link)!
        UIApplication.shared.open(url, options: [:])
    }

}
