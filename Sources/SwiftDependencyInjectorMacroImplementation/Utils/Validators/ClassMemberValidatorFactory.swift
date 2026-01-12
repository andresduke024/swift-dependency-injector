//
//  ClassMemberValidatorFactory.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

struct ClassMemberValidatorFactory {
    static func get(_ type: ClassMemberValidatorType) -> ClassMemberValidator {
        switch type {
        case .designedInitializer:
            return DesignedInitializerValidator()
        }
    }
}

enum ClassMemberValidatorType {
    case designedInitializer
}
