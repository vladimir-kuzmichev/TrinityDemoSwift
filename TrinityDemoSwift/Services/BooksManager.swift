//
//  BooksManager.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 10.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import Foundation

typealias ItemsListCompletion = (NSArray?, NSError?) -> Void
typealias BookDetailsCompletion = (Book?, NSError?) -> Void

class BooksPagination {
	var offset = 0
	var limit = 0
	var totalCount = 0
	var canLoadPage = false
}

class BooksManager {
	
	private let temporaryContext = NSManagedObjectContext.MR_contextWithParent(NSManagedObjectContext.MR_defaultContext())
	
	// MARK: Singleton
	
	static let shared = BooksManager()
	private init() {}	// This prevents others from using the default '()' initializer for this class
	
	// MARK: API
	
	func searchBooks(withQuery query: String?, pagination: BooksPagination, onCompletion completion: ItemsListCompletion?) {
		
		// Get data from service
		let params = [kAPIKeyProjection : kAPIKeyProjectionLite, kAPIKeyQuery : query ?? "", kAPIKeyPaginationPage : pagination.offset, kAPIKeyPaginationSize : pagination.limit]
		
		GoogleBooksAPIClient.shared.makeRequest(kAPIRequestGetVolumes, parameters: params) { (data: NSDictionary?, error: NSError?) in
			
			var books = [Book]()
			
			if let result = data {
				if let dataItems = result[kAPIKeyItems] as? [NSDictionary] {
					for item in dataItems {
						let theBook = self.parseBookData(item)
						if theBook != nil {
							books.append(theBook!)
						}
					}
				}
				pagination.totalCount = result[kAPIKeyItemsCount] as? Int ?? 0
			}
			
			if completion != nil {
				completion!(books, error)
			}
			
		}
		
	}
	
	func saveBookToDatabase(book: Book) {
		
		// Create and save the model object
		let theBook = Book.MR_findFirstOrCreateByAttribute("itemId", withValue: book.itemId!)
		
		theBook.itemId = book.itemId
		theBook.title = book.title
		theBook.author = book.author
		theBook.desc = book.desc
		theBook.thumbnailUrl = book.thumbnailUrl
		
		NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
		
	}
	
	// MARK: Parsing
	
	private func parseBookData(data: NSDictionary?) -> Book? {
		
		guard let bookData = data else { return nil }
		
		let item = Book.MR_createEntityInContext(self.temporaryContext)
		item?.itemId = bookData[kAPIKeyVolumeId] as? String
		item?.title = bookData[kAPIKeyVolumeInfo]?[kAPIKeyVolumeTitle] as? String
		
		let authors = bookData[kAPIKeyVolumeInfo]?[kAPIKeyVolumeAuthors] as? [String]
		item?.author = authors?.joinWithSeparator(", ")
		
		item?.desc = bookData[kAPIKeyVolumeInfo]?[kAPIKeyVolumeDescription] as? String
		item?.thumbnailUrl = (bookData[kAPIKeyVolumeInfo]?[kAPIKeyVolumeImages] as? NSDictionary)?[kAPIKeyVolumeImageThumbnail] as? String
		
		return item
	}
	
}
