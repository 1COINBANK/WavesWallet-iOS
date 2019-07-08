//
//  ApplicationDebugSettings.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/28/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension

struct ApplicationDebugSettings: TSUD, Codable, Mutating {
    
    private static let key: String = "com.waves.debug.settings"

    private var isEnableStage: Bool = false
    private var isEnableNotificationsSettingDev: Bool = false
    
    static var defaultValue: ApplicationDebugSettings {
        return ApplicationDebugSettings(isEnableStage: false, isEnableNotificationsSettingDev: false)
    }
    
    static var stringKey: String {
        return key
    }
    
    static var isEnableStage: Bool {
        return ApplicationDebugSettings.get().isEnableStage
    }
    
    static func setupIsEnableStage(isEnable: Bool) {
        var settings = ApplicationDebugSettings.get()
        settings.isEnableStage = isEnable
        ApplicationDebugSettings.set(settings)
    }
    
    static var isEnableNotificationsSettingDev: Bool {
        return ApplicationDebugSettings.get().isEnableNotificationsSettingDev
    }
    
    static func setEnableNotificationsSettingDev(isEnable: Bool) {
        var settings = ApplicationDebugSettings.get()
        settings.isEnableNotificationsSettingDev = isEnable
        ApplicationDebugSettings.set(settings)
    }
}
