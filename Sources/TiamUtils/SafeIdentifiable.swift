import Foundation

/// Make your types identifiable with a type safe identifier.
///
/// - Note: Two instances of a type having the the same unique identifer are considered equal.
/// - `id` must be of type `Identifier<Self>`. Compared to the standard `Identifiable` protocol, `SafeIdentifiable` has 2 advantages and 1 downside:
///   1. You cannot assign/compare a `Identifier<A>` to a `Identifier<B>` by mistake
///   2. The `id` property is `Hashable`, `Codable` and `CustomStringConvertible` so you can still use it as a traditional unique identifer
///   3. `SafeIdentifiable` cannot be used as a type, it can only be used as a generic constraint
/// - `RawIdentifierType` is the type of the actual unique identifier.
///   - It's a `String` by default, but it can be anything that conforms to `IdentifierRequirements` (e.g. `Int`)
///   - The `rawIdentifier` property of `Identifier<Self>` is used as the backing store for the actual unique identifier
/// - Code examples:
/// ````
/// struct User: SafeIdentifiable, Codable { // Automatic Codable conformance
///     let id: Identifier<User>
///     var name = ""
/// }
/// struct Country: SafeIdentifiable {
///     let id: Identifier<Country>
/// }
/// struct Product: SafeIdentifiable {
///     typealias RawIdentifierType = Int // Instead of the default String
///     let id: Identifier<Product>
/// }
/// struct Group: SafeIdentifiable {
///     typealias RawIdentifierType = User // User conforms to all "IdentifierRequirements"
///     let id: Identifier<Group>
/// }
/// let user1 = User(id: "1", name: "Tim"), user2 = User(id: "2") // using string literal
/// user1.id == user2.id // comparing 2 Identifier<User> with raw value "1" and "2"
/// user1.id == Country(id: "1").id // ERROR: comparing Identifier<User> and Identifier<Country>
/// let users = Set([user1, user2]) // User conforms to Hashable
/// let product = Product(id: 42) // using integer literal
/// let group = Group(id: Identifier(user2))
/// group.id.name == "toto" // using dynamic member lookup
/// func doSomething1<T: SafeIdentifiable>(t: T) { ... } // using SafeIdentifiable as generic constraint
/// func doSomething2(t: SafeIdentifiable) { ... } // ERROR: using SafeIdentifiable as a type
/// ````
public protocol SafeIdentifiable: Hashable, CustomStringConvertible, Identifiable {
    typealias IdentifierRequirements = Hashable & CustomStringConvertible & Codable
    associatedtype RawIdentifierType: IdentifierRequirements = String
    var id: Identifier<Self> { get }
}

public extension SafeIdentifiable {
    var description: String {
        id.description
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



/// The generic identifer type, wrapping the unique raw identifer
@dynamicMemberLookup
public struct Identifier<T: SafeIdentifiable>: SafeIdentifiable.IdentifierRequirements {
    private let rawIdentifier: T.RawIdentifierType

    public var description: String {
        return rawIdentifier.description
    }
    public init(_ rawIdentifier: T.RawIdentifierType) {
        self.rawIdentifier = rawIdentifier
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawIdentifier = try container.decode(T.RawIdentifierType.self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawIdentifier)
    }
    subscript<U>(dynamicMember keyPath: KeyPath<T.RawIdentifierType, U>) -> U {
        rawIdentifier[keyPath: keyPath]
    }
}

/// `Int` specialization
extension Identifier: ExpressibleByIntegerLiteral where T.RawIdentifierType == Int {
    public typealias IntegerLiteralType = Int
    public init(integerLiteral value: Int) {
        rawIdentifier = value
    }
}

/// `String` specialization
extension Identifier: ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringLiteral where T.RawIdentifierType == String {
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    public typealias StringLiteralType = String
    public init(stringLiteral value: Self.StringLiteralType) {
        rawIdentifier = value
    }
}

/// `UUID` specialization
extension Identifier where T.RawIdentifierType == UUID {
    public init() {
        rawIdentifier = UUID()
    }
}
