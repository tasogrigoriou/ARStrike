//
//  EndGameViewController.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 12/12/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import UIKit

protocol EndGameDelegate: class {
    func resumeGame()
}

class EndGameViewController: UIViewController {
    
    @IBOutlet weak var endGameLabel: UILabel!
    
    let endGameData: EndGameData
    weak var delegate: EndGameDelegate?
    
    init(endGameData: EndGameData, delegate: EndGameDelegate?) {
        self.endGameData = endGameData
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.resumeGame()
        }
    }
    
    private func setupUI() {
        endGameLabel.text = "Game over! \nHighest level: \(endGameData.highestLevel) \nHighest score: \(Int(endGameData.highestScore))"
    }
}
