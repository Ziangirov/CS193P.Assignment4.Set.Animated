//
//  SetViewController.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 14/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    private var game = SetGame() {
        didSet {
            dealCardsButton.isEnabled = game.isCanDealCards
        }
    }
    
    private var tmpCards = [SetCardView]()
    
    private var dealCardViews: [SetCardView] {
        return  gameView.cardViews.filter { $0.alpha == 0 }
    }
    
    private var matchedCardViews: [SetCardView] {
        var matchedCardViews = [SetCardView]()
        if game.isSet == true {
            game.cardsSelected.forEach() { card in
                matchedCardViews.append(contentsOf:
                    gameView.cardViews.filter {
                        $0.number == card.number &&
                        $0.symbol == card.symbol &&
                        $0.color == card.color &&
                        $0.shade == card.shade
                    }
                )
            }
        }
        return matchedCardViews
    }
    
    private var deckCenter: CGPoint {
        return dealCardsButtonLabel.convert(dealCardsButtonLabel.center, to: gameView)
    }
    private var discardPileCenter: CGPoint {
        return dealCardsButtonLabel.convert(setCountLabel.center, to: gameView)
    }
    
    private lazy var cardBehavior = SetCardBehavior(in: animator)
    
    private lazy var animator : UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.gameView)
        animator.delegate = self
        return animator
    }()
    
    @IBOutlet weak private var scoreLabel: UILabel!
    @IBOutlet weak private var dealCardsButtonLabel: UILabel!
    @IBOutlet weak private var setCountLabel: UILabel!
    
    @IBOutlet weak private var dealCardsButton: UIButton!
    
    @IBOutlet weak private var controlPanelStackView: UIStackView!
    
    @IBOutlet weak var gameView: SetGameView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealThreeOnTable))
            let rotation = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle))
            
            swipe.direction = .up
            gameView.addGestureRecognizer(swipe)
            gameView.addGestureRecognizer(rotation)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardBehavior.snapPoint = discardPileCenter
    }
    
    private func updateView() {
        updateViewFromModel()
        updateLabels()
    }
    
    private func updateLabels() {
        dealCardsButton.setTitle("Deck: \(game.deckCount)", for: .normal)
        setCountLabel.text = "Sets: \(game.cardsSets.count)"
        scoreLabel.text = "Score: \(game.score)"
        
        if game.isFinished() {
            switch game.deckCount {
            case 0:
                scoreLabel.layer.borderWidth = SetCardView.Constants.borderWidth
                scoreLabel.layer.borderColor = UIColor.orange.cgColor
                
                gameView.subviews.forEach { $0.removeFromSuperview() }
            default:
                dealCardsButton.layer.borderWidth = SetCardView.Constants.borderWidth
                dealCardsButton.layer.borderColor = UIColor.green.cgColor
            }
        } else {
            scoreLabel.layer.borderColor = UIColor.white
                .withAlphaComponent(0).cgColor
            dealCardsButton.layer.borderColor = UIColor.white
                .withAlphaComponent(0).cgColor
        }
    }

    private func updateViewFromModel() {
        var  newCardViews = [SetCardView]()
        
        if gameView.cardViews.count - game.cardsOnTable.count > 0 {
            gameView.removeCardViews(matchedCardViews)
        }
        
        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            if index > gameView.cardViews.count - 1 {
                let cardView = SetCardView()
                updateCardView(cardView, for: card)
                cardView.alpha = 0
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapCard(_:)))
                cardView.addGestureRecognizer(tap)
                newCardViews.append(cardView)
            } else {
                let cardView = gameView.cardViews[index]
                if cardView.alpha != 0 && cardView.alpha != 1 && game.isSet != true {
                    cardView.alpha = 0
                }
                updateCardView(cardView, for: card)
            }
        }
        
        gameView.addCardViews(newCardViews)
        
        flyAwayAnimation()
        dealAnimation()
        
        if gameView.cardViews.count > SetGame.CardsCountAt.start {
            gameView.removeCardViews(matchedCardViews)
        }
    }
    
    private func updateCardView(_ cardView: SetCardView, for card: SetCard) {
        cardView.number =  card.number
        cardView.symbol = card.symbol
        cardView.color = card.color
        cardView.shade =  card.shade
        
        if game.cardsSelected.contains(card) {
            cardView.state = .selected
        } else {
            cardView.state = .unselected
            if game.cardsHints.contains(card) {
                cardView.state = .hinted
            }
        }
    }
    
    private func dealAnimation() {
        let timeInterval = Double(gameView.rows + 1) * 0.15
        var currentDealCard = 0
        
        dealCardViews.forEach() { $0.alpha = 0 }
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { timer in
            self.dealCardViews.forEach {
                $0.animateDealFrom(self.deckCenter, with: Double(currentDealCard) * 0.25)
                currentDealCard += 1
            }
        }
    }
    
    private func flyAwayAnimation() {
        if  game.isSet == true {
            self.dealCardsButton.isUserInteractionEnabled = false
            tmpCards.forEach { $0.removeFromSuperview() }
            tmpCards.removeAll()
            
            matchedCardViews.forEach {
                $0.alpha = 0.001
                tmpCards.append($0.copyCardView())
            }
            
            tmpCards.forEach {
                gameView.addSubview($0)
                cardBehavior.addItem($0)
            }
        }
    }

    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        tmpCards.forEach { tmpCard in
            UIView.transition(
                with: tmpCard,
                duration: 0.75,
                options: [.transitionFlipFromLeft,
                          .preferredFramesPerSecond60],
                animations: {
                    tmpCard.isFaceUp = false
                    tmpCard.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi * 2)
                    tmpCard.bounds = CGRect(x: 0.0, y: 0.0,
                                            width: tmpCard.bounds.width * 0.6,
                                            height: tmpCard.bounds.height * 0.6)
            },
                completion: { finished in
                    self.cardBehavior.removeItem(tmpCard)
                    tmpCard.removeFromSuperview()
                    self.tmpCards = self.tmpCards.filter { $0 != tmpCard }
            })
        }
    }
}

    //MARK: Actions
private extension SetViewController {
    @objc private func dealThreeOnTable() {
        game.dealThreeOnTable()
        updateView()
    }
    
    @objc private func reshuffle() {
        game.reshuffle()
        updateView()
    }
    
    @objc private func tapCard(_ sender: UITapGestureRecognizer) {
        guard let tappedCard = sender.view as? SetCardView else { return }
        switch sender.state {
        case .ended:
            game.chooseCard(at: gameView.cardViews.index(of: tappedCard)! )
            dealCardsButton.isUserInteractionEnabled = true
        default:
            break
        }
        updateView()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        gameView.reset()
        game.reset()
        updateView()
    }
    
    @IBAction func hintButton(_ sender: UIButton) {
        game.hint()
        updateView()
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
        dealThreeOnTable()
    }
}
