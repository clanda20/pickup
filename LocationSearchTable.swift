//
//  LocationSearchTable.swift
//  pickup
//
//  Created by christian landa on 8/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var mapViewLarge: MKMapView? = nil
    
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var handleMapSearchEditEventDelegate:HandleMapSearchEditEvent? = nil    //EditEventVC
    
   
    
    
   
    
    
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    
}
extension LocationSearchTable : UISearchResultsUpdating {
//    @available(iOS 8.0, *)
//    public func updateSearchResults(for searchController: UISearchController) {
//        //<#code#>
//    }


    func updateSearchResults(for searchController: UISearchController){
        guard let mapViewLarge = mapViewLarge,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapViewLarge.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
}

extension LocationSearchTable {
      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
     override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}

extension LocationSearchTable {
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
         handleMapSearchEditEventDelegate?.dropPinZoomIn(placemark: selectedItem) //just added
        dismiss(animated: true, completion: nil)
    }
}
