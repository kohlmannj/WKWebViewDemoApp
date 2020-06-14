//
//  AdPlaceholderTrackerMessage.swift
//  WKWebViewDemoApp
//
//  Created by Joseph Kohlmann on 6/14/20.
//  Copyright © 2020 Joseph Kohlmann. All rights reserved.
//

enum AdPlaceholderTrackerMessageAction: String {
    case add = "add"
    case update = "update"
    case remove = "remove"
}

enum AdPlaceholderTrackerMessageError: Error {
    case invalidOrMissingId
    case invalidOrMissingAction
    case invalidRect
}

struct AdPlaceholderTrackerMessage {
    let id: String
    let action: AdPlaceholderTrackerMessageAction
    let rect: AdPlaceholderRect?

    init(json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw AdPlaceholderTrackerMessageError.invalidOrMissingId
        }
        self.id = id

        guard let action = AdPlaceholderTrackerMessageAction(rawValue: json["action"] as! String) else {
            throw AdPlaceholderTrackerMessageError.invalidOrMissingAction
        }
        self.action = action

        if let rawRect = json["rect"] as? [String: Double] {
            guard let width = rawRect["width"],
                let height = rawRect["height"],
                let x = rawRect["x"],
                let y = rawRect["y"]
            else {
                throw AdPlaceholderTrackerMessageError.invalidRect
            }
            rect = AdPlaceholderRect(width: width, height: height, x: x, y: y)
        } else {
            rect = nil
        }
    }
}
