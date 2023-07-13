//
//  PublishedValueWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// To wrap a generic value that can be sended in any publisher.
struct PublishedValueWrapper<Value> {
    
    /// This property could be used as an id of the published value or to identify an specific subscriber.
    let id: String?
    
    /// To store the published value.
    let value: Value?
}
