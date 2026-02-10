//
//  DependenciesContainerMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

struct DependenciesInjectorMacroCreator: ExtensionMacroCreator {
    var arguments: ExtensionMacroArguments
    
    private var name: String { Constants.Macros.dependenciesInjector }
    
    init(arguments: ExtensionMacroArguments) { self.arguments = arguments }
    
    func validate() throws -> Bool {
        let validations = [
            MacroValidatorData(
                type: .objectType,
                message: ObjectTypeDiagnostic(macro: name)
            ),
            MacroValidatorData(
                type: .argumentsExistence,
                message: MissingDependencyArgumentsDiagnostic(macro: name)
            )
        ]
        
        return applyValidators(validations)
    }
    
    func create() throws -> [ExtensionDeclSyntax] {
        guard let type = arguments.type else {
            throw MacroError.invalidConstruction
        }
        
        let dependencies = try parseDependencies()

        return [
            makeExtension(
                type: type,
                dependencies: dependencies
            )
        ]
    }
    
    private func parseDependencies() throws -> [TypeSyntax] {
        guard let nodeArguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw MacroError.invalidArguments
        }

        var seen = Set<String>()
        var result: [TypeSyntax] = []

        for argument in nodeArguments {
            let expr = argument.expression

            guard
                let member = expr.as(MemberAccessExprSyntax.self),
                member.declName.baseName.text == Constants.SintaxKeys.selfSintax
            else {
                diagnose(message: DependenciesInjectorInvalidSelfTypeDiagnostic())
                throw MacroError.invalidDependency
            }

            let type = try extractType(
                from: ExprSyntax(member.base!),
                context: context
            )

            let key = type.trimmedDescription
            guard seen.insert(key).inserted else {
                diagnose(message: DependenciesInjectorDuplicatedDependency(typeName: key))
                throw MacroError.invalidDependency
            }

            result.append(type)
        }

        return result
    }

    private func extractType(
        from expr: ExprSyntax,
        context: some MacroExpansionContext
    ) throws -> TypeSyntax {

        if let ref = expr.as(DeclReferenceExprSyntax.self) {
            return TypeSyntax(
                IdentifierTypeSyntax(
                    name: ref.baseName
                )
            )
        }

        if let member = expr.as(MemberAccessExprSyntax.self) {
            return TypeSyntax(
                MemberTypeSyntax(
                    baseType: try extractType(
                        from: ExprSyntax(member.base!),
                        context: context
                    ),
                    name: member.declName.baseName
                )
            )
        }
        
        diagnose(message: DependenciesInjectorDependencyModelExpected())
        throw MacroError.invalidDependency
    }
    
    private func makeExtension(
        type: some TypeSyntaxProtocol,
        dependencies: [TypeSyntax]
    ) -> ExtensionDeclSyntax {

        let registerBody = CodeBlockItemListSyntax {
            for dep in dependencies {
                """
                \(dep).register()
                """
            }
        }

        return ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier(
                            Constants.SintaxKeys.dependenciesInjectorProtocol
                        )
                    )
                )
            }
        ) {
            """
            func startInjection() {
                \(registerBody)
            }
            """
        }
    }
}

