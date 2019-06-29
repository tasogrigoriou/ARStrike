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
}

class StartGameViewController: UIViewController {
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.dismiss(animated: true) {
                self.delegate?.startGame()
            }
        }
    }
}
