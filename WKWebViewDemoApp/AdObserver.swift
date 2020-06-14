//
//  AdObserver.swift
//  WKWebViewDemoApp
//
//  Created by Joseph Kohlmann on 6/14/20.
//  Copyright © 2020 Joseph Kohlmann. All rights reserved.
//

import UIKit

func toCGRect(_ position: AdPlaceholderRect) -> CGRect {
    return CGRect(x: CGFloat(position.x), y: CGFloat(position.y), width: CGFloat(position.width), height: CGFloat(position.height))
}

class AdObserver {
    let id: String
    var parent: UIView
    var adView: UIView

    init(id: String, rect: AdPlaceholderRect, parent: UIView) {
        self.id = id
        self.parent = parent
        self.adView = UIView()
        self.buildAdView()
        self.update(rect)
        self.parent.addSubview(self.adView)
    }

    deinit {
        print("AdObserver.deinit()")
        self.parent.willRemoveSubview(self.adView)
        self.adView.removeFromSuperview()
    }

    func update(_ rect: AdPlaceholderRect) -> Void {
        self.adView.frame = toCGRect(rect)
    }

    private func buildAdView() -> Void {
        adView.backgroundColor = .green
        let label = UILabel()
        label.text = self.id
        label.drawText(in: adView.bounds)
    }
}
