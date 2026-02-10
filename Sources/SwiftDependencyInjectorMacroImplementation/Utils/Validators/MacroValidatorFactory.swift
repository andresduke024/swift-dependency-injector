//
//  ClassMemberValidatorFactory.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

/// A factory responsible for creating concrete macro validators based on a requested type.
///
/// Macro validators encapsulate validation logic used during macro expansion,
/// such as ensuring that a declaration has a designated initializer, that a
/// macro is applied to a supported object type, or that required arguments are present.
///
/// Usage:
/// - Choose a validation category via `MacroValidatorType`.
/// - Call `MacroValidatorFactory.get(_:)` to obtain a `MacroValidator` that performs that validation.
///
/// Example:
/// ```swift
/// let validator = MacroValidatorFactory.get(.objectType)
/// try validator.validate(context)
/// ```
///
/// Notes:
/// - This factory centralizes construction to keep call sites decoupled from
///   specific validator implementations.
/// - Add new cases to `MacroValidatorType` and extend the `switch` in `get(_:)`
///   when introducing additional validation rules.
struct MacroValidatorFactory {
    static func get(_ type: MacroValidatorType) -> MacroValidator {
        switch type {
        case .designedInitializer:
            DesignedInitializerValidator()
        case .objectType:
            ObjectTypeValidator()
        case .argumentsExistence:
            ArgumentsExistenceValidator()
        }
    }
}

/// Represents the categories of validation that can be performed by macro validators.
///
/// Use these cases to request a specific validator from `MacroValidatorFactory`,
/// which returns a `MacroValidator` configured to enforce the corresponding rule.
/// Each case targets a distinct aspect of macro usage and syntax correctness:
///
/// - `designedInitializer`: Ensures that the target type contains a designated initializer
///   matching the macro’s requirements. This is useful when macro expansion relies on
///   the presence of a specific initializer signature.
/// - `objectType`: Verifies that the macro is applied to a supported declaration kind
///   (e.g., class, struct, enum) and rejects unsupported targets.
/// - `argumentsExistence`: Confirms that required macro arguments are present and valid,
///   preventing expansion when mandatory parameters are missing.
///
/// Extend this enum with new cases as additional validation rules are introduced,
/// and update `MacroValidatorFactory.get(_:)` to construct the corresponding validators.
enum MacroValidatorType {
    case designedInitializer
    case objectType
    case argumentsExistence
}
