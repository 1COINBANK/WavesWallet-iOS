//
//  TransactionsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CryptoSwift
import Base58
import WavesSDKExtension
import WavesSDKClientCrypto
import WavesSDKCrypto
import WavesSDKServices

fileprivate enum Constants {
    static let maxLimit: Int = 10000
}

extension TransactionSenderSpecifications {

    var version: Int {
        switch self {
        case .createAlias:
            return 2

        case .lease:
            return 2
            
        case .burn:
            return 2

        case .cancelLease:
            return 2

        case .data:
            return 1

        case .send:
            return 2
        }
    }

    var type: TransactionType {
        switch self {
        case .createAlias:
            return TransactionType.alias

        case .lease:
            return TransactionType.lease
            
        case .burn:
            return TransactionType.burn

        case .cancelLease:
            return TransactionType.leaseCancel

        case .data:
            return TransactionType.data

        case .send:
            return TransactionType.transfer
        }
    }
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {
    
    private let transactionRules: MoyaProvider<GitHub.Service.TransactionRules> = .anyMoyaProvider()
    private let transactionNodeService = ServicesFactory.shared.transactionNodeService
    private let leasingNodeService = ServicesFactory.shared.leasingNodeService
    
    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func transactions(by address: DomainLayer.DTO.Address, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: address.address)
            .flatMap { [weak self] environment -> Observable<[DomainLayer.DTO.AnyTransaction]> in

                guard let self = self else { return Observable.never() }
                
                let limit = min(Constants.maxLimit, offset + limit)
                
                return self
                    .transactionNodeService
                    .list(address: address.address,
                          offset: 0,
                          limit: limit, enviroment: environment.environmentServiceNode)
                    .map { $0.anyTransactions(status: .completed, environment: environment) }
            }
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Observable<[DomainLayer.DTO.LeaseTransaction]> in
                
                guard let self = self else { return Observable.never() }
                
                return self
                    .leasingNodeService
                    .activeLeasingTransactions(by: accountAddress,
                                               enviroment: environment.environmentServiceNode)
                    .map { $0.map { tx in
                        return DomainLayer.DTO.LeaseTransaction(transaction: tx, status: .activeNow, environment: environment)
                        }
                    }
                    .asObservable()
            }
    }

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction> {

        return environmentRepository
            .accountEnvironment(accountAddress: wallet.address)
            .flatMap { [weak self] environment -> Observable<DomainLayer.DTO.AnyTransaction> in

                guard let self = self else { return Observable.never() }
                
                let timestamp = Date().millisecondsSince1970(timestampDiff: environment.timestampServerDiff)
                var signature = specifications.signature(timestamp: timestamp,
                                                         scheme: environment.scheme,
                                                         publicKey: wallet.publicKey.publicKey)
                
                do {
                    signature = try wallet.sign(input: signature, kind: [.none])
                } catch let e {
                    SweetLogger.error(e)
                    return Observable.error(TransactionsInteractorError.invalid)
                }

                let proofs = [Base58.encode(signature)]

                let broadcastSpecification = specifications.broadcastSpecification(timestamp: timestamp,
                                                                                   environment: environment,
                                                                                   publicKey: wallet.publicKey.getPublicKeyStr(),
                                                                                   proofs: proofs)
                return self
                    .transactionNodeService
                    .broadcast(query: broadcastSpecification,
                               enviroment: environment.environmentServiceNode)
                    .map({ $0.anyTransaction(status: .unconfirmed, environment: environment) })
                    .asObservable()
            }
    }

