//
//  LoanMasterDetailSplitVC.swift
//  Lendr
//
//  Created by Keith Tan on 15/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit

class LoanMasterDetailSplitVC: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
