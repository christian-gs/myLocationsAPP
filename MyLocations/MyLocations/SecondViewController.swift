//
//  SecondViewController.swift
//  MyLocations
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        self.tabBarItem = UITabBarItem(title: "Second", image: #imageLiteral(resourceName: "second") , selectedImage: #imageLiteral(resourceName: "second"))
    }


}

