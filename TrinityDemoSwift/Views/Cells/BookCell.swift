//
//  BookCell.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import UIKit

class BookCell: UITableViewCell {

	@IBOutlet weak var thumbnailView: UIImageView!
	@IBOutlet weak var titleLbl: UILabel!
	@IBOutlet weak var authorsLbl: UILabel!
	@IBOutlet weak var cartBtn: UIButton!
	
	@IBAction func cartBtnPressed(sender: AnyObject) {
		if let btnPressed = self.cartBtnPressed {
			btnPressed(self)
		}
	}
	
	var cartBtnPressed: (BookCell -> Void)?
	
	// MARK: Init
	
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//	}
//	
//	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//		super.init(style: style, reuseIdentifier: reuseIdentifier)
//		self.setupUI()
//	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.setupUI()
	}
	
	// MARK: UI
	
	private func setupUI() {
		let viewLayer = self.cartBtn.layer
		viewLayer.cornerRadius = 3
		viewLayer.masksToBounds = true
	}
	
}
