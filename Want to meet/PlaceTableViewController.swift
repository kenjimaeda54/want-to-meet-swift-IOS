//
//  PlaceTableViewController.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import UIKit

class PlaceTableViewController: UITableViewController {
	
	var ud = UserDefaults.standard
	var places: [Place] = []
	var labelWithoutPlace: UILabel?

	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Want to meet"
		loadPlaces()
		labelWithoutPlace = UILabel()
		labelWithoutPlace?.text = "Press plus for add places you would like to visited"
		labelWithoutPlace?.numberOfLines = 0
		labelWithoutPlace?.textColor = .black
		labelWithoutPlace?.textAlignment = .center
		labelWithoutPlace?.font.withSize(21.3)
		
	}
	

	
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
	
	
	func loadPlaces () {
		do {
			if let data = ud.data(forKey: "places") {
				places = try JSONDecoder().decode([Place].self, from: data)
				tableView.reloadData()
			}
		}catch {
			print(error)
		}
	}
	
	func savePlaces() {
		do {
			let data = try JSONEncoder().encode(places)
			ud.set(data, forKey: "places")
		}catch{
			print(error)
		}
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if places.count > 0 {
			let buttonPlace = UIBarButtonItem(title: "All places", style: .plain, target: self, action: #selector(showAllPlaces) )
			navigationItem.leftBarButtonItem = buttonPlace
			tableView.backgroundView = nil
		}else {
			navigationItem.leftBarButtonItem = nil
			tableView.backgroundView = labelWithoutPlace
		}
		
		
		return places.count
	}
	
	@objc	func showAllPlaces() {
		performSegue(withIdentifier: "foundPlaceSegue", sender: nil)
	}
	
	
	//metodo para deletar uma linha do tableview
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			places.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
			savePlaces()
		}
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceTableViewCell
		cell.formatCell(title: places[indexPath.row].name)
		return cell
	}
	
	//quando uma linha e selecionado na table view
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let place = places[indexPath.row]
		performSegue(withIdentifier: "foundPlaceSegue", sender: place)
	}
	
	
}

extension PlaceTableViewController:PlaceFinderDelegate {
	func getPlace(_ place: Place) {
		if !places.contains(place) {
			places.append(place)
			//reload data e importante para carregar novamente a table
			//assim o metodo viewdidLoad e chamado novvamente
			savePlaces()
			tableView.reloadData()
		}
	}
}




