//
//  ViewController.swift
//  Concentration
//
//  Created by Evgeniy Ziangirov on 26/05/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

class  ConcentrationViewController: UIViewController {
    
    var numberOfPairsOfCards: Int { return (visibleCardButtons.count + 1) / 2 }
    
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    var theme: Theme? {
        didSet {
            if let theme = theme {
            emojiChoices = theme.emojies
            cardColor = theme.cardColor
            emoji = [:]
            view.backgroundColor = theme.viewColor
            newGameButton.setTitleColor(cardColor, for: UIControl.State.normal)
            
            }
            updateViewFromModel()
        }
    }
    private var emojiChoices = "😃🤣😇😍🤬😎😱😡😈☠️"
    private var cardColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    
    private var emoji = [ConcentrationCard: String]()
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private weak var scoreCountLabel: UILabel!

    @IBOutlet private var cardButtons: [UIButton]!
    
    private var visibleCardButtons: [UIButton]! {
        return cardButtons?.filter { !$0.superview!.isHidden}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewFromModel()
    }
  
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = visibleCardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in visibleCardButtons")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        updateViewFromModel()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        game.reset()
        updateViewFromModel()
    }
    
    private func updateLabels() {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strokeWidth: 5.0,
                                                        NSAttributedString.Key.strokeColor: cardColor]

        let attributedFlipCountString = NSAttributedString(string: "Flips: \(game.flipCount)", attributes: attributes)
        let attributedScoreCountString = NSAttributedString(string: "Score: \(game.score)", attributes: attributes)
        
        flipCountLabel.attributedText = attributedFlipCountString
        scoreCountLabel.attributedText = attributedScoreCountString
    }

    private func updateViewFromModel(){
        if visibleCardButtons != nil {
            for index in visibleCardButtons.indices {
                let button = visibleCardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    button.setTitle(emoji(for: card), for: UIControl.State.normal)
                    button.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                } else {
                    button.setTitle("", for: UIControl.State.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : cardColor
                }
            }
            updateLabels()
        }
    }
    
//    private func setRandomTheme() {
//        emoji = [Card: String]()
//        let randomIndex = themes.count.arc4random
//        emojiChoices = themes[randomIndex].emojies
//        cardColor = themes[randomIndex].cardColor
//
//        view.backgroundColor = themes[randomIndex].viewColor
//        newGameButton.setTitleColor(cardColor, for: .normal)
//    }

    private func emoji(for card: ConcentrationCard) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
}


