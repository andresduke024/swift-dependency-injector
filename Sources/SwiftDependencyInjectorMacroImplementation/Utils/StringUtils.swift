//
//  StringUtils.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 12/01/26.
//

extension String {
    /// Returns a new string with the specified suffix removed, if present.
    ///
    /// This method checks whether the string ends with the given `suffix`.
    /// - If it does, the suffix is removed and the resulting string is returned.
    /// - If it does not, the original string is returned unchanged.
    ///
    /// The operation is non-mutating.
    ///
    /// - Parameter suffix: The substring to remove from the end of the string if it exists.
    /// - Returns: A new `String` without the specified suffix if it was present; otherwise, the original string.
    ///
    /// - Note: The comparison is case-sensitive and operates on character counts, not byte counts.
    ///
    /// - Example:
    ///   ```swift
    ///   "HelloWorld".removeSuffix("World")   // "Hello"
    ///   "HelloWorld".removeSuffix("world")   // "HelloWorld" (no change)
    ///   "filename.swift".removeSuffix(".swift") // "filename"
    ///   ```
    func removeSuffix(_ suffix: String) -> Self {
        guard hasSuffix(suffix) else { return self }
        
        return String(
            dropLast(suffix.count)
        )
    }
    
    /// Returns a copy of the string with only its first character lowercased.
    ///
    /// - Important: If the string is empty, this returns an empty string.
    /// - Note: This operation is non-mutating; it returns a new `String`.
    ///
    /// - Returns: A new string whose first character is lowercased and whose remaining characters are unchanged.
    ///
    /// - Example:
    ///   ```swift
    ///   "Hello".lowercasedFirst()   // "hello"
    ///   "URLSession".lowercasedFirst() // "uRLSession"
    ///   "".lowercasedFirst()        // ""
    ///   ```
    func lowercasedFirst() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
