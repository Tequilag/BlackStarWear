//
//  KeychainService.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

/**
 A collection of helper functions for saving text and data in the keychain.
 */
class KeychainService {
    
    // MARK: - Public properties
    
    /// Contains result code from the last operation. Value is noErr (0) for a successful result.
    var lastResultCode: OSStatus = noErr
    
    var keyPrefix = "com.bsw"
    
    /**
     Specify an access group that will be used to access keychain items. Access groups can be used to share keychain items between applications.
     When access group value is nil all application access groups are being accessed. Access group name is used by all functions: set, get, delete and clear.
     */
    var accessGroup: String?
    
    /**
     Specifies whether the items can be synchronized with other devices through iCloud. Setting this property to true will
     add the item to other devices with the `set` method and obtain synchronizable items with the `get` command.
     Deleting synchronizable items will remove them from all devices.
     In order for keychain synchronization to work the user must enable "Keychain" in iCloud settings.
     */
    var synchronizable: Bool = false
    
    /// All keys from keychain
    var allKeys: [String] {
        
        var query: [String: Any] = [
            KeychainServiceConstants.kClass: kSecClassGenericPassword,
            KeychainServiceConstants.returnData: true,
            KeychainServiceConstants.returnAttributes: true,
            KeychainServiceConstants.returnReference: true,
            KeychainServiceConstants.matchLimit: KeychainServiceConstants.secMatchLimitAll
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        var result: AnyObject?
        
        let lastResultCode = withUnsafeMutablePointer(to: &result) {
            
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if lastResultCode == noErr {
            
            return (result as? [[String: Any]])?.compactMap {
                
                $0[KeychainServiceConstants.attrAccount] as? String
            } ?? []
        }
        
        return []
    }
    
    // MARK: - Private properties
    
    private let lock = NSLock()
    
    // MARK: - Lifecycle
    
    /// Instantiate a KeychainService object
    init() { }
    
    /**
     - parameter keyPrefix: a prefix that is added before the key in get/set methods. Note that `clear` method still clears everything from the Keychain.
     */
    init(keyPrefix: String) {
        
        self.keyPrefix = keyPrefix
    }
    
}

// MARK: - Public methods
extension KeychainService {
    
    /**
     Stores the text value in the keychain item under the given key.
     
     - parameter key: Key under which the text value is stored in the keychain.
     - parameter value: Text string to be written to the keychain.
     - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item.
     By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
     
     - returns: True if the text was successfully written to the keychain.
     */
    @discardableResult
    func set(_ value: String, forKey key: String,
             withAccess access: KeychainServiceAccessOptions? = nil) -> Bool {
        
        guard let value = value.data(using: String.Encoding.utf8) else { return false }
            
        return set(value, forKey: key, withAccess: access)
    }
    
    /**
     Stores the data in the keychain item under the given key.
     
     - parameter key: Key under which the data is stored in the keychain.
     - parameter value: Data to be written to the keychain.
     - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item.
     By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
     
     - returns: True if the text was successfully written to the keychain.
     */
    @discardableResult
    func set(_ value: Data, forKey key: String,
             withAccess access: KeychainServiceAccessOptions? = nil) -> Bool {
        
        // The lock prevents the code to be run simultaneously
        // from multiple threads which may result in crashing
        lock.lock()
        defer { lock.unlock() }
        
        deleteNoLock(key) // Delete any existing key before saving it
        let accessible = access?.value ?? KeychainServiceAccessOptions.defaultOption.value
        
        let prefixedKey = keyWithPrefix(key)
        
        var query: [String: Any] = [
            KeychainServiceConstants.kClass: kSecClassGenericPassword,
            KeychainServiceConstants.attrAccount: prefixedKey,
            KeychainServiceConstants.valueData: value,
            KeychainServiceConstants.accessible: accessible
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: true)
        
        lastResultCode = SecItemAdd(query as CFDictionary, nil)
        
        return lastResultCode == noErr
    }
    
    /**
     Stores the boolean value in the keychain item under the given key.
     - parameter key: Key under which the value is stored in the keychain.
     - parameter value: Boolean to be written to the keychain.
     - parameter withAccess: Value that indicates when your app needs access to the value in the keychain item.
     By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
     
     - returns: True if the value was successfully written to the keychain.
     */
    @discardableResult
    func set(_ value: Bool, forKey key: String,
             withAccess access: KeychainServiceAccessOptions? = nil) -> Bool {
        
        let bytes: [UInt8] = value ? [1] : [0]
        let data = Data(bytes)
        
        return set(data, forKey: key, withAccess: access)
    }
    
    /**
     Retrieves the text value from the keychain that corresponds to the given key.
     
     - parameter key: The key that is used to read the keychain item.
     
     - returns: The text value from the keychain. Returns nil if unable to read the item.
     */
    func getString(_ key: String) -> String? {
        
        if let data = getData(key) {
            
            if let currentString = String(data: data, encoding: .utf8) {
                return currentString
            }
            
            lastResultCode = -67853 // errSecInvalidEncoding
        }
        
        return nil
    }
    
    /**
     Retrieves the data from the keychain that corresponds to the given key.
     
     - parameter key: The key that is used to read the keychain item.
     - parameter asReference: If true, returns the data as reference (needed for things like NEVPNProtocol).
     
     - returns: The text value from the keychain. Returns nil if unable to read the item.
     */
    func getData(_ key: String, asReference: Bool = false) -> Data? {
        
        // The lock prevents the code to be run simultaneously
        // from multiple threads which may result in crashing
        lock.lock()
        defer { lock.unlock() }
        
        let prefixedKey = keyWithPrefix(key)
        
        var query: [String: Any] = [
            KeychainServiceConstants.kClass: kSecClassGenericPassword,
            KeychainServiceConstants.attrAccount: prefixedKey,
            KeychainServiceConstants.matchLimit: kSecMatchLimitOne
        ]
        
        if asReference {
            
            query[KeychainServiceConstants.returnReference] = kCFBooleanTrue
        }
        else {
            
            query[KeychainServiceConstants.returnData] =  kCFBooleanTrue
        }
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        var result: AnyObject?
        
        lastResultCode = withUnsafeMutablePointer(to: &result) {
            
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        return lastResultCode == noErr ? result as? Data : nil
    }
    
    /**
     Retrieves the boolean value from the keychain that corresponds to the given key.
     - parameter key: The key that is used to read the keychain item.
     
     - returns: The boolean value from the keychain. Returns nil if unable to read the item.
     */
    func getBool(_ key: String) -> Bool? {
        
        guard let data = getData(key) else { return nil }
        guard let firstBit = data.first else { return nil }
        return firstBit == 1
    }
    
    /**
     Deletes the single keychain item specified by the key.
     
     - parameter key: The key that is used to delete the keychain item.
     
     - returns: True if the item was successfully deleted.
     */
    @discardableResult
    func delete(_ key: String) -> Bool {
        
        // The lock prevents the code to be run simultaneously
        // from multiple threads which may result in crashing
        lock.lock()
        defer { lock.unlock() }
        
        return deleteNoLock(key)
    }
    
    /**
     Deletes all Keychain items used by the app. Note that this method deletes all items regardless of the prefix settings used for initializing the class.
     
     - returns: True if the keychain items were successfully deleted.
     */
    @discardableResult
    func clear() -> Bool {
        
        // The lock prevents the code to be run simultaneously
        // from multiple threads which may result in crashing
        lock.lock()
        defer { lock.unlock() }
        
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        lastResultCode = SecItemDelete(query as CFDictionary)
        
        return lastResultCode == noErr
    }
    
}

// MARK: - Private methods
private extension KeychainService {
    
    /**
     Adds kSecAttrSynchronizable: kSecAttrSynchronizableAny` item to the dictionary when the `synchronizable` property is true.
     
     - parameter items: The dictionary where the kSecAttrSynchronizable items will be added when requested.
     - parameter addingItems: Use `true` when the dictionary will be used with `SecItemAdd` method (adding a keychain item).
     For getting and deleting items, use `false`.
     
     - returns: the dictionary with kSecAttrSynchronizable item added if it was requested. Otherwise, it returns the original dictionary.
     */
    func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
        
        guard synchronizable else { return items }
        var result: [String: Any] = items
        result[KeychainServiceConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
        return result
    }
    
    func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
        
        guard let accessGroup = accessGroup else { return items }
        
        var result: [String: Any] = items
        result[KeychainServiceConstants.accessGroup] = accessGroup
        return result
    }
    
    /// Returns the key with currently set prefix.
    func keyWithPrefix(_ key: String) -> String {
        
        return "\(keyPrefix)\(key)"
    }
    
    /**
     Same as `delete` but is only accessed internally, since it is not thread safe.
     
     - parameter key: The key that is used to delete the keychain item.
     
     - returns: True if the item was successfully deleted.
     */
    @discardableResult
    func deleteNoLock(_ key: String) -> Bool {
        
        let prefixedKey = keyWithPrefix(key)
        
        var query: [String: Any] = [
            KeychainServiceConstants.kClass: kSecClassGenericPassword,
            KeychainServiceConstants.attrAccount: prefixedKey
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        lastResultCode = SecItemDelete(query as CFDictionary)
        
        return lastResultCode == noErr
    }
    
}
