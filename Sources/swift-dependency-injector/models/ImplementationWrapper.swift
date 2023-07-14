//
//  ImplementationWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// To wrap a generic implementation value sended by a publisher.
struct ImplementationWrapper {
    
    /// To store a specific subscriber id or nil in case this can be used for all subscribers.
    let subscriberId: String?
    
    /// To store the published value (implementation as generic object).
    let value: AnyObject
}
