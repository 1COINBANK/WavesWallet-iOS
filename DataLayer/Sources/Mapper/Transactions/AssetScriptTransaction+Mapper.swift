//
//  AssetScriptTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import DomainLayer
import Extensions

extension AssetScriptTransaction {

    convenience init(transaction: DomainLayer.DTO.AssetScriptTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        signature = transaction.signature
        version = transaction.version
        script = transaction.script
        assetId = transaction.assetId

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.AssetScriptTransaction {

    init(transaction: NodeService.DTO.SetAssetScriptTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {
        
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height ?? -1,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  chainId: transaction.chainId,
                  version: transaction.version,
                  script: transaction.script,
                  assetId: transaction.assetId,
                  modified: Date(),
                  status: status)
    }

    init(transaction: AssetScriptTransaction) {
        
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: transaction.proofs.toArray(),
                  chainId: transaction.chainId.value,
                  version: transaction.version,
                  script: transaction.script,
                  assetId: transaction.assetId,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}

