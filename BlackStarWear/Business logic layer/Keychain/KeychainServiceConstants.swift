//
//  KeychainServiceConstants.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

/// Constants used by the library
struct KeychainServiceConstants {
    
    /// Specifies a Keychain access group. Used for sharing Keychain items between apps.
    static var accessGroup: String { return kSecAttrAccessGroup as String }
    
    /**
     A value that indicates when your app needs access to the data in a keychain item.
     The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainServiceAccessOptions.
     */
    static var accessible: String { return kSecAttrAccessible as String }
    
    /// Used for specifying a String key when setting/getting a Keychain value.
    static var attrAccount: String { return kSecAttrAccount as String }
    
    /// Used for specifying synchronization of keychain items between devices.
    static var attrSynchronizable: String { return kSecAttrSynchronizable as String }
    
    /// An item class key used to construct a Keychain search dictionary.
    static var kClass: String { return kSecClass as String }
    
    /// Specifies the number of values returned from the keychain. The library only supports single values.
    static var matchLimit: String { return kSecMatchLimit as String }
    
    /// A return data type used to get the data from the Keychain.
    static var returnData: String { return kSecReturnData as String }
    
    /// Used for specifying a value when setting a Keychain value.
    static var valueData: String { return kSecValueData as String }
    
    /// Used for returning a reference to the data from the keychain
    static var returnReference: String { return kSecReturnPersistentRef as String }
    
    /// A key whose value is a Boolean indicating whether or not to return item attributes
    static var returnAttributes: String { return kSecReturnAttributes as String }
    
    /// A value that corresponds to matching an unlimited number of items
    static var secMatchLimitAll: String { return kSecMatchLimitAll as String }
}
