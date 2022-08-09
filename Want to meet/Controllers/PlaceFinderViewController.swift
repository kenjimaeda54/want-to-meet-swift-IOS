//
//  PlaceFinderViewController.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {
	
	@IBOutlet weak var actLoading: UIActivityIndicatorView!
	@IBOutlet weak var vwLoading: UIView!
	@IBOutlet weak var mkMapKit: MKMapView!
	@IBOutlet weak var btnSearch: UIButton!
	@IBOutlet weak var tfSearchCity: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Want to meet"
		
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
		tfSearchCity.resignFirstResponder()
		showLoading(true)
		if	let address = tfSearchCity.text{
			let geocoder = CLGeocoder()
			//geocoder adressString
			geocoder.geocodeAddressString(address) { (placeMark,error) in
				self.showLoading(false)
				if let place = placeMark?.first{
					let adress =  Place.formaterAdress(place)
					print(adress)
				}
			}
		}
	}
	
}
