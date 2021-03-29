//
//  MT1977Filter.swift
//  MetalFilters
//
//  Created by alexiscn on 2018/6/8.
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
