//
//  MT1977Filter.swift
//  MetalFilters
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

import Foundation
import MetalPetal

class BlurFilter: MTFilter {

   override class var name: String {
        return "Blur"
    }

   override var borderName: String {
        return "filterBorderPlainWhite.png"
    }

   override var fragmentName: String {
        return "BlurFragment"
    }

   override var samplers: [String : String] {
        return [
            "map": "test2.png",
            "screen": "screen30.png",
        ]
    }

}
