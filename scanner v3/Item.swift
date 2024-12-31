//
//  Item.swift
//  scanner v3
//
//  Created by andrew bell on 31/12/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
