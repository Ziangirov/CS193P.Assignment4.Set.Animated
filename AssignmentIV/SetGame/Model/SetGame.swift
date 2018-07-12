//
//  SetGame.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 14/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import Foundation

struct SetGame {
    
    private var deck = SetCardDeck()
    
    private(set) var score = 0
    
    private(set) var cardsOnTable = [SetCard]()
    private(set) var cardsSelected = [SetCard]()
    private(set) var cardsSets = [[SetCard]]()
    
    private(set) lazy var cardsHints = [SetCard]()
    
    private(set) var isSet: Bool? {
        get {
            guard cardsSelected.count == CardsCountAt.set else { return nil }
            return cardsSelected.isSet()
        }
        set {
            if newValue != nil {
                switch newValue! {
                case true:
                    cardsSets.append(cardsSelected)
                    replaceOrRemoveCard()
                    score += Score.bonus.rawValue
                case false:
                    score += Score.penalty.rawValue
                }
                cardsSelected.removeAll()
            }
        }
    }
    
    var deckCount: Int { return deck.cards.count }
    var isCanDealCards: Bool { return deckCount == 0 ? false : true }
    
    mutating func chooseCard(at index: Int) {
        assert(cardsOnTable.indices.contains(index), "Set.chooseCard(at: \(index)): chosen index not in the cards")
        
        isSet = isSet
        
        let chosenCard = cardsOnTable[index]
        if cardsSelected.contains(chosenCard) {
            cardsSelected = cardsSelected.filter() { $0 != chosenCard }
            return
        }
        cardsSelected.append(chosenCard)
    }
    
    private mutating func replaceOrRemoveCard() {
        for cardSelected in cardsSelected {
            let indexForChange = cardsOnTable.index(of: cardSelected)
            
            if cardsOnTable.count <= CardsCountAt.start, let card = deck.deal() {
                if let index = indexForChange {
                cardsOnTable[index] = card
                }
            } else {
                if let index = indexForChange {
                    cardsOnTable.remove(at: index)
                }
            }
        }
        cardsSelected.removeAll()
    }
    
    mutating func hint() {
        cardsSelected.removeAll()
        score += Score.hint.rawValue
        cardsHints = cardsOnTable.thripletFor() { $0.isSet() }
    }
    
    mutating func reshuffle() {
        cardsOnTable.shuffle()
    }
    
    mutating func dealThreeOnTable() {
        repeatBy(CardsCountAt.deal) { deal() }
    }
    
    mutating func isFinished() -> Bool {
        return cardsOnTable.thripletFor() { $0.isSet() }.isEmpty
    }
    
    mutating func reset() {
        self = SetGame()
    }
    
    init() {
        repeatBy(CardsCountAt.start) { deal() }
    }
}

extension SetGame {
    struct CardsCountAt {
        static let start = 12
        static let deal = 3
        static let set = 3
    }
    
    private enum Score: Int {
        case bonus = 3, penalty = -5, hint = -2
    }
    
    private mutating func deal() {
        if let card = deck.deal() {
            cardsOnTable.append(card)
        }
    }
    
    private func repeatBy(_ repeatingCount: Int, foo: ()->()) {
        guard repeatingCount > 0 else { return }
        for _ in 1...repeatingCount { foo() }
    }
}

private extension Array where Element == SetCard {
    func isSet() -> Bool {
        let validValues = Set([1, 3])
        
        let number  = Set(self.map { $0.number } )
        let symbol  = Set(self.map { $0.symbol } )
        let color   = Set(self.map { $0.color } )
        let shade   = Set(self.map { $0.shade } )
        
        return  validValues.contains(number.count) &&
                validValues.contains(symbol.count) &&
                validValues.contains(color.count) &&
                validValues.contains(shade.count)
    }
}

private extension Array where Element: Equatable {
    func thripletFor(_ closure: (_ check: [Element]) -> (Bool)) -> [Element] {
        if self.count >= 3 {
            for i in 0..<self.count {
                for j in (i + 1)..<self.count {
                    for k in (j + 1)..<self.count {
                        let result = [self[i], self[j], self[k]]
                        if closure(result) {
                            return result
                        }
                    }
                }
            }
        }
        return []
    }
}
