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
    
    // Working with CoreData.
    class func addFavouriteCity(name: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let request: NSFetchRequest<FavouriteCities> = FavouriteCities.fetchRequest()
        
        // In predicate we use long float - lf for compare because otherwise values that are compared never will be the same, because float and double precision is not 100%.
        request.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        let favouriteCity = try? context.fetch(request)
        
        if favouriteCity!.count == 0 {
            let favCity = FavouriteCities(context: context)
            favCity.cityName = name
            favCity.latitude = latitude
            favCity.longitude = longitude
            favCity.dateCreated = Date()
        }
    }
    
    class func deleteFavouriteCity(latitude: Double, longitude: Double, into context: NSManagedObjectContext ) {
        let request: NSFetchRequest<FavouriteCities> = FavouriteCities.fetchRequest()
        
        // In predicate we use long float - lf for compare because otherwise values that are compared never will be the same, because float and double precision is not 100%.
        request.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        let favouriteCity = try? context.fetch(request)
        
        if favouriteCity!.count > 0 {
            context.delete(favouriteCity!.first!)
        }
    }
}
