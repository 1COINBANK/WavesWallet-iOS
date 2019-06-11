//
//  AddressRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK

final class AddressRepositoryRemote: AddressRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func isSmartAddress(accountAddress: String) -> Observable<Bool> {
        
        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ [weak self] (servicesEnvironment) -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                return servicesEnvironment
                    .wavesServices
                    .nodeServices
                    .addressesNodeService
                    .scriptInfo(address: accountAddress)
                    .map { ($0.extraFee ?? 0) > 0 }
            })
    }
}
