//
//  ApplicationHelper.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import Foundation
import UIKit

class ApplicationHelper {
	
	static let shared = ApplicationHelper()
	private init() {} // This prevents others from using the default '()' initializer for this class
	
	class func topmostViewController() -> UIViewController? {
		
		var window = UIApplication.sharedApplication().keyWindow
		if window == nil {
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
			window = appDelegate.window
		}
		
		var vc = window?.rootViewController
		
		// Iterate over presented view controllers
		while vc?.presentedViewController != nil {
			vc = vc?.presentedViewController!
		}
		
		guard var viewController = vc else { return nil }
		
		if viewController.isKindOfClass(UINavigationController) {
			viewController = (viewController as! UINavigationController).visibleViewController!
		}
		
		if viewController.isKindOfClass(UITabBarController) {
			viewController = (viewController as! UITabBarController).selectedViewController!
		}
		
		return viewController
		
	}
	
	class func showAlertWith(error: NSError, onController controller: UIViewController) {
		
		let ac = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
		let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default) { (_) in
			ac.dismissViewControllerAnimated(true, completion: nil)
		}
		
		ac.addAction(action)
		controller.presentViewController(ac, animated: true, completion: nil)
		
	}
	
}