//
//  DOMRectData.swift
//  WKWebViewDemoApp
//
//  Created by Joseph Kohlmann on 6/14/20.
//  Copyright © 2020 Joseph Kohlmann. All rights reserved.
//

struct AdPlaceholderRect {
    let width: Double
    let height: Double
    /*left, right, top, bottom,*/
    let x: Double
    let y: Double

    init(width: Double = 0, height: Double = 0, x: Double = 0, y: Double = 0) {
        self.width = width
        self.height = height
        self.x = x
        self.y = y
    }
}