// MARK - -  Dont support
    func newTransactions(by address: DomainLayer.DTO.Address,
                         specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func transactions(by address: DomainLayer.DTO.Address,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }


    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func feeRules() -> Observable<DomainLayer.DTO.TransactionFeeRules> {
        return transactionRules
            .rx
            .request(.get)
            .map(GitHub.DTO.TransactionFeeRules.self)
            .asObservable()
            .map({ (txRules) -> DomainLayer.DTO.TransactionFeeRules in

                let deffault = txRules.calculate_fee_rules[TransactionFeeDefaultRule]

                let rules = TransactionType
                    .all
                    .reduce(into: [TransactionType: DomainLayer.DTO.TransactionFeeRules.Rule](), { (result, type) in

                    let rule = txRules.calculate_fee_rules["\(type.rawValue)"]

                    let addSmartAssetFee = (rule?.add_smart_asset_fee ?? deffault?.add_smart_asset_fee) ?? false
                    let addSmartAccountFee = (rule?.add_smart_account_fee ?? deffault?.add_smart_account_fee) ?? false
                    let minPriceStep = (rule?.min_price_step ?? deffault?.min_price_step) ?? 0
                    let fee = (rule?.fee ?? deffault?.fee) ?? 0
                    let pricePerTransfer = (rule?.price_per_transfer ?? deffault?.price_per_transfer) ?? 0
                    let pricePerKb = (rule?.price_per_kb ?? deffault?.price_per_kb) ?? 0

                    let newRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: addSmartAssetFee,
                                                                           addSmartAccountFee: addSmartAccountFee,
                                                                           minPriceStep: minPriceStep,
                                                                           fee: fee,
                                                                           pricePerTransfer: pricePerTransfer,
                                                                           pricePerKb: pricePerKb)

                    result[type] = newRule
                })


                let newDefaultRule = DomainLayer.DTO.TransactionFeeRules.Rule(addSmartAssetFee: deffault?.add_smart_asset_fee ?? false,
                                                                              addSmartAccountFee: deffault?.add_smart_account_fee ?? false,
                                                                              minPriceStep: deffault?.min_price_step ?? 0,
                                                                              fee: deffault?.fee ?? 0,
                                                                              pricePerTransfer: deffault?.price_per_transfer ?? 0,
                                                                              pricePerKb: deffault?.price_per_kb ?? 0)


                let newRules = DomainLayer.DTO.TransactionFeeRules(smartAssetExtraFee: txRules.smart_asset_extra_fee,
                                                                   smartAccountExtraFee: txRules.smart_account_extra_fee,
                                                                   defaultRule: newDefaultRule,
                                                                   rules: rules)

                return newRules
            })
    }
}



