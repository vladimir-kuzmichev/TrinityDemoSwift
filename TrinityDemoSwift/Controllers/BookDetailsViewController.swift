//
//  BookDetailsViewController.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import UIKit
import SDWebImage

class BookDetailsViewController: UIViewController {

	var theBook: Book? {
		didSet {
			self.updateUI()
		}
	}
	
	// MARK: IB
	
	@IBOutlet weak var detailsView: UIScrollView!
	
	@IBOutlet weak var thumbnailView: UIImageView!
	@IBOutlet weak var titleLbl: UILabel!
	@IBOutlet weak var authorsLbl: UILabel!
	@IBOutlet weak var descriptionView: UITextView!
	
	// MARK: VC lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.updateUI()
	}
	
	// MARK: UI
	
	func setupUI() {
		
		
		
	}
	
	func updateUI() {
		
		guard self.isViewLoaded() else { return }
		
		self.thumbnailView.sd_setImageWithPreviousCachedImageWithURL(NSURL.init(string: self.theBook?.thumbnailUrl ?? ""), placeholderImage: nil, options: SDWebImageOptions.init(rawValue: 0), progress: nil, completed: nil)
		
		self.titleLbl.text = self.theBook?.title
		self.authorsLbl.text = self.theBook?.author
		self.descriptionView.text = self.theBook?.desc
		
	}
	
}
