//
//  DesignedInitializerValidator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Validates that a type declares at least one designated initializer.
///
/// This validator inspects the member declarations of the type associated with a macro
/// and determines whether there exists an initializer that is not marked as `convenience`.
/// In Swift, a designated initializer is any initializer that is not a convenience initializer.
/// This is important for macros that require a concrete initialization path to guarantee
/// proper dependency injection or setup semantics.
///
/// Behavior:
/// - Iterates over all members in the declaration's member block.
/// - For each initializer it finds, it checks the modifier list for the `convenience` keyword.
/// - Returns `true` if it encounters any member that is not an initializer (allowing validation
///   to continue) or if it finds an initializer that is not `convenience` (i.e., a designated initializer).
/// - Returns `false` only when all initializers present are marked `convenience`, implying the absence
///   of a designated initializer.
///
/// Notes:
/// - Non-initializer members cause the scan to continue and do not fail validation.
/// - If the type contains no initializers at all, this implementation will treat non-initializer
///   members as passing through and will not produce a definitive failure, effectively resulting in
///   a `true` outcome unless the member list is exclusively convenience initializers.
///
/// Dependencies:
/// - Relies on `SwiftSyntax` to traverse and query the declaration's syntax tree.
/// - Conforms to `MacroValidator` and consumes `MacroArguments` that provide the declaration context.
///
/// Use cases:
/// - Enforcing that a type targeted by a macro has a designated initializer for dependency injection.
/// - Preventing application of certain macros to types that only provide convenience initializers.
///
/// Caveats:
/// - If the declaration has no members or only has convenience initializers, validation should fail,
///   but due to the current logic it may pass if non-initializer members are present. Consider refining
///   the logic if strict enforcement is required.
struct DesignedInitializerValidator: MacroValidator {
    func validate(
        for arguments: MacroArguments
    ) -> Bool {
        arguments.declaration.memberBlock.members.contains { member in
            guard let initializer = member.decl.as(InitializerDeclSyntax.self) else {
                return true
            }

            let isConvenience = initializer.modifiers.contains(
                where: { $0.name.tokenKind == .keyword(.convenience) }
            )

            return isConvenience
        }
    }
}
