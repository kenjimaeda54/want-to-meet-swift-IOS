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
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_ :)))
		gesture.minimumPressDuration = 2.0
		mkMapKit.addGestureRecognizer(gesture)
	}
	
	@objc	func getLocation(_ gesture:UIGestureRecognizer) {
		//so apos os 2 segundos esse metodo sera efetuado
		if gesture.state == .began {
			showLoading(true)
			let location = Place.getLocationByTap(gesture: gesture, where: mkMapKit)
			let geocoder = CLGeocoder()
			geocoder.reverseGeocodeLocation(location) { (placeMarks,error) in
				self.showLoading(false)
				if error == nil {
					if let region =  Place.getRegion(placeMarks?.first).regionCoordinate, let name = Place.getRegion(placeMarks?.first).name {
						Place.showMessage(with: .name(name), view: self)
						self.mkMapKit.setRegion(region, animated: true)
						return
					}
					
				}
				Place.showMessage(with: .error("Something don't worked try again"), view: self)
			}
			
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
		tfSearchCity.resignFirstResponder()
		showLoading(true)
		if	let address = tfSearchCity.text{
			let geocoder = CLGeocoder()
			//geocoder adressString
			geocoder.geocodeAddressString(address) { (placeMarks,error) in
				self.showLoading(false)
				if error == nil {
					if let region =  Place.getRegion(placeMarks?.first).regionCoordinate, let name = Place.getRegion(placeMarks?.first).name {
						Place.showMessage(with: .name(name), view: self)
						self.mkMapKit.setRegion(region, animated: true)
						return
					}
					
				}
				Place.showMessage(with: .error("Something don't worked try again"), view: self)
			}
		}
	}
}
