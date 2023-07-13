//
//  AbstractionMapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

struct AbstractionMapper {
    static func map<Abstraction>(_ implementation: AnyObject?) -> Abstraction? {
        let abstractionName = String(describing: Abstraction.self)
        
        guard let implementation = implementation as? Abstraction else {
            Logger.log(InjectionErrors.implementationsCouldNotBeCasted(abstractionName: abstractionName))
            return nil
        }
        
        return implementation
    }
}
