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


struct Place {
	let name: String
	let latitude: CLLocationDegrees
	let longitude: CLLocationDegrees
	let adress: String
	
	
	//para trabalhar com pins no mapa
	var corrdinates: CLLocationCoordinate2D {
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
	
	static func getRegion(_ placeMark: CLPlacemark?) -> (regionCoordinate: MKCoordinateRegion?,name: String?)  {
		if let placeMark = placeMark, let coordinate = placeMark.location?.coordinate {
			
			//quanto maior o latitudinalMeters,longitudinalMeters maior
			//mapa fica para cliente
			let regionCoordinate = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
			let name = placeMark.name
			
			return (regionCoordinate,name)
		}
		return (nil,nil)
	}
	
	static func showMessage(with type: PlaceFinderMessageType,view viewAlert: UIViewController) {
		var title: String
		var message: String
		var hasConfirm = false
		
		switch type {
		case .name(let name):
			title = "Found location"
			message = "You would like add \(name)"
			hasConfirm = true
		case .error(let error):
			title = "Error"
			message = error
		}
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancel)
		
		if hasConfirm {
			let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
				print("ok")
			}
			alert.addAction(confirm)
		}
		
		viewAlert.present(alert, animated: true, completion: nil)
		
	}
	
	static func getLocationByTap(gesture: UIGestureRecognizer,where view:  MKMapView) -> CLLocation {
		//pego as posicoes x e y da view que foi tocada
		let point = gesture.location(in: view)
		let coordinate =  view.convert(point, toCoordinateFrom: view)
		let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    return location
	}
	
}
