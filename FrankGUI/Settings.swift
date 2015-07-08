//
//  Settings.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 11/06/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import Foundation

private enum UserDefaultsKeys : String
{
    case AppPathURLKey     = "AppPathURLKey"
    case ScriptsPathURLKey = "ScriptsPathURLKey"
    case PlatformKey       = "PlatformKey"
    case TabChoiceKey      = "TabChoiceKey"
}

private extension NSUserDefaults
{
    func URLForKey(key: UserDefaultsKeys) -> NSURL?
    {
        return URLForKey(key.rawValue)
    }
    
    func setURL(url: NSURL?, forKey defaultName: UserDefaultsKeys)
    {
        setURL(url, forKey: defaultName.rawValue)
    }

    func stringForKey(key: UserDefaultsKeys) -> String?
    {
        return stringForKey(key.rawValue)
    }
    
    func setString(value: String?, forKey defaultName: UserDefaultsKeys)
    {
        setObject(value, forKey: defaultName.rawValue)
    }

    func integerForKey(key: UserDefaultsKeys) -> Int
    {
        return integerForKey(key.rawValue)
    }
    
    func setInteger(value: Int, forKey defaultName: UserDefaultsKeys)
    {
        setInteger(value, forKey: defaultName.rawValue)
    }
}

final class Settings : NSObject
{
    enum TabChoice : Int
    {
        case Undefined
        case Runner
        case Settings
    }

    private let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()

    var tabChoice: TabChoice {
        willSet
        {
            if newValue != tabChoice
            {
                defaults.setInteger(newValue.rawValue, forKey: UserDefaultsKeys.TabChoiceKey)
            }
        }
    }

    var appPathURL: NSURL? {
        willSet
        {
            if newValue != appPathURL
            {
                defaults.setURL(newValue, forKey: .AppPathURLKey)
            }
        }
    }

    var scriptsPathURL: NSURL? {
        willSet
        {
            if newValue != scriptsPathURL
            {
                defaults.setURL(newValue, forKey: .ScriptsPathURLKey)
            }
        }
    }

    var platform: String? {
        willSet
        {
            if newValue != platform
            {
                defaults.setString(newValue, forKey: .PlatformKey)
            }
        }
    }

    override init()
    {
        // Attempt to read the values from user preferences
        appPathURL = defaults.URLForKey(.AppPathURLKey)
        scriptsPathURL = defaults.URLForKey(.ScriptsPathURLKey)
        platform = defaults.stringForKey(.PlatformKey)
        tabChoice = TabChoice(rawValue: defaults.integerForKey(.TabChoiceKey))!
    }
}
