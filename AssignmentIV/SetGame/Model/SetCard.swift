//
//  SetCard.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 14/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import Foundation

struct SetCard: CustomStringConvertible {
    let number: Number
    let symbol: Symbol
    let color: Color
    let shade: Shade
    
    enum Number: Int {
        case one, two, three
        var description: String { return String(rawValue) }
        static let all = [Number.one, .two, .three]
    }
    
    enum Symbol: Int {
        case triangle, circle, square
        var description: String { return String(rawValue) }
        static let all = [Symbol.triangle, .circle, .square]
    }
    
    enum Color: Int {
        case red, green, purple
        var description: String { return String(rawValue) }
        static let all = [Color.red, .green, .purple]
    }
    
    enum Shade: Int {
        case striped, filled, outlined
        var description: String { return String(rawValue) }
        static let all = [Shade.striped, .filled, .outlined]
    }
}

extension SetCard: Equatable {
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return  lhs.number == rhs.number &&
            lhs.symbol == rhs.symbol &&
            lhs.color == rhs.color &&
            lhs.shade == rhs.shade
    }
}

extension SetCard {
    var description: String {
        return "\(number.rawValue) \(symbol.rawValue) \(shade.rawValue) \(color.rawValue)\n"
    }
}
