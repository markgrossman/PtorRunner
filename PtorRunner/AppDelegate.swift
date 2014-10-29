//
//  AppDelegate.swift
//  PtorRunner
//
//  Created by Mark Grossman on 10/17/14.
//  Copyright (c) 2014 Mark Grossman. All rights reserved.
//

import Cocoa
import Foundation
    
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var PtorFolderLocation: NSTextField!

    @IBOutlet weak var browserSelection: NSMatrix!
    
    @IBOutlet weak var SaveButton: NSButton!
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()


    @IBAction func SaveFolderLocation(sender: AnyObject) {
        if(PtorFolderLocation.stringValue.substringToIndex(advance(PtorFolderLocation.stringValue.startIndex, 1)) != "/"){
            PtorFolderLocation.stringValue = "/" + PtorFolderLocation.stringValue
        }
        
        NSUserDefaults.standardUserDefaults().setObject("\(PtorFolderLocation.stringValue)", forKey:"FolderLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.window!.close()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        PtorFolderLocation.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("FolderLocation")!
        }
    
    func runTests(sender: AnyObject) {
        var browserFlag = "--browser=chrome"
        
        if(browserSelection.selectedTag() == 2){
            browserFlag = "--browser=firefox"
        }
        var protractorFolderLocation = NSUserDefaults.standardUserDefaults().stringForKey("FolderLocation")!
        
        let launchPath = "/usr/local/bin/node"
        let arguments = ["\(protractorFolderLocation)/node_modules/protractor/bin/protractor", browserFlag, "\(protractorFolderLocation)/protractor.conf.js"]
        
        let (output, exitStatus) = runTask(launchPath, arguments: arguments)
        handleResults()
    }
    
    func handleResults() {
        
        var protractorFolderLocation = NSUserDefaults.standardUserDefaults().stringForKey("FolderLocation")!
        var resultsLocation = protractorFolderLocation + "/results"
        
        var collaborationResult =  protractorFolderLocation + "/TEST-Collaboration.xml"
        var framesetResult = protractorFolderLocation + "/TEST-StandardChatView.xml"
        
        if(checkForFailure(collaborationResult) || checkForFailure(framesetResult)){
            statusBarItem.image = NSImage(named: "Red@2x.png")
        } else {
            statusBarItem.image = NSImage(named: "Green@2x.png")
        }

    }
    
    func checkForFailure(location: NSString) -> Bool {
        var error: NSError?
        let content = NSData(contentsOfFile:location, options: nil, error: nil)
        
        if let xmlDoc = AEXMLDocument(data: content, error: &error) {
            
            if (xmlDoc["testsuites"]["testsuite"].attributes["failures"] as String != "0") {
                return true
            }
        } else {
            println("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
        }
        return false
    }
    
    
    func runTask(launchPath: NSString, arguments: NSArray) -> (output: String, exitStatus: Int) {
        var error: NSError?
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        let stdout = NSPipe()
        task.standardOutput = stdout
        
        task.launch()
        task.waitUntilExit()
        
        let outData = stdout.fileHandleForReading.readDataToEndOfFile()
        
        let outStr = NSString(data: outData, encoding: NSUTF8StringEncoding)
        return (outStr!, Int(task.terminationStatus))
    }
    
    
    override func awakeFromNib() {
        buildMenu()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func showSettings(sender: AnyObject){
        self.window!.orderFront(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func showResults(sender: AnyObject){
        var protractorFolderLocation = NSUserDefaults.standardUserDefaults().stringForKey("FolderLocation")!
        let launchPath = "/usr/bin/open"
        let arguments = [protractorFolderLocation + "/TEST-StandardChatView.xml", protractorFolderLocation + "/TEST-Collaboration.xml"]
        let (output, exitStatus) = runTask(launchPath, arguments: arguments)
    }
    
    func quitApp(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func buildMenu() {
        var quitAppMenuItem: NSMenuItem = NSMenuItem()
        var runTestsMenuItem : NSMenuItem = NSMenuItem()
        var showSettingsMenuItem: NSMenuItem = NSMenuItem()
        var showResultsMenuItem: NSMenuItem = NSMenuItem()
        
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.image = NSImage(named: "Green@2x.png")
        
        //Add menuItem to menu
        runTestsMenuItem.title = "Run Tests"
        runTestsMenuItem.action = Selector("runTests:")
        runTestsMenuItem.keyEquivalent = ""
        menu.addItem(runTestsMenuItem)
        
        showSettingsMenuItem.title = "Settings"
        showSettingsMenuItem.action = Selector("showSettings:")
        menu.addItem(showSettingsMenuItem)
        
        showResultsMenuItem.title = "Results"
        showResultsMenuItem.action = Selector("showResults:")
        menu.addItem(showResultsMenuItem)
        
        quitAppMenuItem.title = "Quit"
        quitAppMenuItem.action = Selector("quitApp:")
        menu.addItem(quitAppMenuItem)
    }

}

