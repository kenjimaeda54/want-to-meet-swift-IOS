//
//  Place.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import Foundation
import CoreLocation
import MapKit



enum PlaceFinderMessageType {
	case name(String)
	case error(String)
}


struct Place: Codable  {
	
	var latitude: CLLocationDegrees
	var longitude: CLLocationDegrees
	var name: String
	var address: String
	
	//para trabalhar com pins no mapa
	var coordinates: CLLocationCoordinate2D {
		return  CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	
static	func formaterAdress(_ placeMark: CLPlacemark) -> String {
		var adress = ""
		
		if let street = placeMark.thoroughfare   {
			adress += "\(street)"  // rua
		}
		if let number = placeMark.subThoroughfare {
			adress += ",\(number)" // numero da rua
		}
		if let	district = placeMark.subLocality {
			adress += ",\(district)" // bairro
		}
		
		if let city = placeMark.locality {
			adress += "\n\(city)," //cidade
		}
		
		if let state = placeMark.administrativeArea {
			adress += "\(state)" //estado
		}
		
		if let postalCode = placeMark.postalCode {
			adress += "- CEP:\(postalCode)\n" //cep
		}
		
		if let country = placeMark.country {
			adress += "\n\(country)" // pais
		}
		return adress
	}
	
	
}


//assim que compara objetos em swift

extension Place:Equatable {
 static	func ==(lhs:Place,rsh:Place) -> Bool {
	 return lhs.latitude == rsh.latitude && lhs.longitude == rsh.longitude
	}
}
