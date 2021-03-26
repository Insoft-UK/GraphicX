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
        Singleton.sharedInstance()?.mainScene.zoomIn()
    }
    
    @IBAction private func zoomOut(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.zoomOut()
    }
    
    @IBAction private func findPalette(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.nextPalette()
    }
    
    @IBAction private func planeCount(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.setPlaneCount(UInt32(sender.tag))
        updateAllMenus()
    }
    
    @IBAction private func bitsPerPlane(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.setBitsPerComponent(UInt32(sender.tag))
        updateAllMenus()
    }
    
    @IBAction private func platform(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            switch sender.tag {
            case 0: // ZX Spectrum
                scene.setBitsPerComponent(8)
                scene.setPlaneCount(1)
                scene.setScreenSize(CGSize(width: 256, height: 192))
                scene.setAlphaPlane(false);
                
            case 1: // Atari ST Low Resolution
                scene.setBitsPerComponent(16)
                scene.setPlaneCount(4)
                scene.setScreenSize(CGSize(width: 320, height: 200))
                scene.setAlphaPlane(false);
                
            case 2: // Atari ST Medium Resolution
                scene.setBitsPerComponent(16)
                scene.setPlaneCount(2)
                scene.setScreenSize(CGSize(width: 640, height: 200))
                scene.setAlphaPlane(false);
                
            case 3: // Atari ST High Resolution
                scene.setBitsPerComponent(16)
                scene.setPlaneCount(1)
                scene.setScreenSize(CGSize(width: 640, height: 400))
                scene.setAlphaPlane(false);
                
            case 8: // ZX Spectrum Next
                scene.setBitsPerComponent(8)
                scene.setPlaneCount(0)
                scene.setScreenSize(CGSize(width: 256, height: 192))
                
            default: break
                
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction private func increaseWidth(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            var size = scene.screenSize;
            size.width += CGFloat(scene.bitsPerComponent)
            scene.setScreenSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func decreaseWidth(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            var size = scene.screenSize;
            size.width -= CGFloat(scene.bitsPerComponent)
            scene.setScreenSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func increaseHeight(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            var size = scene.screenSize;
            size.height += 1.0
            scene.setScreenSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func decreaseHeight(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            var size = scene.screenSize;
            size.height -= 1.0
            scene.setScreenSize(size)
        }
        updateAllMenus()
    }
    
    @IBAction private func openDocument(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.openDocument()
        updateAllMenus()
    }
    
    @IBAction private func importPalettet(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.importPalette()
    }
    
    @IBAction private func exportAs(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.exportAs()
    }
    
    @IBAction private func exportPalette(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.exportPalette()
    }
    
    @IBAction private func screenWidth(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.setScreenSize(CGSize(width: CGFloat(sender.tag), height: (Singleton.sharedInstance()?.mainScene.screenSize.height)!))
        updateAllMenus()
    }
    
    @IBAction private func screenHeight(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.setScreenSize(CGSize(width: (Singleton.sharedInstance()?.mainScene.screenSize.width)!, height: CGFloat(sender.tag)))
        updateAllMenus()
    }
    
    @IBAction private func pixelArrangement(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            switch sender.tag {
            case 0: // Packed
                scene.setPlaneCount(0)
                scene.setBitsPerComponent(8)
                
            case 1: // Planar
                scene.setPlaneCount(4)
                scene.setBitsPerComponent(16)
                
                if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.submenu {
                    if menu.item(withTag: 8)?.state == .on {
                        scene.setBitsPerComponent(8)
                    } else {
                        scene.setBitsPerComponent(16)
                    }
                }
            default:
                break
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction func colors(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.setPlaneCount(0)
            scene.setBitsPerComponent(UInt32(sender.tag))
            updateAllMenus()
        }
    }
    
    @IBAction func maskPlane(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.setAlphaPlane(!scene.alphaPlane)
        }
        updateAllMenus()
    }
    
    // MARK: - Private Methods
    
    private func updateAllMenus() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            // Size
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Size")?.submenu {
                if let width = menu.item(withTitle: "Width")?.submenu {
                    for item in width.items {
                        item.state = item.tag == Int(scene.screenSize.width) ? .on : .off
                    }
                }
                
                if let height = menu.item(withTitle: "Height")?.submenu {
                    for item in height.items {
                        item.state = item.tag == Int(scene.screenSize.height) ? .on : .off
                    }
                }
            }
            
            // Pixel Arrangement
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Pixel Arrangement")?.submenu {
                if scene.planeCount == 0 {
                    // Packed...
                    menu.item(withTitle: "Planar")?.state = .off
                    menu.item(withTitle: "Packed")?.state = .on
                    
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Color Depth")?.isEnabled = true
                    if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Color Depth")?.submenu {
                        menu.item(withTag: 2)?.state = scene.bitsPerComponent == 2 ? .on : .off
                        menu.item(withTag: 4)?.state = scene.bitsPerComponent == 4 ? .on : .off
                        menu.item(withTag: 8)?.state = scene.bitsPerComponent == 8 ? .on : .off
                        menu.item(withTag: 24)?.state = scene.bitsPerComponent == 24 ? .on : .off
                        if (scene.bitsPerComponent < 4096) {
                            menu.item(withTag: 0)?.state = .off
                        }
                    }
                    
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.isEnabled = false
                } else {
                    // Planar...
                    menu.item(withTitle: "Planar")?.state = .on
                    menu.item(withTitle: "Packed")?.state = .off
                    
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Color Depth")?.isEnabled = false
                    mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.isEnabled = true
                    if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.submenu {
                        menu.item(withTag: 8)?.state = scene.bitsPerComponent == 8 ? .on : .off
                        menu.item(withTag: 16)?.state = scene.bitsPerComponent == 16 ? .on : .off
                        for n in 1...5 {
                            menu.item(withTag: n)?.state = scene.planeCount == n ? .on : .off
                        }
                        menu.item(withTitle: "Alpha Plane")?.state = scene.alphaPlane == true ? .on : .off
                    }
                }
            }
            
        }
    }
}
