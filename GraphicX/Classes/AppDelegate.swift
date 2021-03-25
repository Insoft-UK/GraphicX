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
    
    @IBAction private func findPalette(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.nextPalette()
    }
    
    @IBAction private func planeCount(_ sender: NSMenuItem) {
        if let number = UInt32(sender.title) {
            Singleton.sharedInstance()?.mainScene.setPlaneCount(number)
            updateAllMenus()
        }
    }
    
    @IBAction private func bitsPerPlane(_ sender: NSMenuItem) {
        if let number = UInt32(sender.title) {
            Singleton.sharedInstance()?.mainScene.setBitsPerPlane(number)
            updateAllMenus()
        }
    }
    
    @IBAction private func platform(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if sender.title == "ZX Spectrum" {
                scene.setBitsPerComponent(1)
                scene.setPlaneCount(1)
                scene.setBitsPerPlane(8)
                scene.setPixelArrangement(PixelArrangementPlanar)
                scene.setScreenSize(CGSize(width: 256, height: 192))
                scene.setMaskInterleaved(false);
            }
            
            if sender.title == "Atari ST/E Low" {
                scene.setBitsPerComponent(1)
                scene.setPlaneCount(4)
                scene.setBitsPerPlane(16)
                scene.setPixelArrangement(PixelArrangementPlanar)
                scene.setScreenSize(CGSize(width: 320, height: 200))
                scene.setMaskInterleaved(false);
            }
            
            if sender.title == "ZX Spectrum NEXT" {
                scene.setBitsPerComponent(8)
                scene.setPixelArrangement(PixelArrangementPacked)
                scene.setScreenSize(CGSize(width: 256, height: 64))
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction private func increaseWidth(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.increaseWidth()
        updateAllMenus()
    }
    
    @IBAction private func decreaseWidth(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.decreaseWidth()
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
        if let number = UInt(sender.title) {
            Singleton.sharedInstance()?.mainScene.setScreenSize(CGSize(width: CGFloat(number), height: (Singleton.sharedInstance()?.mainScene.screenSize.height)!))
            updateAllMenus()
        }
    }
    
    @IBAction private func screenHeight(_ sender: NSMenuItem) {
        if let number = UInt(sender.title) {
            Singleton.sharedInstance()?.mainScene.setScreenSize(CGSize(width: (Singleton.sharedInstance()?.mainScene.screenSize.width)!, height: CGFloat(number)))
            updateAllMenus()
        }
    }
    
    @IBAction private func pixelArrangement(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.setPixelArrangement(sender.title == "Planar" ? PixelArrangementPlanar : PixelArrangementPacked)
        }
        
        updateAllMenus()
    }
    
    @IBAction func colors(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.setPixelArrangement(PixelArrangementPacked)

            if let number = UInt(sender.title) {
                switch number {
                case 4:
                    scene.setBitsPerComponent(2)
                case 16:
                    scene.setBitsPerComponent(4)
                default:
                    break
                }
            } else {
                scene.setBitsPerComponent(8)
            }
            updateAllMenus()
        }
    }
    
    @IBAction func maskInterleaved(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.setMaskInterleaved(!scene.maskInterleaved)
        }
        updateAllMenus()
    }
    
    // MARK: - Private Methods
    
    private func updateScreenSizeMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Size")?.submenu {
                
                // Width
                if let width = menu.item(withTitle: "Width")?.submenu {
                    for size in width.items {
                        let value = Int(size.title) ?? 0
                        if value == Int(scene.screenSize.width) {
                            size.state = .on
                        } else {
                            size.state = .off
                        }
                        
                    }
                }
                
                // Height
                if let width = menu.item(withTitle: "Height")?.submenu {
                    for size in width.items {
                        let value = Int(size.title) ?? 0
                        if value == Int(scene.screenSize.height) {
                            size.state = .on
                        } else {
                            size.state = .off
                        }
                        
                    }
                }
            }
        }
    }
    
    private func updatePlanesMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if scene.pixelArrangement == PixelArrangementPlanar {
                
                mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.isEnabled = true
                
                if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.submenu {
                    menu.item(withTitle: "8")?.state = scene.bitsPerPlane == 8 ? .on : .off
                    menu.item(withTitle: "16")?.state = scene.bitsPerPlane == 16 ? .on : .off
                    
                    menu.item(withTitle: "1")?.state = .off
                    menu.item(withTitle: "2")?.state = .off
                    menu.item(withTitle: "4")?.state = .off
                    menu.item(withTitle: String(scene.planeCount))?.state = .on
                    
                    menu.item(withTitle: "Mask Interleaved")?.state = scene.maskInterleaved == true ? .on : .off
                }
                
            } else {
                mainMenu.item(at: 2)?.submenu?.item(withTitle: "Planes")?.isEnabled = false
            }
            
        }
    }
    
    private func updatePixelArrangementMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Pixel Arrangement")?.submenu {
                menu.item(withTitle: "Planar")?.state = scene.pixelArrangement == PixelArrangementPlanar ? .on : .off
                menu.item(withTitle: "Packed")?.state = scene.pixelArrangement == PixelArrangementPacked ? .on : .off
            }
        }
    }
    
    private func updateColorsMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if scene.pixelArrangement == PixelArrangementPacked {
                mainMenu.item(at: 2)?.submenu?.item(withTitle: "Colors")?.isEnabled = true
                if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Colors")?.submenu {
                    menu.item(withTitle: "4 Colors")?.state = scene.bitsPerComponent == 2 ? .on : .off
                    menu.item(withTitle: "16 Colors")?.state = scene.bitsPerComponent == 4 ? .on : .off
                    menu.item(withTitle: "RGB332 Color")?.state = scene.bitsPerComponent == 8 ? .on : .off
                    menu.item(withTitle: "Indexed Color")?.state = scene.bitsPerComponent == 8 ? .on : .off
                    
                    
                }
            } else {
                mainMenu.item(at: 2)?.submenu?.item(withTitle: "Colors")?.isEnabled = false
            }
        }
    }
    
    private func updateAllMenus() {
        updateScreenSizeMenu()
        updatePlanesMenu()
        updatePixelArrangementMenu()
        updateColorsMenu()
    }
}
