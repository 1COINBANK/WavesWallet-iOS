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

fileprivate enum Constants {
    static let maxLimit: Int = 10000
}

extension TransactionSenderSpecifications {

    var version: Int {
        switch self {
        case .createAlias:
            return 2
        }
    }

    var type: TransactionType {
        switch self {
        case .createAlias:
            return TransactionType.alias
        }
    }
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {

    private let transactions: MoyaProvider<Node.Service.Transaction> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }

                let limit = min(Constants.maxLimit, offset + limit)

                return owner
                    .transactions
                    .rx
                    .request(.init(kind: .list(accountAddress: accountAddress,
                                               limit: limit),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map(Node.DTO.TransactionContainers.self)
            .map { $0.anyTransactions() }
            .asObservable()        
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .leasingProvider
                    .rx
                    .request(.init(kind: .getActive(accountAddress: accountAddress),
                                   environment: environment),
                                   callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map([Node.DTO.LeaseTransaction].self)
            .map { $0.map { DomainLayer.DTO.LeaseTransaction(transaction: $0) } }
            .asObservable()
    }

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction> {

        return environmentRepository
            .accountEnvironment(accountAddress: wallet.wallet.address)
            .flatMap { [weak self] environment -> Single<Response> in

                let timestamp = Int64(Date().millisecondsSince1970)
                var signature = specifications.signature(timestamp: timestamp,
                                                         scheme: environment.scheme,
                                                         publicKey: wallet.publicKey.publicKey)

                do {
                    signature = try wallet.sign(input: signature, kind: [.none])
                } catch let e {
                    error(e)
                    return Single.error(LeasingTransactionRepositoryError.fail)
                }

                let proofs = [Base58.encode(signature)]

                let broadcastSpecification = specifications.broadcastSpecification(timestamp: timestamp,
                                                                                   publicKey: wallet.publicKey.getPublicKeyStr(),
                                                                                   proofs: proofs)

                guard let owner = self else { return Single.never() }
                return owner
                    .transactions
                    .rx
                    .request(.init(kind: .broadcast(broadcastSpecification),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map(Node.DTO.Transaction.self)
            .map({ $0.anyTransaction })
            .asObservable()
    }

    func transactions(by accountAddress: String,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransaction(by id: String, accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by ids: [String], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}

fileprivate extension TransactionSenderSpecifications {

    func broadcastSpecification(timestamp: Int64, publicKey: String, proofs: [String]) -> Node.Service.Transaction.BroadcastSpecification {

        switch self {
        case .createAlias(let model):

            return .createAlias(Node.Service.Transaction.Alias(version: self.version,
                                                               name: model.alias,
                                                               fee: model.fee,
                                                               timestamp: timestamp,
                                                               type: self.type.rawValue,
                                                               senderPublicKey: publicKey,
                                                               proofs: proofs))

        default:
            break
        }

    }

    func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {

        switch self {
        case .createAlias(let model):

            var alias: [UInt8] = toByteArray(Int8(self.version))
            alias += scheme.utf8
            alias += model.alias.arrayWithSize()

            var signature: [UInt8] = []
            signature += toByteArray(Int8(self.type.rawValue))
            signature += toByteArray(Int8(self.version))
            signature += publicKey

            signature += alias.arrayWithSize()
            signature += toByteArray(model.fee)
            signature += toByteArray(timestamp)
            return signature

        default:
            break
        }

    }
}

