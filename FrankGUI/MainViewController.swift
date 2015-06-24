//
//  MainViewController.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 24/06/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import Cocoa

final class MainViewController : NSTabViewController
{
    private var settings: Settings?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        settings = nil
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
        settings = delegate.settings
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()

        switch settings!.tabChoice
        {
        case .Runner:
            selectedTabViewItemIndex = 0
        case .Settings:
            selectedTabViewItemIndex = tabViewItems.count - 1
        default:
            print("Wut?")
        }
        
        tabView.delegate = self
    }
    
    override func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?)
    {
        super.tabView(tabView, didSelectTabViewItem: tabViewItem)
        
        if tabView == self.tabView
        {
            let index = tabView.indexOfTabViewItem(tabViewItem!)
            if index == 0
            {
                settings!.tabChoice = .Runner
            }
            else if index == tabViewItems.count - 1
            {
                settings!.tabChoice = .Settings
            }
        }
    }
}
