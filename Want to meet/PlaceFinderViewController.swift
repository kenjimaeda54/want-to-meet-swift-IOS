//
//  PlaceFinderViewController.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import UIKit
import MapKit

enum PlaceAlert {
	case name(String)
	case error(String)
}

protocol PlaceFinderDelegate {
	func getPlace(_ place: Place)
}


class PlaceFinderViewController: UIViewController {
	
	@IBOutlet weak var actLoading: UIActivityIndicatorView!
	@IBOutlet weak var vwLoading: UIView!
	@IBOutlet weak var mkMapKit: MKMapView!
	@IBOutlet weak var btnSearch: UIButton!
	@IBOutlet weak var tfSearchCity: UITextField!
	
	var place: Place!
	var placeDelegate: PlaceFinderDelegate!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_ :)))
		gesture.minimumPressDuration = 2.0
		//gestureRecognizer poderiam ser adicionado no storyboard
		mkMapKit.addGestureRecognizer(gesture)
	}
	
	@objc func getLocation(_ gesture: UIGestureRecognizer) {
		showLoading(true)
		let point = gesture.location(in: mkMapKit)
		let coordinate = mkMapKit.convert(point, toCoordinateFrom: mkMapKit)
		let geocoder = CLGeocoder()
		let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		
		geocoder.reverseGeocodeLocation(location) {[self] (placeMarks,error)in
			showLoading(false)
			if let placeMark = placeMarks?.first  {
				
				let addressFormated = Place.formaterAdress(placeMark)
				let region = showRegion(placeMark: placeMark, with: mkMapKit)
				place = Place(latitude: region.latitude , longitude: region.longitude, name: region.name, address: addressFormated)
				alertLocation(.name(region.name))
				return
			}
			alertLocation(.error("Error unknown please try again"))
		}
	}
	
	
	@IBAction func handleCloseModal(_ sender: UIButton) {
		dismiss(animated: true)
	}
	
	func showLoading(_ show: Bool) {
		vwLoading.isHidden = !show
		if show {
			actLoading.startAnimating()
		}else {
			actLoading.stopAnimating()
		}
	}
	
	
	@IBAction func findCity(_ sender: UIButton) {
		showLoading(true)
		tfSearchCity.resignFirstResponder()
		let geocoder = CLGeocoder()
		
		if let address = tfSearchCity.text {
			geocoder.geocodeAddressString(address) { [self](placeMarks,error) in
				showLoading(false)
				if let placeMark = placeMarks?.first {
					let addressFormated = Place.formaterAdress(placeMark)
					let region = showRegion(placeMark: placeMark, with: mkMapKit)
					place = Place(latitude: region.latitude , longitude: region.longitude, name: region.name, address: addressFormated)
					alertLocation(.name(region.name))
					return
				}
				alertLocation(.error("Error unknown please try again"))
			}
		}
	}
	
	func alertLocation(_ type:PlaceAlert)  {
		let title: String
		let message: String
		let hasConfirm: Bool
		
		switch type {
		case .name(let name):
			title = "Found city"
			message = "You would like add \(name)"
			hasConfirm = true
			
		case .error(let error):
			title = "Error"
			message = error
			hasConfirm = false
			
		}
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancel)
		
		if hasConfirm {
			let confirm = UIAlertAction(title: "Confirm", style: .default) { [self](action) in
				placeDelegate.getPlace(place)
				dismiss(animated: true)
			}
			alert.addAction(confirm)
		}
		self.present(alert, animated: true, completion: nil)
	}
	
	func	showRegion(placeMark: CLPlacemark,with mpView: MKMapView) -> (latitude: CLLocationDegrees,longitude: CLLocationDegrees,name: String)  {
		
		if 	let coordiante2D = placeMark.location?.coordinate,let name = placeMark.name{
			
			//quanto maior o latitudinalMeters,longitudinalMeters maior
			//mapa fica para cliente
			//mostrar a regiao no mapa
			let region = MKCoordinateRegion(center: coordiante2D, latitudinalMeters: 2500, longitudinalMeters: 2500)
			mpView.setRegion(region, animated: true)
			let latitude = mpView.region.center.latitude
			let longitude = mpView.region.center.longitude
			return (latitude,longitude,name)
		}
		return (0.0,0.0,"Unknown")
	}
	
	
}
