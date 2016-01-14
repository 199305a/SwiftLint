//
//  TypeBodyLengthRule.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework
import SwiftXPC

public struct TypeBodyLengthRule: ASTRule, ViolationLevelRule {
    public var warning = RuleParameter(severity: .Warning, value: 200)
    public var error = RuleParameter(severity: .Error, value: 350)

    public init() {}

    public static let description = RuleDescription(
        identifier: "type_body_length",
        name: "Type Body Length",
        description: "Type bodies should not span too many lines."
    )

    public func validateFile(file: File,
        kind: SwiftDeclarationKind,
        dictionary: XPCDictionary) -> [StyleViolation] {
        let typeKinds: [SwiftDeclarationKind] = [.Class, .Struct, .Enum]
        if !typeKinds.contains(kind) {
            return []
        }
        if let offset = (dictionary["key.offset"] as? Int64).flatMap({ Int($0) }),
            let bodyOffset = (dictionary["key.bodyoffset"] as? Int64).flatMap({ Int($0) }),
            let bodyLength = (dictionary["key.bodylength"] as? Int64).flatMap({ Int($0) }) {
            let location = Location(file: file, byteOffset: offset)
            let startLine = file.contents.lineAndCharacterForByteOffset(bodyOffset)
            let endLine = file.contents.lineAndCharacterForByteOffset(bodyOffset + bodyLength)
            for parameter in [error, warning] {
                if let startLine = startLine?.line, let endLine = endLine?.line
                    where endLine - startLine > parameter.value {
                        return [StyleViolation(ruleDescription: self.dynamicType.description,
                            severity: parameter.severity, location: location,
                            reason: "Type body should span \(warning.value) lines " +
                            "or less: currently spans \(endLine - startLine) lines")]
                }
            }
        }
        return []
    }
}
