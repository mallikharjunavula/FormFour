//
//  AppCoordinator.swift
//  FormFour
//
//  Created by Mallikharjuna avula on 28/11/19.
//  Copyright © 2019 Mallikharjuna avula. All rights reserved.
//

import Foundation
import UIKit

protocol coordinator:class{
    func start()
}

protocol loadGame:class{
    func dismissVC(rows: Int, columns: Int)
}

protocol restartGame: class{
    func restart()
}

class AppCoordinator: NSObject, coordinator, UITabBarControllerDelegate, loadGame, restartGame{
    
    let rootController: UITabBarController
    let window: UIWindow
    let storyBoard: UIStoryboard
    var presentVc: ViewController?
    var first = true
    
    init(window: UIWindow) {
        rootController = UITabBarController()
        storyBoard = UIStoryboard(name: "Main", bundle: nil)
        self.window = window
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
    
    func start() {
        rootController.delegate = self

        let VC = storyBoard.instantiateViewController(withIdentifier: "MainVc") as! ViewController
        VC.tabBarItem = UITabBarItem(title: "1 VS 1", image: nil, tag: 0)
        VC.startGame = self
        presentVc = VC
        
        let VC1 = storyBoard.instantiateViewController(withIdentifier: "MainVc") as! ViewController
        VC1.tabBarItem = UITabBarItem(title: "1 VS comp", image: nil, tag: 0)
        VC1.startGame = self
    
        rootController.viewControllers = [VC,VC1]
    }
    
    func dismissVC(rows: Int,columns: Int) {
        let VC = first == true ? rootController.viewControllers?.first! as! ViewController : rootController.viewControllers?.last! as! ViewController
        VC.dismiss(animated: true){
            VC.gameView.restartGame = self
            VC.view.alpha = 1.0
            VC.gameView.columns = columns
            VC.gameView.rows = rows
            VC.gameView.setNeedsDisplay()
        }
    }
    
    func restart() {
        let popUpVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpVc") as! popUpViewController
        popUpVc.modalTransitionStyle = .flipHorizontal
        popUpVc.modalPresentationStyle = .overCurrentContext
        let VC = first == true ? rootController.viewControllers?.first! as! ViewController : rootController.viewControllers?.last! as! ViewController
        VC.definesPresentationContext = true
        VC.modalPresentationStyle = .overCurrentContext
        popUpVc.delegate = self
        VC.view.alpha = 0.6
        VC.present(popUpVc, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let VC = first == true ? rootController.viewControllers?.first! as! ViewController : rootController.viewControllers?.last! as! ViewController
        VC.dismiss(animated: true)
        first = first == true ? false : true
    }
}
