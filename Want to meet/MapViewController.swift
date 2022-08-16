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
	@IBOutlet weak var loading: UIActivityIndicatorView!
	
	var places: [Place]!
	var annotationPoi: [MKAnnotation] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//para customizar os pin
		mapView.delegate = self
		searchBar.delegate = self
		
		//mudar cor do background color do textfiled do search bar
		searchBar.searchTextField.backgroundColor = .white
		
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
		let annotation = PlaceAnnotation(coordinate: place.coordinates, type: .place)
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
	
	
	
	@IBAction func showSearchBar(_ sender: UIBarButtonItem) {
		searchBar.resignFirstResponder()
		searchBar.isHidden = !searchBar.isHidden //forma de fazer um toogle
	}
	
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		//isso vai evitar sobescrever os pin de rota
		if !(annotation is PlaceAnnotation) {
			return nil
		}
		let type = (annotation as! PlaceAnnotation).type
		let identifier = "\(type)"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
		//para reaproveitar as annotation
		if annotationView == nil {
			annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
		}
		annotationView?.annotation = annotation
		annotationView?.canShowCallout = true
		annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
		annotationView?.glyphImage =  type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
		annotationView?.displayPriority = type == .place ? .required : .defaultHigh
		
		return annotationView
		
	}
	
}


//MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		loading.startAnimating()
		searchBar.resignFirstResponder()
		searchBar.isHidden = true
		//aqui preparo para realizar a request
		let request = MKLocalSearch.Request()
		//e para transformar em linguagem natural
		//se a pessoa pesquisar por cafe ira trazer as cafeterias
		//se a pessoa pesquisar por hotel ira trazer hoteis
		request.naturalLanguageQuery = searchBar.text
		request.region = mapView.region
		//aqui faco a busca de acordo como preparei
		let localSearch = MKLocalSearch(request: request)
		localSearch.start {[self] (response,error ) in
			loading.startAnimating()
			if let response = response {
				//antes de criar as anotation preciso cancelar todas que ja possuem
				mapView.removeAnnotations(annotationPoi)
				annotationPoi.removeAll()
				response.mapItems.forEach { (it) in
					let annotation = PlaceAnnotation(coordinate: it.placemark.coordinate, type: .poi)
					annotation.title = it.name
					annotation.subtitle = it.phoneNumber
					annotation.address = Place.formaterAdress(it.placemark)
					annotationPoi.append(annotation)
				}
				mapView.addAnnotations(annotationPoi)
				mapView.showAnnotations(annotationPoi, animated: true)
				loading.stopAnimating()
			}
			if error != nil {
				self.loading.stopAnimating()
				let alert = UIAlertController(title: "Error", message: "Something don't work please try again", preferredStyle: .alert)
				let cancel = UIAlertAction(title: "Cancel", style: .cancel)
				alert.addAction(cancel)
				self.present(alert, animated: true)
				print(error?.localizedDescription)
			}
		}
		
		
	}
	
}
