//
//  GoogleBooksResponseSerializer.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 10.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import Foundation
import AFNetworking

class GoogleBooksResponseSerializer: AFJSONResponseSerializer {
	
	private var httpStatusCode_: Int?
	private var error_: NSError?
	
	var httpStatusCode: Int? {
		return httpStatusCode_
	}
	
	var error: NSError? {
		return error_
	}
	
	override func responseObjectForResponse(response: NSURLResponse?, data: NSData?, error: NSErrorPointer) -> AnyObject? {
		
		let responseString = String.init(data: data ?? NSData(), encoding: self.stringEncoding)
		
		let httpResponse = response as? NSHTTPURLResponse
		httpStatusCode_ = httpResponse?.statusCode
		
		//print(String(format: "JSON response for API request '%@' with HTTP status code '%ld':\n%@", response?.URL?.lastPathComponent ?? "", self.httpStatusCode ?? 0, responseString ?? ""))
		
		print("JSON response for API request '\(response?.URL?.lastPathComponent)' with HTTP status code '\(self.httpStatusCode)':\n\(responseString)")
		
		let json = super.responseObjectForResponse(response, data: data, error: error) as? NSDictionary
		return self.parseResponse(fromJson: json)
		
	}
	
	// MARK: Utils
	
	private func parseResponse(fromJson json: NSDictionary?) -> AnyObject? {
		error_ = self.retrieveError(fromResponse: json)
		return json
	}
	
	private func retrieveError(fromResponse response: NSDictionary?) -> NSError? {
		var error: NSError?
		
		if let resp = response {
			let errorInfo = resp[kAPIKeyError] as? NSDictionary
			if errorInfo != nil {
				error = NSError(domain: kErrorDomain, code: ApplicationError.APIError.rawValue, userInfo: [NSLocalizedDescriptionKey : errorInfo![kAPIKeyErrorMessage] ?? ""])
			}
		}
		
		return error
	}
	
}