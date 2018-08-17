//
//  DexTraderContainerModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexTraderContainerModuleBuilder: ModuleBuilder {
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        let vc = StoryboardScene.Dex.dexTraderContainerViewController.instantiate()
        vc.pair = input
        return vc
    }
}


