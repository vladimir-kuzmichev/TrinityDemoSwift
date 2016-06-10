//
//  GoogleBooksAPIClient.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 10.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import Foundation
import AFNetworking

let kAPIBaseURL = "https://www.googleapis.com/books/v1/"
private let KAPIKey = "AIzaSyDCj6okZId4lNidX2dFw566BAeEg_Bn5-Y"

public let kHTTPMethodGet = "GET"
public let kHTTPMethodPost = "POST"

public typealias APIRequestCompletion = (NSDictionary?, NSError?) -> Void

public class GoogleBooksAPIClient: AFHTTPSessionManager {
	
	// MARK: Singleton
	
	static let shared = GoogleBooksAPIClient()
	private init() {	// This prevents others from using the default '()' initializer for this class
		
		super.init(baseURL: NSURL(string: kAPIBaseURL), sessionConfiguration: nil)
		
		// Serializers
		self.requestSerializer = AFHTTPRequestSerializer()
		self.responseSerializer = GoogleBooksResponseSerializer()
		
		// Initial setup
		self.setup()
		
	}
	
	// MARK: Init
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// MARK: Setup
	
	private func setup() {
		self.reachabilityManager.setReachabilityStatusChangeBlock { (_) in
			print("Reachability status for 'www.googleapis.com': \(self.reachabilityManager.localizedNetworkReachabilityStatusString())\n")
		}
		self.reachabilityManager.startMonitoring()
	}
	
	// MARK: API
	
	public func makeRequest(requestPath: String, onCompletion completion: APIRequestCompletion?) {
		self.makeRequest(requestPath, parameters: nil, onCompletion: completion)
	}
	
	public func makeRequest(requestPath: String, parameters: NSDictionary?, onCompletion completion: APIRequestCompletion?) {
		self.makeRequest(requestPath, httpMethod: kHTTPMethodGet, parameters: parameters, onCompletion: completion)
	}
	
	public func makeRequest(requestPath: String, httpMethod: String, parameters: NSDictionary?, onCompletion completion: APIRequestCompletion?) {
		
		print("Attempt to perform API request '\(requestPath)'...")
		
		// Build request URL
		let requestUrl = self.baseURL?.URLByAppendingPathComponent(requestPath)
		guard let reqUrl = requestUrl else { assertionFailure("Invalid API base URL"); return }
		
		// Cancel all the same previous requests
		self.cancelRequestsByURL(reqUrl)
		
		// First check the internet connection
		if (!self.reachabilityManager.reachable)
		{
			let error = self.createConnectionError()
			print("Connection error: \(error)")
			
			// Post notification for subscribers
			NSNotificationCenter.defaultCenter().postNotificationName(kNotificationApplicationError, object: self, userInfo: ["error" : error])
			
			if completion != nil {
				completion!(nil, error)
			}
			
			return
		}
		
		// Modify request params (append the API key)
		let params = parameters ?? [:]
		params.setValue(KAPIKey, forKey: kAPIKeyKey)
		
		print("Request URL: \(reqUrl)")
		print("Request parameters: \(params)")
		
		// Construct URL Request
		var serializationError: NSError?
		let request = self.requestSerializer.requestWithMethod(httpMethod, URLString: reqUrl.absoluteString, parameters: params, error: NSErrorPointer.init(&serializationError))
		
		if (serializationError != nil)
		{
			print("Request serialization error: \(serializationError)")
			
			if completion != nil {
				completion!(nil, serializationError)
			}
			
			return
		}
		
		let dataTask = self.dataTaskWithRequest(request) { (response: NSURLResponse, responseObject: AnyObject?, error: NSError?) in
			
			let serializer = self.responseSerializer as! GoogleBooksResponseSerializer
			
			// Check for API request error
			if serializer.error != nil {
				print("Response error: \(serializer.error)")
				
				// Post notification for subscribers
				NSNotificationCenter.defaultCenter().postNotificationName(kNotificationApplicationError, object: self, userInfo: ["error" : serializer.error!])
				
				if completion != nil {
					completion!(nil, serializer.error)
				}
				
				return
			}
			
			// Check for server error
			if error != nil {
				print("Server error: \(error)")
				
				if error?.code != -999 {	// "Cancelled"
					NSNotificationCenter.defaultCenter().postNotificationName(kNotificationApplicationError, object: self, userInfo: ["error" : error!])
				}
				
				if completion != nil {
					completion!(nil, error)
				}
				
				return
			}
			
			if completion != nil {
				completion!(responseObject as? NSDictionary, nil)
			}
			
		}
		
		// Start the data task
		dataTask.resume()
		
	}
	
	// MARK: Utils
	
	private func cancelRequestsByURL(url: NSURL) {
		for item in self.tasks {
			let requestUrl = item.originalRequest?.URL
			if requestUrl?.path != nil && requestUrl?.path! == (url.path ?? "") {
				item.cancel()
			}
		}
	}
	
	private func createConnectionError() -> NSError {
		// Generate connection error
		return NSError(domain: kErrorDomain, code: ApplicationError.NoConnection.rawValue, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("There are problems with network connection. Please try again later", comment: "")])
	}
	
}
