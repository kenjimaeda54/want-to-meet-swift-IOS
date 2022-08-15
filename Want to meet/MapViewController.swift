//
//  FindViewController.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
	
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var labAddress: UILabel!
	@IBOutlet weak var vwInfo: UIView!
	@IBOutlet weak var labName: UILabel!
	
	var places: [Place]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//para customizar os pin
		mapView.delegate = self
		
		if places.count > 1 {
			title = "All places"
		}else {
			title = places[0].name
		}
		searchBar.isHidden = true
		vwInfo.isHidden = true
		
		
		places.forEach { (it) in
			addPin(it)
		}
		showPin()
	}
	
	//criando as anotacoes para pin
	//maneira padrao de criar um pin
	//	func addPin(_ place: Place)  {
	//		let anotation = MKPointAnnotation()
	//		anotation.title = place.name
	//		anotation.coordinate = place.coordinates
	//		mapView.addAnnotation(anotation)
	//	}
	
	//customizada
	func addPin(_ place:Place) {
		let annotation = PlaceAnnotation(coordinate: place.coordinates,type:  .place )
		annotation.title = place.name
		annotation.address = place.address
		mapView.addAnnotation(annotation)
	}
	
	
	//mostrando os pin
	func showPin() {
		mapView.showAnnotations(mapView.annotations, animated: true)
	}
	
	
	@IBAction func handleTraceRote(_ sender: UIButton) {
	}
	
	
}


extension MapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		//isso vai evitar sobescrever os pin de rota
		if !(annotation is PlaceAnnotation)  {
			return nil
		}
		
		let type =  (annotation as! PlaceAnnotation).type
		let identifier = "\(type)"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
		// aqui garonto que as annotation que aparece que de fato serao customizadas
		if annotationView == nil {
			annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			
		}
		annotationView?.annotation = annotation
		//habil para mostrar
		annotationView?.canShowCallout = true
		annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
		annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
		annotationView?.displayPriority = type == .place ? .required : .defaultLow
		return annotationView
		
	}
	
}
