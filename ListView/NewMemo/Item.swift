//
//  Item.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/06.
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
