//
//  WalletRealmConfig.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 23/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

enum WalletRealmFactory {

    static func create(accountAddress: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(accountAddress).realm")
        config.deleteRealmIfMigrationNeeded = true
        return config
    }

    static func realm(accountAddress: String) throws -> Realm {
        let config = create(accountAddress: accountAddress)
        return try Realm(configuration: config)
    }
}
