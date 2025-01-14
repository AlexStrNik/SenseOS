//
//  main.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import Foundation
import AppKit

let app = NSApplication.shared
let delegate = SenseOSApp()

app.delegate = delegate
app.setActivationPolicy(.accessory)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
