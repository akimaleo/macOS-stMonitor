//
//  InfoView.swift
//  stMonitor
//
//  Created by Yaroslav Movchan on 16.07.17.
//  Copyright © 2017 letit0or1. All rights reserved.
//

import Cocoa

class InfoView: NSView {
    
    @IBOutlet weak var cpuLabel: NSTextField!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    @IBAction func quitApp(_ sender: Any) {
        NSApp.terminate(self)
    }
    
}
