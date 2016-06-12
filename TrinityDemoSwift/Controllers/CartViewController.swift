//
//  SecondViewController.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
	
	var bookTableVC: BookTableViewController!
	
	// MARK: VC lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.updateUI()
	}
	
	// MARK: UI
	
	func setupUI() {
		
		self.bookTableVC = self.childViewControllers.first as? BookTableViewController
		self.bookTableVC.onDatabase = true
		self.bookTableVC.loadNextDataPageOnCompletion = nil
		
	}
	
	func updateUI() {
		
		// Get data from DB
		let data = Book.MR_findAll()
		
		bookTableVC.updateWithData(data as? [Book] ?? [Book](), pagination: nil, fromScratch: true)
		
	}

}
