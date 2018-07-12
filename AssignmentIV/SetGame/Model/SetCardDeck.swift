//
//  SetCardDeck.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 14/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import Foundation

struct SetCardDeck {
    private(set) var cards = [SetCard]()
    
    init() {
        for number in SetCard.Number.all {
            for symbol in SetCard.Symbol.all {
                for color in SetCard.Color.all {
                    for shade in SetCard.Shade.all {
                        cards.append(SetCard(number: number,
                                          symbol: symbol,
                                          color: color,
                                          shade: shade))
                    }
                }
            }
        }
        cards.shuffle()
    }
    
    mutating func deal() -> SetCard? {
        return cards.count > 0 ? cards.removeLast() : nil
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

private extension Array {
    mutating func shuffle() {
        for index in stride(from: count - 1, through: 1, by: -1) {
            let randomIndex = (index + 1).arc4random
            if index != randomIndex {
                self.swapAt(index, randomIndex)
            }
        }
    }
    
}
