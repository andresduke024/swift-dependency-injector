//
//  InjectableDependencyMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

struct InjectableDependencyMacroCreator: ExtensionMacroCreator {
    var arguments: ExtensionMacroArguments
    
    private var name: String { Constants.Macros.injectableDependency }
    
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
        
        let registrations = try parseDependencies()

        let extensionDeclSyntax = makeExtension(
            type: type,
            registrations: registrations
        )
        
        return [extensionDeclSyntax]
    }
    
    private func parseDependencies() throws -> [DependencyRegistration] {
        guard let nodeArguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw MacroError.invalidArguments
        }
        
        var seenProtocols = Set<String>()
        var result: [DependencyRegistration] = []

        for argument in nodeArguments {
            let expr = argument.expression

            if let member = expr.as(MemberAccessExprSyntax.self),
               member.declName.baseName.text == Constants.SintaxKeys.selfSintax {

                let proto: ExprSyntax = member.base?.trimmed ?? ExprSyntax(member)

                let key = proto.description
                guard seenProtocols.insert(key).inserted else {
                    diagnose(message: InjectableDependencyDuplicatedDependency(typeName: key))
                    throw MacroError.invalidDependency
                }
                
                let protocolType = try extractType(
                    from: expr,
                    context: context
                )

                result.append(
                    DependencyRegistration(
                        protocolType: protocolType,
                        key: nil
                    )
                )

                continue
            }

            if let call = expr.as(FunctionCallExprSyntax.self),
               call.calledExpression.trimmedDescription == Constants.SintaxKeys.injectableDependencyArgsModelName {

                guard let firstArg = call.arguments.first else {
                    diagnose(message: InjectableDependencyInvalidArgsModelCase1())
                    throw MacroError.invalidArguments
                }

                let protoExpr = firstArg.expression
                guard
                    let member = protoExpr.as(MemberAccessExprSyntax.self),
                    member.declName.baseName.text == Constants.SintaxKeys.selfSintax
                else {
                    diagnose(message: InjectableDependencyInvalidArgsModelCase2())
                    throw MacroError.invalidArguments
                }

                let proto = member.base!.trimmed
                let protoKey = proto.description
                guard seenProtocols.insert(protoKey).inserted else {
                    diagnose(message: InjectableDependencyDuplicatedDependency(typeName: protoKey))
                    throw MacroError.invalidDependency
                }

                let keyExpr = call.arguments
                    .first(where: { $0.label?.text == "key" })?
                    .expression

                let protocolType = try extractType(
                    from: protoExpr,
                    context: context
                )

                result.append(
                    DependencyRegistration(
                        protocolType: protocolType,
                        key: keyExpr
                    )
                )

                continue
            }

            diagnose(message: InjectableDependencyInvalidArgument())
            throw MacroError.invalidArguments
        }

        return result
    }

    private func makeExtension(
        type: some TypeSyntaxProtocol,
        registrations: [DependencyRegistration]
    ) -> ExtensionDeclSyntax {
        let registerBody = CodeBlockItemListSyntax {
            for reg in registrations { "\(raw: buildInjectorSintax(for: reg))" }
        }

        return ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(
                    type: TypeSyntax(
                        IdentifierTypeSyntax(
                            name: .identifier(
                                Constants.SintaxKeys.injectableDependencyProtocol
                            )
                        )
                    )
                )
            }
        ) {
            """
            static func register() {
                \(registerBody)
            }
            """
        }
    }
    
    private func buildInjectorSintax(for registration: DependencyRegistration) -> String {
        let injectorSintax = "\(Constants.SintaxKeys.injectorClass).\(Constants.SintaxKeys.injectorGlobalProperty).\(Constants.SintaxKeys.injectorAddOrRegisterMethod)"
        let keyArgumentSyntax = registration.key != nil ? ", key: \(registration.key!)" : ""
        let initializerSintax = "{ Self() }"
        
        return """
        \(injectorSintax)(\(registration.protocolType).self\(keyArgumentSyntax)) \(initializerSintax)
        """
    }

    private func extractType(
        from expr: ExprSyntax,
        context: some MacroExpansionContext
    ) throws -> TypeSyntax {

        if let member = expr.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == Constants.SintaxKeys.selfSintax {

            if let base = member.base?.as(DeclReferenceExprSyntax.self) {
                return TypeSyntax(
                    IdentifierTypeSyntax(
                        name: base.baseName
                    )
                )
            }

            if let base = member.base?.as(MemberAccessExprSyntax.self) {
                return TypeSyntax(
                    MemberTypeSyntax(
                        baseType: try extractType(
                            from: ExprSyntax(base),
                            context: context
                        ),
                        name: base.declName.baseName
                    )
                )
            }
        }
        
        diagnose(message: InjectableDependencyMissingSelfDiagnostic())
        throw MacroError.invalidDependency
    }
    
}
