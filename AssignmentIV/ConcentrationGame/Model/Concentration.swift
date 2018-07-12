//
//  Concentration.swift
//  Concentration
//
//  Created by Evgeniy Ziangirov on 28/05/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import Foundation

struct Concentration {
    
    private struct Points {
        static let bonus = 20
        static let penalty = -10
        static let maxTimePenalty = 10
        
        static var dateOfClick: Date?
        static var timePenalty: Int { return min(dateOfClick?.sinceNow ?? 0, maxTimePenalty) }
    }
    
    private var seenCards = [Int]()
    private(set) var cards = [ConcentrationCard]()
    private(set) var score = 0
    private(set) var flipCount = 0
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set { for index in cards.indices {
            cards[index].isFaceUp = (index == newValue) }
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        if !cards[index].isMatched {
            flipCount += 1
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // check if cards match
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    
                    score += Points.bonus
                } else {
                    if seenCards.contains(index) {
                        score += Points.penalty
                    }
                    if seenCards.contains(matchIndex) {
                        score += Points.penalty
                    }
                    seenCards.append(index)
                    seenCards.append(matchIndex)
                }
                cards[index].isFaceUp = true
                score -= Points.timePenalty
            } else {
                // either no card or 2 cards are face up
                indexOfOneAndOnlyFaceUpCard = index
            }
            Points.dateOfClick = Date()
        }
    }
    
    mutating func reset() {
        score = 0
        flipCount = 0
        seenCards = [Int]()
        for index in cards.indices {
            cards[index].isFaceUp = false
            cards[index].isMatched = false
        }
        cards.shuffle()
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have at least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
            let card = ConcentrationCard()
            cards += [card, card]
        }
        // TODO: Shuffle the cards
        cards.shuffle()
    }
}
extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}

//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Shuffle
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

extension Date {
    var sinceNow: Int {
        return -Int(self.timeIntervalSinceNow)
    }
    
}
