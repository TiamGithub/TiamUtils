import Foundation

public extension UserDefaults {
    /// A key type to store required `Value` objects in UserDefaults
    ///
    /// Usage:
    /// ````
    /// public extension UserDefaults.RequiredKey where Value == Int {
    ///     static var myIntKey: Self { Self(defaultValue: 42) }
    /// }
    /// let standardDefaults = UserDefaults.standard
    /// var someInt: Int = standardDefaults[required: .myIntKey] // someInt == 42 if key was not present
    /// standardDefaults[required: .myIntKey] = 24
    /// someInt = standardDefaults[required: .myIntKey] // someInt == 24
    /// ````
    /// - Warning: do not change the name of the static computed property (ie. `myIntKey` here) once it has been used to persist data in UserDefaults
    struct RequiredKey<Value: PropertyListValue> {
        fileprivate let name: String
        fileprivate let defaultValue: Value

        public init(defaultValue: Value, name: StaticString = #function) {
            let fullName = "\(name)__\(String(describing: Self.self))"
            self.name = fullName
            self.defaultValue = defaultValue
        }
    }

    subscript<Value>(required key: RequiredKey<Value>) -> Value {
        get { object(forKey: key.name) as? Value ?? key.defaultValue }
        set { set(newValue, forKey: key.name) }
    }

    /// A key type to store facultative `Value` objects in UserDefaults
    ///
    /// Usage:
    /// ````
    /// public extension UserDefaults.FacultativeKey where Value == Int {
    ///     static var myIntKey: Self { Self() }
    /// }
    /// let standardDefaults = UserDefaults.standard
    /// var someInt: Int? = standardDefaults[facultative: .myIntKey] // someInt == nil if key was not present
    /// standardDefaults[facultative: .myIntKey] = 5
    /// someInt = standardDefaults[facultative: .myIntKey] // someInt == 5
    /// ````
    /// - Warning: do not change the name of the static computed property (ie. `myIntKey` here) once it has been used to persist data in UserDefaults
    struct FacultativeKey<Value: PropertyListValue> {
        fileprivate let name: String

        public init(name: StaticString = #function) {
            let fullName = "\(name)__\(String(describing: Self.self))"
            self.name = fullName
        }
    }

    subscript<Value>(facultative key: FacultativeKey<Value>) -> Value? {
        get { object(forKey: key.name) as? Value }
        set { set(newValue, forKey: key.name) }
    }

    func removeObject<Value>(for key: FacultativeKey<Value>) {
        removeObject(forKey: key.name)
    }
}

public protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension NSData: PropertyListValue {}
extension String: PropertyListValue {}
extension NSString: PropertyListValue {}
extension Date: PropertyListValue {}
extension NSDate: PropertyListValue {}
extension NSNumber: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Int8: PropertyListValue {}
extension Int16: PropertyListValue {}
extension Int32: PropertyListValue {}
extension Int64: PropertyListValue {}
extension UInt: PropertyListValue {}
extension UInt8: PropertyListValue {}
extension UInt16: PropertyListValue {}
extension UInt32: PropertyListValue {}
extension UInt64: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
