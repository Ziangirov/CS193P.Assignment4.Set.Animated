//
//  GameView.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 23/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

class GameView: UIView {
    var cardViews = [CardView]()
    
    private var grid: Grid?
    
    var rows: Int { return grid?.dimensions.rowCount ?? 0 }
    private var columns: Int { return grid?.dimensions.columnCount ?? 0 }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        grid = Grid(layout: Grid.Layout.aspectRatio(Cell.aspectRatio), frame: bounds)
        grid?.cellCount = cardViews.count
        layoutSetCards()
    }
    
    private func layoutSetCards() {
        if let grid = grid {
            for row in 0..<rows {
                for column in 0..<columns {
                    if cardViews.count > (row * columns + column) {
                        UIViewPropertyAnimator
                            .runningPropertyAnimator(
                                withDuration: 0.25,
                                delay: Double(row) * 0.1,
                                options: [.curveEaseInOut,
                                          .preferredFramesPerSecond60],
                                animations: { [unowned self] in
                                    self.cardViews[row * self.columns + column].frame =
                                        grid[row,column]!.insetBy(dx: Cell.spacing, dy: Cell.spacing)
                            })
                    }
                }
            }
        }
    }
    
    func addCardViews(_ newCardViews: [CardView]) {
        newCardViews.forEach {
            cardViews.append($0)
            addSubview($0)
            sendSubviewToBack($0)
        }
        layoutIfNeeded()
    }
    
    func removeCardViews(_ removedCardViews: [CardView]) {
        removedCardViews.forEach { cardView in
            cardViews = cardViews.filter { $0 != cardView }
            cardView.removeFromSuperview()
        }
        layoutIfNeeded()
    }
    
    func reset() {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        layoutIfNeeded()
    }
}

fileprivate struct Cell {
    static let aspectRatio: CGFloat = 8 / 5
    static let spacing: CGFloat = 3.0
}
