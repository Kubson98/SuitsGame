//
//  File.swift
//  SuitsGame
//
//  Created by Kuba on 30/08/2020.
//  Copyright © 2020 Kuba. All rights reserved.
//

import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}
