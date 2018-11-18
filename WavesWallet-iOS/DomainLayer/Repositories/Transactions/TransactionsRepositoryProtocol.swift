//
//  Transactions.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum TransactionsRepositoryError: Error {
    case fail
}

enum TransactionStatus: Int, Decodable {
    case activeNow
    case completed
    case unconfirmed
}

enum TransactionType: Int {
    case issue = 3
    case transfer = 4
    case reissue = 5
    case burn = 6
    case exchange = 7
    case lease = 8
    case leaseCancel = 9
    case alias = 10
    case massTransfer = 11
    case data = 12

    static var all: [TransactionType] {
        return [.issue,
                .transfer,
                .reissue,
                .burn,
                .exchange,
                .lease,
                .leaseCancel,
                .alias,
                .massTransfer,
                .data]
    }
}

struct TransactionsSpecifications {
    
    struct Page {
        let offset: Int
        let limit: Int
    }

    let page: Page?
    let assets: [String]
    let senders: [String]
    let types: [TransactionType]
}


struct AliasTransactionSender {
    let alias: String
    let fee: Int64
}

struct LeaseTransactionSender {
    let recipient: String
    let amount: Int64
    let fee: Int64
}


enum TransactionSenderSpecifications {
    case createAlias(AliasTransactionSender)
    case lease(LeaseTransactionSender)
}

struct AliasTransactionSpecifications {
    let fee: Int64
    let timestamp: Int64
    let alias: String
}

protocol TransactionsRepositoryProtocol {

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func newTransactions(by accountAddress: String,
                         specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]>

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> 
    
    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool>

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>
    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>
    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction>
}
