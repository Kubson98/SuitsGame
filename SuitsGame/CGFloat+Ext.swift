//
//  CGFloat+Ext.swift
//  SuitsGame
//
//  Created by Kuba on 01/09/2020.
//  Copyright © 2020 Kuba. All rights reserved.
//

import CoreGraphics

extension CGFloat {

    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }

}
