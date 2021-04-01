/*
Copyright © 2021 Insoft. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainMenu: NSMenu!
   
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        updateAllMenus()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Private Action Methods
    
    @IBAction private func zoomIn(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            if image.xScale < 8.0 {
                image.setScale(image.xScale + 1.0)
            }
        }
    }
    
    @IBAction private func zoomOut(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            if image.xScale > 1.0 {
                image.setScale(image.xScale - 1.0)
            }
        }
    }
    
    @IBAction private func firstPalette(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.firstAtariSTPalette()
    }
    
    @IBAction private func nextPalette(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.nextAtariSTPalette()
    }
    
    @IBAction private func planeCount(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.setPlaneCount(UInt32(sender.tag))
        updateAllMenus()
    }
    
    @IBAction private func bitsPerPlane(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.setBitsPerPixel(UInt32(sender.tag))
        updateAllMenus()
    }
    
    @IBAction private func platform(_ sender: NSMenuItem) {
        // NOTE: bitsPerPixel is regarded as bitsPerPlane when planeCount is not zero!
        
        if let image = Singleton.sharedInstance()?.image {
            switch sender.tag {
            case 0: // ZX Spectrum
                image.setSize(CGSize(width: 256, height: 192))
                image.setBitsPerPixel(8)
                image.setPlaneCount(1)
                image.alphaPlane = false
                
            case 8:
                image.setSize(CGSize(width: 256, height: 192))
                image.setBitsPerPixel(8)
                image.setPlaneCount(0)
                image.alphaPlane = false
                
            case 1: // Atari ST Low Resolution
                image.setSize(CGSize(width: 320, height: 200))
                image.setBitsPerPixel(16)
                image.setPlaneCount(4)
                image.alphaPlane = false
            
            case 2: // Atari ST Medium Resolution
                image.setSize(CGSize(width: 640, height: 200))
                image.setBitsPerPixel(16)
                image.setPlaneCount(2)
                image.alphaPlane = false
                
            case 3: // Atari ST Heigh Resolution
                image.setSize(CGSize(width: 640, height: 400))
                image.setBitsPerPixel(16)
                image.setPlaneCount(1)
                image.alphaPlane = false
                
            default: break
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction private func loadPalette(_ sender: NSMenuItem) {
        if let palette = Singleton.sharedInstance()?.image.palette {
            if let filePath = Bundle.main.path(forResource: sender.title, ofType: "act") {
                palette.load(withContentsOfFile: filePath)
            }
        }
    }
    
    @IBAction private func increaseWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            var size = image.size;
            size.width += CGFloat(image.bitsPerPixel)
            image.setSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func decreaseWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            var size = image.size;
            size.width -= CGFloat(image.bitsPerPixel)
            image.setSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func increaseHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            var size = image.size;
            size.height += 1.0
            image.setSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func decreaseHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            var size = image.size;
            size.height -= 1.0
            image.setSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func openDocument(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "GraphicX"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        
        let modalresponse = openPanel.runModal()
        if modalresponse == .OK {
            if let url = openPanel.url {
                Singleton.sharedInstance()?.image.modify(withContentsOf: url)
                NSApp.windows.first?.title = url.deletingPathExtension().lastPathComponent
                Singleton.sharedInstance()?.mainScene.checkForKnownFormats()
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction private func importPalette(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "GraphicX"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        
        let modalresponse = openPanel.runModal()
        if modalresponse == .OK {
            if let url = openPanel.url {
                Singleton.sharedInstance()?.image.palette.load(withContentsOfFile: url.path)
            }
        }
    }
    
    @IBAction private func saveAs(_ sender: NSMenuItem) {
        let savePanel = NSSavePanel()
        
        savePanel.title = "GraphicX"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(NSApp.windows.first?.title ?? "name").png"
        
        let modalresponse = savePanel.runModal()
        if modalresponse == .OK {
            if let url = savePanel.url {
                Singleton.sharedInstance()?.image.save(at: url)
            }
        }
    }
    
    @IBAction private func exportPalette(_ sender: NSMenuItem) {
        let savePanel = NSSavePanel()
        
        savePanel.title = "GraphicX"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(NSApp.windows.first?.title ?? "name").act"
        
        let modalresponse = savePanel.runModal()
        if modalresponse == .OK {
            if let url = savePanel.url {
                Singleton.sharedInstance()?.image.palette.saveAsPhotoshopAct(atPath: url.path)
            }
        }
    }
    
    @IBAction private func screenWidth(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.setSize(CGSize(width: CGFloat(sender.tag), height: (Singleton.sharedInstance()?.image.size.height)!))
        updateAllMenus()
    }
    
    @IBAction private func screenHeight(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.setSize(CGSize(width: (Singleton.sharedInstance()?.image.size.width)!, height: CGFloat(sender.tag)))
        updateAllMenus()
    }
    
    @IBAction private func pixelArrangement(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            switch sender.tag {
            case 0: // Packed
                image.setPlaneCount(1)
                image.setBitsPerPixel(1)
                
            case 1: // Planar
                image.setPlaneCount(2)
                
                if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.submenu {
                    if menu.item(withTag: 8)?.state == .on {
                        image.setBitsPerPixel(8) // bitsPerPlane!
                    } else {
                        image.setBitsPerPixel(16) // bitsPerPlane!
                    }
                }
            default:
                break
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction func colors(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setPlaneCount(1)
            image.setBitsPerPixel(UInt32(sender.tag))
            updateAllMenus()
        }
    }
    
    // NOTE: alphaPlane is also alphaChannel when in packed image mode.
    @IBAction func alphaPlane(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.alphaPlane = !image.alphaPlane
        }
        updateAllMenus()
    }
    
    // MARK: - Private Methods
    
    private func updateAllMenus() {
        if let image = Singleton.sharedInstance()?.image {
            // Size
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Size")?.submenu {
                if let width = menu.item(withTitle: "Width")?.submenu {
                    for item in width.items {
                        item.state = item.tag == Int(image.size.width) ? .on : .off
                    }
                }
                
                if let height = menu.item(withTitle: "Height")?.submenu {
                    for item in height.items {
                        item.state = item.tag == Int(image.size.height) ? .on : .off
                    }
                }
            }
            
            // Pixel Arrangement
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Pixel Arrangement")?.submenu {
                if image.planeCount == 1 {
                    // Packed...
                    menu.item(withTitle: "Planar")?.state = .off
                    menu.item(withTitle: "Packed")?.state = .on
                    
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Color Depth")?.isEnabled = true
                    if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Color Depth")?.submenu {
                        menu.item(withTag: 1)?.state = image.bitsPerPixel == 1 ? .on : .off
                        menu.item(withTag: 2)?.state = image.bitsPerPixel == 2 ? .on : .off
                        menu.item(withTag: 4)?.state = image.bitsPerPixel == 4 ? .on : .off
                        menu.item(withTag: 8)?.state = image.bitsPerPixel == 8 ? .on : .off
                        menu.item(withTag: 24)?.state = image.bitsPerPixel == 24 ? .on : .off
                        menu.item(withTitle: "Alpha Channel")?.state = image.alphaPlane == true ? .on : .off
                    }
                    
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.isEnabled = false
                    
                } else {
                    // Planar...
                    menu.item(withTitle: "Planar")?.state = .on
                    menu.item(withTitle: "Packed")?.state = .off
                    
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Color Depth")?.isEnabled = false
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.isEnabled = true
                    if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.submenu {
                        menu.item(withTag: 8)?.state = image.bitsPerPixel == 8 ? .on : .off
                        menu.item(withTag: 16)?.state = image.bitsPerPixel == 16 ? .on : .off
                        for n in 1...5 {
                            menu.item(withTag: n)?.state = image.planeCount == n ? .on : .off
                        }
                        menu.item(withTitle: "Alpha Plane")?.state = image.alphaPlane == true ? .on : .off
                    }
                }
            }
            
        }
    }
    
    
    
}
