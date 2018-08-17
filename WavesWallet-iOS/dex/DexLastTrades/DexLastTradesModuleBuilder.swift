//
//  DexLastTradesModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexLastTradesModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        let vc = StoryboardScene.Dex.dexLastTradesViewController.instantiate()
        return vc
    }
}
