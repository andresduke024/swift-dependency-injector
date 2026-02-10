//
//  Untitled.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

/// A shared implementation helper for macros that synthesize dependency-injected initializers and
/// stored properties into a declaration.
///
/// Conforming types provide macro expansion behavior (via `MemberMacroCreator`) that:
/// - Parses the macro argument list to determine requested dependencies (either simple `Self.Type`
///   references or configured dependencies using a `Dependency(...)` builder call).
/// - Validates macro usage and reports diagnostics for common mistakes (e.g., using designated
///   initializers incorrectly, duplicate dependencies, missing `Self.` qualification, or name
///   conflicts with initializer parameters).
/// - Generates private stored properties for each dependency, optionally preserving attribute
///   annotations passed to the macro.
/// - Synthesizes an initializer that:
///   - Accepts explicitly annotated init parameters (marked with `@InitParameter` on stored
///     properties in the type).
///   - Appends parameters for each dependency with default values that call the injector
///     (constructed via `InjectorGetMethodBuilder`), enabling call-site omission.
///   - Assigns both explicit init parameters and dependencies to their corresponding stored
///     properties.
///
/// Key behaviors and responsibilities provided by the default implementation:
/// - Argument parsing:
///   - Supports `Self.SomeType` for simple dependencies.
///   - Supports `Dependency(Self.SomeType, injectionType: ..., constrainedTo: ..., name: ...)`
///     for configured dependencies.
/// - Validation:
///   - Ensures no duplicate dependencies of the same simple type are declared.
///   - Ensures `Self.` qualification is present where required and reports a diagnostic if not.
///   - Ensures no naming conflicts between `@InitParameter` properties and generated dependency
///     property names.
///   - Applies additional validators such as the designated initializer rule.
/// - Code generation:
///   - Emits `private let` stored properties for each dependency, preserving attributes passed to
///     the macro site.
///   - Emits an initializer whose parameter ordering preserves explicitly declared init parameters
///     first, followed by dependency parameters (with defaults), while maintaining correct trivia
///     and formatting.
///
/// Expected environment and collaborators:
/// - Relies on types and utilities such as:
///   - `MemberMacroCreator` (protocol conformance for macro expansion context and declaration access)
///   - `MacroValidatorData`, `DesignedInitializerDiagnostic`, `InvalidSelfTypeDiagnostic`,
///     `DuplicateDependencyDiagnostic`, `MissingSelfDiagnostic`, `InitParameterNameConflictDiagnostic`
///     for validation and diagnostics
///   - `MacroError` for error signaling during parsing/validation
///   - `Dependency` and `InitParameter` for internal modeling
///   - `InjectorGetMethodBuilder` to construct default dependency expressions
///   - `Constants.SintaxKeys` and `Constants.Trivia` for consistent token/text handling
///
/// Usage:
/// - Adopt this protocol in a macro type that injects dependencies into types (e.g., structs/classes).
/// - Call `validate()` prior to generation to enforce macro rules.
/// - Use `create(with:)` to synthesize stored properties and a convenience initializer based on
///   the macro arguments and any `@InitParameter`-annotated properties found in the target
///   declaration.
///
/// Notes:
/// - The initializer generation preserves custom init parameters first, then dependency parameters
///   with default values, allowing callers to omit dependencies when relying on the injector.
/// - Variable names for dependencies are derived from the type name by removing protocol suffixes
///   and lowercasing the first character, unless an explicit `name:` is provided in a configured
///   dependency.
/// - All generated dependency properties are `private let` to encourage immutability and clear
///   ownership within the type.
///
/// Errors and diagnostics:
/// - Throws `MacroError.invalidArguments` if the macro is invoked without a valid argument list.
/// - Throws `MacroError.invalidDependency` when a dependency cannot be parsed, is duplicated,
///   or lacks required `Self.` qualification.
/// - Emits diagnostics to the expansion context for all invalid states to guide the user.
protocol BaseInjectedConstructorMacroCreator: MemberMacroCreator {}

extension BaseInjectedConstructorMacroCreator {
    
    func validate() throws -> Bool {
        let validations = [
            MacroValidatorData(
                type: .designedInitializer,
                message: DesignedInitializerDiagnostic()
            )
        ]
        
        return applyValidators(validations)
    }
    
    func create(
        with attributes: [AttributeSyntax]?
    ) throws -> [DeclSyntax] {
        let dependencies = try parseDependencies()
        let initParameters = parseInitParameters(from: declaration)

        try validateNoNameConflicts(
            parameters: initParameters,
            dependencies: dependencies,
            context: context,
            node: Syntax(declaration)
        )

        let properties = dependencies.map {
            makeProperty($0, attributes)
        }
 
        let initializer = makeInitializer(
            dependencies: dependencies,
            parameters: initParameters
        )

        return properties.map(DeclSyntax.init) + [
            DeclSyntax(initializer)
        ]
    }
    
