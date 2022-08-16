//
//  PlaceAnnotation.swift
//  Want to meet
//
//  Created by kenjimaeda on 15/08/22.
//

import Foundation
import MapKit

enum PlaceType {
	case place
	case poi
}

class PlaceAnnotation: NSObject,MKAnnotation {
	
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	var address: String?
	var type: PlaceType
	
	init(coordinate:CLLocationCoordinate2D,type: PlaceType) {
		self.coordinate = coordinate
		self.type = type
	}
	
	
	
}
