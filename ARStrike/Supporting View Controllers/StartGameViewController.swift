//
//  StartGameViewController.swift
//  ARStrike
//
//  Created by Anastasios Grigoriou on 6/28/19.
//  Copyright © 2019 Taso Grigoriou. All rights reserved.
//

import UIKit

protocol StartGameDelegate: class {
    func startGame()
    func resumeGame(fromLevel: Int)
}

class StartGameViewController: UIViewController {
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fromLevelLabel: UILabel!
    
    @IBOutlet weak var audioButton: UIButton!
    
    private var highestLevel: Int {
        return GameLevel.shared.getHighestLevel()
    }
    
    weak var delegate: StartGameDelegate?
    
    init(delegate: StartGameDelegate?) {
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
    
    private func setupUI() {
        resumeButton.layer.cornerRadius = 6
        resumeButton.layer.borderWidth = 1
        resumeButton.layer.borderColor = resumeButton.backgroundColor?.cgColor
        
        startButton.layer.cornerRadius = 6
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = startButton.backgroundColor?.cgColor
        
        fromLevelLabel.text = "From Level \(highestLevel)"
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.startGame()
        }
    }
    
    @IBAction func resumeButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.resumeGame(fromLevel: self.highestLevel)
        }
    }
}