fileprivate extension TransactionSenderSpecifications {

    func broadcastSpecification(timestamp: Int64,
                                environment: Environment,
                                publicKey: String,
                                proofs: [String]) -> NodeService.Query.Broadcast {

        switch self {
            
        case .burn(let model):
            
            return .burn(NodeService.Query.Broadcast.Burn(version: self.version,
                                                    type: self.type.rawValue,
                                                    scheme: environment.scheme,
                                                    fee: model.fee,
                                                    assetId: model.assetID,
                                                    quantity: model.quantity,
                                                    timestamp: timestamp,
                                                    senderPublicKey: publicKey,
                                                    proofs: proofs))
            
        case .createAlias(let model):

            return .createAlias(NodeService.Query.Broadcast.Alias(version: self.version,
                                                            name: model.alias,
                                                            fee: model.fee,
                                                            timestamp: timestamp,
                                                            type: self.type.rawValue,
                                                            senderPublicKey: publicKey,
                                                            proofs: proofs))
        case .lease(let model):

            var recipient = ""
            if model.recipient.count <= WavesSDKCryptoConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            return .startLease(NodeService.Query.Broadcast.Lease(version: self.version,
                                                          scheme: environment.scheme,
                                                          fee: model.fee,
                                                          recipient: recipient,
                                                          amount: model.amount,
                                                          timestamp: timestamp,
                                                          type: self.type.rawValue,
                                                          senderPublicKey: publicKey,
                                                          proofs: proofs))
        case .cancelLease(let model):

            return .cancelLease(NodeService.Query.Broadcast.LeaseCancel(version: self.version,
                                                                 scheme: environment.scheme,
                                                                 fee: model.fee,
                                                                 leaseId: model.leaseId,
                                                                 timestamp: timestamp,
                                                                 type: self.type.rawValue,
                                                                 senderPublicKey: publicKey,
                                                                 proofs: proofs))

        case .data(let model):

            return .data(NodeService.Query.Broadcast.Data.init(type: self.type.rawValue,
                                                        version: self.version,
                                                        fee: model.fee,
                                                        timestamp: timestamp,
                                                        senderPublicKey: publicKey,
                                                        proofs: proofs,
                                                        data: model.dataForNode))
            
        case .send(let model):
            
            var recipient = ""
            if model.recipient.count <= WavesSDKCryptoConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            
            return .send(NodeService.Query.Broadcast.Send(type: self.type.rawValue,
                                                   version: self.version,
                                                   recipient: recipient,
                                                   assetId: model.assetId,
                                                   amount: model.amount,
                                                   fee: model.fee,
                                                   attachment: Base58.encode(Array(model.attachment.utf8)),
                                                   feeAssetId: model.getFeeAssetID,
                                                   feeAsset: model.getFeeAssetID,
                                                   timestamp: timestamp,
                                                   senderPublicKey: publicKey,
                                                   proofs: proofs))
        }

    }

    func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {

        switch self {

        case .data(let model):

            let bytes = TransactionSignatureV2.data(.init(fee: model.fee,
                                                          data: model.dataForSignature,
                                                          scheme: scheme,
                                                          senderPublicKey: Base58.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure
            
            return bytes

        case .burn(let model):
            
            let bytes = TransactionSignatureV2.burn(.init(assetID: model.assetID,
                                                          quantity: model.quantity,
                                                          fee: model.fee,
                                                          scheme: scheme,
                                                          senderPublicKey: Base58.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure

            return bytes

        case .cancelLease(let model):

            let bytes = TransactionSignatureV2.cancelLease(.init(leaseId: model.leaseId,
                                                                 fee: model.fee,
                                                                 scheme: scheme,
                                                                 senderPublicKey: Base58.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure
            
            return bytes
            

        case .createAlias(let model):
            
            let bytes = TransactionSignatureV2.createAlias(.init(alias: model.alias,
                                                                 fee: model.fee,
                                                                 scheme: scheme,
                                                                 senderPublicKey: Base58.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure
            
            return bytes
   
        case .lease(let model):
            
            let bytes = TransactionSignatureV2.startLease(.init(recipient: model.recipient,
                                                                amount: model.amount,
                                                                fee: model.fee,
                                                                scheme: scheme,
                                                                senderPublicKey: Base58.encode(publicKey),
                                                                timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .send(let model):
            
            let bytes = TransactionSignatureV2.transfer(.init(senderPublicKey: Base58.encode(publicKey),
                                                              recipient: model.recipient,
                                                              assetId: model.assetId,
                                                              amount: model.amount,
                                                              fee: model.fee,
                                                              attachment: model.attachment,
                                                              feeAssetID: model.feeAssetID,
                                                              scheme: scheme,
                                                              timestamp: timestamp))
                .bytesStructure

            return bytes
        }
    }
}

private extension SendTransactionSender {
   
    var getFeeAssetID: String {
        return feeAssetID == WavesSDKCryptoConstants.wavesAssetId ? "" : feeAssetID
    }
}

private extension DataTransactionSender {

    var dataForSignature: [TransactionSignatureV2.Structure.Data.Value] {
        return self.data.map({ (value) -> TransactionSignatureV2.Structure.Data.Value in
            
            var kind: TransactionSignatureV2.Structure.Data.Value.Kind!
            
            switch value.value {
            case .binary(let data):
                kind = .binary(data)
                
            case .integer(let number):
                kind = .integer(number)
                
            case .boolean(let flag):
                kind = .boolean(flag)
                
            case .string(let str):
                kind = .string(str)
            }
            
            return TransactionSignatureV2.Structure.Data.Value.init(key: value.key, value: kind)
            
        })
    }
    
    var dataForNode: [NodeService.Query.Broadcast.Data.Value] {
        return self.data.map { (value) -> NodeService.Query.Broadcast.Data.Value in

            var kind: NodeService.Query.Broadcast.Data.Value.Kind!

            switch value.value {
            case .binary(let data):
                kind = .binary(data.toBase64() ?? "")

            case .integer(let number):
                kind = .integer(number)

            case .boolean(let flag):
                kind = .boolean(flag)

            case .string(let str):
                kind = .string(str)
            }

            return NodeService.Query.Broadcast.Data.Value.init(key: value.key, value: kind)
        }
    }
}
