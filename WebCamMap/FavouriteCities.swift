//
//  FavouriteCities.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 11/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit
import CoreData

class FavouriteCities: NSManagedObject {
    
    class func addFavouriteCity(name: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let favouriteCity = FavouriteCities(context: context)
        favouriteCity.cityName = name
        favouriteCity.latitude = latitude
        favouriteCity.longitude = longitude
        favouriteCity.isFavourite = true
        favouriteCity.dateCreated = Date()
    }
    
    class func deleteFavouriteCity(matching item: Int, into context: NSManagedObjectContext ) {
        let request: NSFetchRequest<FavouriteCities> = FavouriteCities.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        let favouriteCity = try? context.fetch(request)
        
        if favouriteCity!.count > 0 {
            context.delete(favouriteCity![item])
        }
}
}
