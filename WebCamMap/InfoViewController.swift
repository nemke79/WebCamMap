//
//  InfoWebCamMapViewController.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 21/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    private let howToUseText = "\n\nWebCamMap uses API from api.windy.com to show webcams around the world.\n\nSearch for the location on map, or drag map to desired location. Then you can select point on map, and below map is the list of selected locations. If you click on any element of that list, and if there are any webcams within 20km of selected location, app will show it. You can then click on webcam you want and app will open browser and go to api.windy.com to show you that webcam you've selected. There you can see day timelapse of that webcam.\n\nAlso, you can add to favourites locations which webcams you like. You add location to favourites by clicking on movie image which is positioned on the right of every element(location) in the list - movie image will become filled.Favourites are automatically saved in the phone storage. When you open app again, favourites are there.\n\nYou want to remove location from favourites? Click again on movie image, and location is removed from favourites - movie image is not filled anymore. You can also remove locations by swiping them to the left - they will be removed from list and from storage if location is favourite."
    
    private let rateWebCamMapText = "\n\nLeave your review and rate WebCamMap in App Store."
    
    private let howToUse = "HOW TO USE"
    private let rateWebCamMap = "\n\nRATE WEBCAMMAP"
    private let contactMe = "\n\nCONTACT ME\n"
    
    @IBOutlet weak var infoTextView: UITextView!
    
    private let twitterAttachment = NSTextAttachment()
    
    private var titleFont: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(18.0).bold())
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(16.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        twitterAttachment.image = UIImage(named: "Twitter.png")
        
        twitterAttachment.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        let twitterImage = NSAttributedString(attachment: twitterAttachment)
        
        let attrHowToUse = NSAttributedString(string: howToUse, attributes: [.font: titleFont])
        let attrRateExtraNotes = NSAttributedString(string: rateWebCamMap, attributes: [.font:titleFont])
        let attrContactMe = NSAttributedString(string: contactMe, attributes: [.font:titleFont])
        
        let attrHowToUseText = NSAttributedString(string: howToUseText, attributes: [.font: font])
        let attrRateExtraNotesText = NSAttributedString(string: rateWebCamMapText, attributes: [.font:font])
        
        let attributedHelpText = NSMutableAttributedString()
        
        attributedHelpText.append(attrHowToUse)
        attributedHelpText.append(attrHowToUseText)
        attributedHelpText.append(attrRateExtraNotes)
        attributedHelpText.append(attrRateExtraNotesText)
        attributedHelpText.append(attrContactMe)
        attributedHelpText.append(twitterImage)
        
        let linkRangeRate = attributedHelpText.mutableString.range(of: rateWebCamMapText)
        attributedHelpText.addAttribute(NSAttributedString.Key.link, value: "https://twitter.com/Nemke79", range: linkRangeRate)
        
        let linkRangeContact = attributedHelpText.mutableString.range(of: twitterImage.string)
        attributedHelpText.addAttribute(NSAttributedString.Key.link, value: "https://twitter.com/Nemke79", range: linkRangeContact)
        
        infoTextView.attributedText = attributedHelpText
        infoTextView.linkTextAttributes = [
            kCTForegroundColorAttributeName: UIColor.blue
            ] as [NSAttributedString.Key : Any]
    }
    
    // Scroll textview to the top. Needed for small screens - iPhone SE
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        infoTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
}
