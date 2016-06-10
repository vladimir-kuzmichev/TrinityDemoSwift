//
//  Errors.swift
//  TrinityDemoSwift
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//  Copyright © 2016 Vladimir Kuzmichev. All rights reserved.
//

import Foundation

let kErrorDomain = "com.trinity.TrinityDemo"
let kNotificationApplicationError = "com.trinity.TrinityDemo.NotificationApplicationError"

enum ApplicationError: Int {
	case NoConnection = 1
	case APIError
}
