//
//  FindViewController.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import UIKit
import MapKit

enum MapMessageAlert {
	case error
	case authorizationWarning
}

class MapViewController: UIViewController {
	
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var labAddress: UILabel!
	@IBOutlet weak var vwInfo: UIView!
	@IBOutlet weak var labName: UILabel!
	@IBOutlet weak var loading: UIActivityIndicatorView!
	
	var places: [Place]!
	var annotationPoi: [MKAnnotation] = []
	var locationManager = CLLocationManager()
	var buttonLocation = MKUserTrackingButton()
	var selectedAnotation: PlaceAnnotation?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//para customizar os pin
		mapView.delegate = self
		searchBar.delegate = self
		locationManager.delegate = self
		
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
		requestLocationUser()
		buttonLocationUser()
		
	}
	
	func buttonLocationUser() {
		buttonLocation = MKUserTrackingButton(mapView: mapView)
		buttonLocation.backgroundColor = .white
		buttonLocation.frame.origin.x = 10
		buttonLocation.frame.origin.y = 10
		buttonLocation.layer.cornerRadius = 5
		buttonLocation.layer.borderWidth = 1
		buttonLocation.layer.borderColor = UIColor(named: "main")?.cgColor
	}
	
	//aqui estou verificando os recursos de localizacao
	func requestLocationUser() {
		//lembra que precisa em Info.plist colocar uma mensagem que ira
		//usar servicos de localizacao
		if CLLocationManager.locationServicesEnabled() {
			switch locationManager.authorizationStatus {
			case .authorizedAlways,.authorizedWhenInUse:
				mapView.addSubview(buttonLocation)
			case .denied:
				alertLocation(.authorizationWarning)
			case .notDetermined:
				locationManager.requestWhenInUseAuthorization()
			default:
				break
			}
			
		}
		
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
		if  locationManager.authorizationStatus != .authorizedWhenInUse {
			alertLocation(.authorizationWarning)
			return
		}
		//destionation pegando a localizacao do ponto de interesse
		if let destinationSelected = selectedAnotation?.coordinate,
			 // em locationManager estou pegando a localizacao do usuario
			 let sourceSelected = locationManager.location?.coordinate {
			
			let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationSelected))
			let source = MKMapItem(placemark: MKPlacemark(coordinate: sourceSelected))
			
			let request = MKDirections.Request()
			request.destination = destination
			request.source = source
			let directions = MKDirections(request: request)
			directions.calculate { [self](response, error) in
				if error == nil {
					if let  response = response {
						//necessario para limpar qualquer overlay
						mapView.removeOverlays(mapView.overlays)
						
						let route = response.routes.first!
						//metodos disponiveis com route
						print("name:\(route.name)")
						print("distancia:\(route.distance)")
						print("name:\(route.expectedTravelTime)")
						
						//adicionado overlay
						//abouveRoads pinta em cima da rua
						mapView.addOverlay(route.polyline, level: .aboveRoads)
						
						//aqui estou removendo todas minhas place anotation
						//assim so tenho a localizacao do usuario
						var annotations = mapView.annotations.filter({!($0 is PlaceAnnotation)})
						//dessa forma aqui so vou ter localizacao do usuario
						//mais a annotation selecionada como rota 
						annotations.append(selectedAnotation!)
						mapView.showAnnotations(annotations, animated: true)
						
					}
					
				}else {
					alertLocation(.error)
					print(error)
				}
			}
			
		}
		
	}
	
	
	
	@IBAction func showSearchBar(_ sender: UIBarButtonItem) {
		searchBar.resignFirstResponder()
		searchBar.isHidden = !searchBar.isHidden //forma de fazer um toogle
	}
	
	
	func alertLocation(_ type:MapMessageAlert)  {
		let title = type  == .authorizationWarning ? "Warning" : "Error"
		let message = type == .authorizationWarning ? "To use this feature I need access to the location" : "Could not trace the route"
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancel)
		
		if type == .authorizationWarning {
			let confirm = UIAlertAction(title: "Go settings", style: .default) {(action) in
				//pego o caminho do setings
				if	let appSetings = URL(string: UIApplicationOpenNotificationSettingsURLString){
					
					//pego meu aplicativo com shared e com metodo open
					//envio para setings
					UIApplication.shared.open(appSetings,options: [:],completionHandler: nil)
				}
				
			}
			alert.addAction(confirm)
		}
		
		self.present(alert, animated: true, completion: nil)
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
	
	//quando tocar em uma annotation
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		//3d mapa
		let camera = MKMapCamera()
		//angulo da camera
		camera.centerCoordinate = mapView.centerCoordinate
		camera.pitch = 60
		camera.altitude = 500
		mapView.setCamera(camera, animated: true)
		
		selectedAnotation = view.annotation as! PlaceAnnotation
		labName.text = selectedAnotation?.title
		labAddress.text = selectedAnotation?.address
		vwInfo.isHidden = false
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		//criando overlay
		if overlay is MKPolyline {
			let renderer = MKPolylineRenderer(overlay: overlay)
			renderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
			renderer.lineWidth = 5.0
			return renderer
		}
		return MKOverlayRenderer(overlay: overlay)
	}
	
}

// MARK: - CLLocationManagerDelegate
extension MapViewController:CLLocationManagerDelegate {
	//aqui literalmente vou saber quando autorizacao foi alterada
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .authorizedWhenInUse,.authorizedAlways:
			mapView.showsUserLocation = true
			mapView.addSubview(buttonLocation)
			locationManager.startUpdatingLocation()
		default:
			break
			
		}
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		//vai printar a ultima localizacao do app
		print(locations.last)
	}
	
	
}
