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
    func showMenu()
}

class EndGameViewController: UIViewController {
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
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
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.showMenu()
        }
    }
    private func setupUI() {
//        endGameLabel.text = ("Game over! \nHighest level: \(endGameData.highestLevel) \nHighest score: \(Int(endGameData.highestScore))")
        
        gameOverLabel.layer.shadowColor = UIColor.black.cgColor
        gameOverLabel.layer.shadowOpacity = 0.5
        gameOverLabel.layer.shadowOffset = .zero
        gameOverLabel.layer.shadowRadius = 0.5
        
        continueButton.layer.cornerRadius = 6
        continueButton.layer.borderWidth = 1
        continueButton.layer.borderColor = continueButton.backgroundColor?.cgColor
        
        continueButton.layer.shadowColor = UIColor.black.cgColor
        continueButton.layer.shadowOpacity = 1
        continueButton.layer.shadowOffset = .zero
        continueButton.layer.shadowRadius = 3
        
        menuButton.layer.cornerRadius = 6
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = menuButton.backgroundColor?.cgColor
        
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowOpacity = 1
        menuButton.layer.shadowOffset = .zero
        menuButton.layer.shadowRadius = 3
    }
}
