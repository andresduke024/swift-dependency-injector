//
//  StringUtils.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 12/01/26.
//

extension String {
    func removeSuffix(_ suffix: String) -> Self {
        guard hasSuffix(suffix) else { return self }
        
        return String(
            dropLast(suffix.count)
        )
    }
    
    func lowercasedFirst() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
