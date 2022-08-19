#  Want to meet 
Aplicativo com localizacao do usuario,tracagem de rotas  e pontos de interesse


## Motivacao
Continuar aprendnedo desenvolvimento em swift para IOS


## Feature
- Aprendi novos métodos para trabalhar com UITableView
- Aprendi o método para deletar uma linha e tomar uma ação caso a linha seja selecionado
- Neste caso quando a linha era selecionado enviava a localização selecionada
- Abaixo tem um exemplo como implementar delegate em um modal e conseguir utilizar ele
- Neste caso utilizei o próprio método prepare, que e disponibilizado quando criamos segue
- Outro recurso interessante foi usar o sender do prepare para saber se foram places enviado ou place
- No sender temos acesso os dados enviados pelo método performSegue


```swfit
	
//quando uma linha e selecionado na table view
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let place = places[indexPath.row]
		performSegue(withIdentifier: "foundPlaceSegue", sender: place)
}

//metodo para deletar uma linha do tableview
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
if editingStyle == .delete {
			places.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
			savePlaces()
	}
}

//===============

//precisa chamar segue , para implentar o delegate
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
if segue.identifier == "modalSegue" {
	 let vc = segue.destination as! PlaceFinderViewController
	 vc.placeDelegate = self
}else {
	 let vc = segue.destination as! MapViewController
	 //sender e o valorque estou enviando pelo prepareSegue
	 //neste caso e place ou places
	 switch sender {
				//estou envinado um place ou vario place
				//caso conseguir converter place por Place entrara no primeiro place
	 case let place as Place:
				vc.places = [place]
	 default:
				vc.places = places
			}
		}
}

```


##
- Aprendi uma maneira de caputrar o click na view de um map view e transformar em localização
- Preparei o gestureReconizer e adicionei na instância do mapView
- Com gesture.location tenho acesso ao x e y do ponto tocado na tela e com o método convert do mapView consigo transformar em uma coordinate de fato
- Apos com o coordinate nas mãos, instanciei o location passando as coordenadas




```swift


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

```
##
- Aprendi mostrar  no mapa a região selecionada
- Método e o MKCoordinateRegion
- Quanto maior o latitudinalMeters e longitudinalMeters, maior e a região printada
- Este metodo e para de fato visualimos nossas annotations



```swift
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

```





##
- Aprendi a criar as annotations padrões  e também customizadas
- Annotation são os pins que ficam no mapa
- Tracegem de rota e considerada um annotation
- Para criar as annotation customizadas criei uma calsse place e por herança herdei todos métodos do MKAnnotation, assim tenho acesso a todos métodos e métodos que criei



``` swift



 //padrao
	    	func addPin(_ place: Place)  {
	  		let anotation = MKPointAnnotation()
	  		anotation.title = place.name
	  		anotation.coordinate = place.coordinates
	  		mapView.addAnnotation(anotation)
	 	}
	
  
  //===================
  
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

```
##
- Para mostrar as annotation a partir de um texto
- Neste caso usei searchBar, implementei seu delegate e o método searchBarSearchButtonClicked
- Este método e  acionado sempre que clicarem no botão de pesquisar




```swift

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

```

## 
- Implementei um metodo para manipular a camera da mapView,assim consigo trabalhar com 3d 



```swift

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




```

##
- Aprendi usar botao nativo de localizacao presente no celular
- Toda vez que a pessoa clicar neste botao sera enviado para sua localizacao atual



```swift

	var buttonLocation = MKUserTrackingButton()
  
  	func buttonLocationUser() {
		buttonLocation = MKUserTrackingButton(mapView: mapView)
		buttonLocation.backgroundColor = .white
		buttonLocation.frame.origin.x = 10
		buttonLocation.frame.origin.y = 10
		buttonLocation.layer.cornerRadius = 5
		buttonLocation.layer.borderWidth = 1
		buttonLocation.layer.borderColor = UIColor(named: "main")?.cgColor
	}

```


##
- Para garantir a localização do usuário precisamos criar um método para verificar se esta permitida usar localização
- E implementar o delgate  locationManager, neste método que a mágica acontece


```swift

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



//=============

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






```







