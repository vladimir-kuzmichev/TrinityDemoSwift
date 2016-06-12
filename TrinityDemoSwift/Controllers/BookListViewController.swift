//
//  FirstViewController.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import UIKit

private let kBooksPaginationLimit = 10

class BookListViewController: UIViewController {
	
	var bookTableVC: BookTableViewController!
	let booksPagination = BooksPagination()
	
	var searchTextValidated = ""
	
	// MARK: IB
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	// MARK: VC lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: UI
	
	func setupUI() {
		
		self.bookTableVC = self.childViewControllers.first as? BookTableViewController
		self.bookTableVC.onDatabase = false
		self.bookTableVC.loadNextDataPageOnCompletion = { (completion: (() -> Void)?) in
			self.loadBooksOnCompletion(completion)
		}
		
	}
	
	// MARK: Pagination
	
	func resetPagination() {
		
		self.booksPagination.offset = 0
		self.booksPagination.limit = kBooksPaginationLimit
		self.booksPagination.totalCount = 0
		self.booksPagination.canLoadPage = false
		
	}
	
	func updatePagination() {
		
		self.booksPagination.offset += self.booksPagination.limit
		self.booksPagination.canLoadPage = (self.booksPagination.totalCount > self.booksPagination.offset)
		
		print("Pagination: Offset \(self.booksPagination.offset), Count \(self.booksPagination.totalCount), Page available: \(self.booksPagination.canLoadPage)")
		
	}
	
	// MARK: Utils
	
	func searchBooksWithText(text: String) {
		
		// Reset pagination info
		self.resetPagination()
		
		// Start search when we have at least 2 typed letters
		self.searchTextValidated = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		if self.searchTextValidated.characters.count < 3 {
			return
		}
		
		self.loadBooksOnCompletion(nil)
		
	}
	
	func loadBooksOnCompletion(completion: (() -> Void)?) {
		
		BooksManager.shared.searchBooks(withQuery: self.searchTextValidated, pagination: booksPagination) { (data: NSArray?, _) in
			if let dataCount = data?.count {
				if dataCount > 0 {
					self.updatePagination()
					self.bookTableVC.updateWithData(data as! [Book], pagination: self.booksPagination, fromScratch: (self.booksPagination.offset <= self.booksPagination.limit))
				}
			}
			if completion != nil {
				completion!()
			}
		}
		
	}
	
	// MARK: UISearchBarDelegate
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		self.searchBooksWithText(searchText)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		self.searchBooksWithText(searchBar.text!)
		searchBar.resignFirstResponder()
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
		searchBar.setShowsCancelButton(true, animated: true)
		return true
	}
	
	func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
		searchBar.setShowsCancelButton(false, animated: true)
		return true
	}
	
}
