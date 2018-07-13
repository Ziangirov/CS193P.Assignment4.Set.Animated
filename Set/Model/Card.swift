//
//  Card.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 14/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import Foundation

struct Card {
    let number: Number
    let symbol: Symbol
    let color: Color
    let shade: Shade
    
    enum Number {
        case one, two, three
        static let all = [Number.one, .two, .three]
    }
    
    enum Symbol {
        case triangle, circle, square
        static let all = [Symbol.triangle, .circle, .square]
    }
    
    enum Color {
        case red, green, purple
        static let all = [Color.red, .green, .purple]
    }
    
    enum Shade {
        case striped, filled, outlined
        static let all = [Shade.striped, .filled, .outlined]
    }
}

extension Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return  lhs.number == rhs.number &&
            lhs.symbol == rhs.symbol &&
            lhs.color == rhs.color &&
            lhs.shade == rhs.shade
    }
}
