//
//  BookTableViewController.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import UIKit
import SDWebImage

class BookTableViewController: UIViewController {
	
	var onDatabase = false
	var loadNextDataPageOnCompletion: ((() -> Void)? -> Void)?
	
	var bookList = [Book]()
	var booksPagination: BooksPagination?
	
	var paginationBtn: UIButton!
	
	// MARK: IB
	
	@IBOutlet weak var bookTable: UITableView!
	
	
	// MARK: VC lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
	}
	
	// MARK: UI
	
	func setupUI() {
		
		// Pagination button
		//
		paginationBtn = UIButton(type: UIButtonType.System)
		paginationBtn.frame = CGRectMake(0, 0, 120, 30)
		
		paginationBtn.backgroundColor = UIColor.orangeColor()
		paginationBtn.titleLabel?.font = UIFont.boldSystemFontOfSize(10)
		
		paginationBtn.tintColor = UIColor.whiteColor()
		
		let viewLayer = paginationBtn.layer
		viewLayer.cornerRadius = 3
		viewLayer.masksToBounds = true
		
		paginationBtn.setTitle(NSLocalizedString("Show more", comment: "").uppercaseString, forState: UIControlState.Normal)
		paginationBtn.addTarget(self, action: #selector(self.paginationBtnPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
		//
		
	}
	
	func updatePaginationUI() {
		
		if let pagination = self.booksPagination {
			if pagination.canLoadPage {
				var view = self.bookTable.tableFooterView
				if view == nil {
					view = UIView(frame: self.bookTable.bounds)
					view?.backgroundColor = UIColor.clearColor()
					
					var frame = view?.frame
					frame?.size.height = 55
					view?.frame = frame!
					
					paginationBtn.center = CGPointMake(CGRectGetWidth(frame!) / 2, CGRectGetHeight(frame!) / 2)
					
					view?.addSubview(paginationBtn)
					self.bookTable.tableFooterView = view
				}
			}
			else {
				UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
					self.bookTable.tableFooterView = nil
					}, completion: nil)
			}
		}
		
	}
	
	// MARK: API
	
	func updateWithData(data: [Book], pagination: BooksPagination?, fromScratch: Bool) {
		
		// Clear the data source
		if (fromScratch) {
			self.bookList.removeAll()
		}
		
		bookList.appendContentsOf(data)
		booksPagination = pagination
		
		self.bookTable.reloadData()
		self.updatePaginationUI()
		
	}
	
	// MARK: UITableView
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.bookList.count
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cellId = self.onDatabase ? "BookDBCell" : "BookCell"
		let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! BookCell
		
		let theBook = self.bookList[indexPath.row]
		
		// Setting up the cell
		cell.titleLbl.text = theBook.title
		cell.authorsLbl.text = theBook.author
		
		cell.thumbnailView.sd_setImageWithPreviousCachedImageWithURL(NSURL.init(string: theBook.thumbnailUrl ?? ""), placeholderImage: nil, options: SDWebImageOptions.AvoidAutoSetImage, progress: nil) { (image: UIImage!, _, cacheType: SDImageCacheType, _) in
			
			if image == nil { return }
			
			// Animate image displaying if it was pulled from the web
			if cacheType == SDImageCacheType.None {
				UIView.transitionWithView(cell.thumbnailView, duration: 0.25, options: UIViewAnimationOptions(rawValue: 0), animations: {
					cell.thumbnailView.image = image
					}, completion: nil)
			}
			else {
				cell.thumbnailView.image = image
			}
			
		}
		
		if !self.onDatabase {
			// Disable Cart button if the book is in DB, Enable otherwise
			let item = Book.MR_findFirstByAttribute("itemId", withValue: theBook.itemId!)
			cell.cartBtn?.enabled = (item != nil ? false : true)
		}
		
		cell.cartBtnPressed = { (c: BookCell) in
			
			let path = tableView.indexPathForCell(c)
			let item = self.bookList[path!.row]
			
			// Add item to the cart
			BooksManager.shared.saveBookToDatabase(item)
			
			// Refresh the cell
			tableView.reloadRowsAtIndexPaths([path!], withRowAnimation: UITableViewRowAnimation.Automatic)
			
		}
		
		return cell
		
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let theBook = self.bookList[indexPath.row]
		self.performSegueWithIdentifier("showDetails", sender: theBook)
		
	}
	
	// MARK: UIStoryboard
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "showDetails" {
			let vc = segue.destinationViewController as! BookDetailsViewController
			vc.theBook = sender as? Book
		}
		
	}
	
	// MARK: Unwind segue support
	
	@IBAction func unwindToBookTableVC(segue: UIStoryboardSegue) {
		
	}
	
	// MARK: Actions
	
	func paginationBtnPressed(sender: AnyObject?) {
		
		if self.loadNextDataPageOnCompletion != nil {
			self.paginationBtn.enabled = false
			self.loadNextDataPageOnCompletion!() {
				self.paginationBtn.enabled = true
			}
		}
		
	}
	
}