    private func parseDependencies() throws -> [Dependency] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw MacroError.invalidArguments
        }

        var dependencies: [Dependency] = []
        var seenSimpleTypes = Set<String>()

        for argument in arguments {
            let expr = argument.expression

            let dependency = try parseDependency(expr, &seenSimpleTypes)
            dependencies.append(dependency)
        }

        return dependencies
    }
    
    private func parseDependency(
        _ expr: ExprSyntax,
        _ seenSimpleTypes: inout Set<String>
    ) throws -> Dependency {
        if let dependency = parseTypeDependency(expr) {
            try validateDuplicateDependency(dependency: dependency, seenSimpleTypes: &seenSimpleTypes)
            return dependency
        }

        if let dependency = try parseConfiguredDependencyIfPossible(expr, in: context) {
            return dependency
        }

        diagnose(message: InjectedConstructorInvalidSelfTypeDiagnostic())
        throw MacroError.invalidDependency
    }
    
    private func validateDuplicateDependency(
        dependency: Dependency,
        seenSimpleTypes: inout Set<String>
    ) throws {
        if !seenSimpleTypes.insert(dependency.typeName).inserted {
            diagnose(message: InjectedConstructorDuplicateDependencyDiagnostic(typeName: dependency.typeName))
            throw MacroError.invalidDependency
        }
    }
    
    private func validateSelfTypeConformance(_ expr: SyntaxProtocol) -> DeclReferenceExprSyntax? {
        guard let memberAccess = expr.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == Constants.SintaxKeys.selfSintax,
              let base = memberAccess.base?.as(DeclReferenceExprSyntax.self)
        else { return nil }
        
        return base
    }
    
    private func parseTypeDependency(
        _ expr: ExprSyntax
    ) -> Dependency? {
        guard let base = validateSelfTypeConformance(expr) else { return nil }

        let typeName = base.baseName.text

        return Dependency(
            typeName: typeName,
            variableName: makeVariableName(from: typeName),
            injectionType: Constants.SintaxKeys.regularInjectionTypePropertyValue,
            constrainedTo: nil,
            source: .simple
        )
    }
    
    private func parseConfiguredDependencyIfPossible(
        _ expr: ExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> Dependency? {

        guard let call = expr.as(FunctionCallExprSyntax.self),
              let callee = call.calledExpression.as(DeclReferenceExprSyntax.self),
              callee.baseName.text == Constants.SintaxKeys.dependencyClass
        else { return nil }

        return try parseConfiguredDependency(from: call, in: context)
    }

    private func parseConfiguredDependency(
        from call: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> Dependency {
        guard let firstArg = call.arguments.first else {
            throw MacroError.invalidDependency
        }

        guard let base = validateSelfTypeConformance(firstArg.expression) else {
            diagnose(message: InjectedConstructorMissingSelfDiagnostic())
            throw MacroError.invalidDependency
        }
        
        let typeName = base.baseName.text

        var injectionType: String? = nil
        var key: String? = nil
        var explicitVariableName: String? = nil

        for argument in call.arguments.dropFirst() {
            switch argument.label?.text {
            case Constants.SintaxKeys.injectionTypeProperty:
                injectionType = argument.expression.description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            case Constants.SintaxKeys.constrainedToProperty:
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                    key = stringLiteral.segments.description.replacingOccurrences(of: "\"", with: "")
                }
            case Constants.SintaxKeys.nameProperty:
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                    explicitVariableName = stringLiteral.segments
                        .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
                        .joined()
                }
            default:
                break
            }
        }

        return Dependency(
            typeName: typeName,
            variableName: explicitVariableName ?? makeVariableName(from: typeName),
            injectionType: injectionType ?? Constants.SintaxKeys.regularInjectionTypePropertyValue,
            constrainedTo: key,
            source: .configured
        )
    }
    
    private func makeVariableName(from typeName: String) -> String {
        typeName
            .removeSuffix(Constants.SintaxKeys.protocolSintax)
            .lowercasedFirst()
    }

    private func makeProperty(
        _ dependency: Dependency,
        _ attributes: [AttributeSyntax]?
    ) -> VariableDeclSyntax {
        VariableDeclSyntax(
            attributes: makePropertyAttributes(from: attributes),
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.private))
            },
            bindingSpecifier: .keyword(.let)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier(dependency.variableName)
                ),
                typeAnnotation: TypeAnnotationSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier(dependency.typeName)
                    )
                )
            )
        }
    }
    
    private func makePropertyAttributes(
        from attributes: [AttributeSyntax]?
    ) -> AttributeListSyntax {
        guard let attributes else { return [] }
        
        return AttributeListSyntax(
            attributes.map { .attribute($0) }
        )
    }

    private func makeDependencyParameter(
        _ dependency: Dependency,
        isFirst: Bool
    ) -> FunctionParameterSyntax {
        let injectorCall = InjectorGetMethodBuilder(dependency: dependency).build()

        return makeParameter(
            isFirst: isFirst,
            name: dependency.variableName,
            type: IdentifierTypeSyntax(
                name: .identifier(dependency.typeName)
            ),
            defaultValue: InitializerClauseSyntax(
                value: ExprSyntax(injectorCall)
            )
        )
    }

    private func makeAssignment(
        name: String
    ) -> CodeBlockItemSyntax {

        let assignment = InfixOperatorExprSyntax(
            leftOperand: ExprSyntax(
                MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier(Constants.SintaxKeys.selfSintax)
                    ),
                    name: .identifier(name)
                )
            ),
            operator: BinaryOperatorExprSyntax(
                operator: .equalToken()
            ),
            rightOperand: ExprSyntax(
                DeclReferenceExprSyntax(
                    baseName: .identifier(name)
                )
            )
        )

        return CodeBlockItemSyntax(
            item: .stmt(
                StmtSyntax(
                    ExpressionStmtSyntax(expression: ExprSyntax(assignment))
                )
            )
        )
    }

    private func makeInitializer(
        dependencies: [Dependency],
        parameters: [InitParameter]
    ) -> InitializerDeclSyntax {

        let parameterClause = makeParameterClause(dependencies, parameters)
        
        let body = CodeBlockSyntax {

            for parameter in parameters {
                makeAssignment(name: parameter.name)
            }

            for dependency in dependencies {
                makeAssignment(name: dependency.variableName)
            }
        }

        return InitializerDeclSyntax(
            signature: FunctionSignatureSyntax(
                parameterClause: parameterClause
            ),
            body: body
        )
    }

    private func makeParameterClause(
        _ dependencies: [Dependency],
        _ parameters: [InitParameter]
    ) -> FunctionParameterClauseSyntax {
        let hasParameters = !parameters.isEmpty
        
        let isFirst: (_ index: Int) -> Bool = { $0 == 0 }
        
        return FunctionParameterClauseSyntax {
            for (index, parameter) in parameters.enumerated() {
                makeInitParameter(parameter, isFirst: isFirst(index))
            }

            for (index, dependency) in dependencies.enumerated() {
                makeDependencyParameter(dependency, isFirst: !hasParameters && isFirst(index))
            }
        }

    }
    
    private func parseInitParameters(
        from declaration: some DeclGroupSyntax
    ) -> [InitParameter] {

        var parameters: [InitParameter] = []

        for member in declaration.memberBlock.members {
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                let binding = variable.bindings.first,
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                let typeAnnotation = binding.typeAnnotation
            else { continue }

            let hasAttribute = variable.attributes.contains {
                $0.as(AttributeSyntax.self)?
                    .attributeName
                    .as(IdentifierTypeSyntax.self)?
                    .name.text == Constants.SintaxKeys.initParameterClass
            }

            guard hasAttribute else { continue }

            parameters.append(
                InitParameter(
                    name: identifier.identifier.text,
                    type: typeAnnotation.type
                )
            )
        }

        return parameters
    }
    
    private func validateNoNameConflicts(
        parameters: [InitParameter],
        dependencies: [Dependency],
        context: some MacroExpansionContext,
        node: Syntax
    ) throws {
        let dependencyNames = Set(dependencies.map(\.variableName))

        for parameter in parameters {
            guard dependencyNames.contains(parameter.name) else { continue }
            
            diagnose(message: InitParameterNameConflictDiagnostic(name: parameter.name))
            throw MacroError.invalidDependency
        }
    }
    
    private func makeInitParameter(
        _ parameter: InitParameter,
        isFirst: Bool
    ) -> FunctionParameterSyntax {
        makeParameter(
            isFirst: isFirst,
            name: parameter.name,
            type: parameter.type
        )
    }
    
    private func makeParameter(
        isFirst: Bool,
        name: String,
        type: TypeSyntaxProtocol,
        defaultValue: InitializerClauseSyntax? = nil
    ) -> FunctionParameterSyntax {
        let leadingTrivia = isFirst
            ? (.newline + Constants.Trivia.defaultSpaces)
            : Constants.Trivia.defaultSpaces
        
        return FunctionParameterSyntax(
            leadingTrivia: leadingTrivia,
            firstName: .identifier(name),
            colon: .colonToken(trailingTrivia: .space),
            type: type,
            defaultValue: defaultValue,
            trailingComma: .commaToken(trailingTrivia: .newline)
        )
    }
}
