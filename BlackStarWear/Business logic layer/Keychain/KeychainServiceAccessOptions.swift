//
//  KeychainServiceAccessOptions.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

import Security

/// These options are used to determine when a keychain item should be readable. The default value is AccessibleWhenUnlocked.
enum KeychainServiceAccessOptions {
    
    /**
     The data in the keychain item can be accessed only while the device is unlocked by the user.
     This is recommended for items that need to be accessible only while the application is in the foreground.
     Items with this attribute migrate to a new device when using encrypted backups.
     This is the default value for keychain items added without explicitly setting an accessibility constant.
     */
    case accessibleWhenUnlocked
    
    /**
     The data in the keychain item can be accessed only while the device is unlocked by the user.
     This is recommended for items that need to be accessible only while the application is in the foreground.
     Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    case accessibleWhenUnlockedThisDeviceOnly
    
    /**
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications.
     Items with this attribute migrate to a new device when using encrypted backups.
     */
    case accessibleAfterFirstUnlock
    
    /**
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications.
     Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    case accessibleAfterFirstUnlockThisDeviceOnly
    
    /**
     The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
     This is recommended for items that only need to be accessible while the application is in the foreground.
     Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing.
     No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
     */
    case accessibleWhenPasscodeSetThisDeviceOnly
    
    static var defaultOption: KeychainServiceAccessOptions {
        
        return .accessibleWhenUnlocked
    }
    
    var value: String {
        
        switch self {
        case .accessibleWhenUnlocked:
            return kSecAttrAccessibleWhenUnlocked as String
        case .accessibleWhenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        case .accessibleAfterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock as String
        case .accessibleAfterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case .accessibleWhenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
        }
    }
    
}