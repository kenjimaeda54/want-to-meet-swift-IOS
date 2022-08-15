//
//  PlaceTableViewCell.swift
//  Want to meet
//
//  Created by kenjimaeda on 09/08/22.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
	
	@IBOutlet weak var labTitlePlace: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func formatCell(title: String) {
		labTitlePlace.text = title
	}
	
	
}
