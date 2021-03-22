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
    
    @IBOutlet weak var formatMenu: NSMenu!

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        updateAllMenus()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Action Methods for Menu
    
    @IBAction func findPalette(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.nextPalette()
    }
    
    @IBAction func bitplane(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            let planes = Int(sender.title) ?? 0
            if planes > 0 {
                scene.setBitplanes(planes)
            } else {
                if sender.title == "8 Bits" {
                    scene.setBytesPerBitplane(1)
                }
                
                if sender.title == "16 Bits" {
                    scene.setBytesPerBitplane(2)
                }
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction func platform(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if sender.title == "ZX Spectrum" {
                scene.setBitplanes(1)
                scene.setBytesPerBitplane(1)
                scene.setPixelArrangement(PixelArrangementPlanar)
                scene.setScreenSize(CGSize(width: 256, height: 192))
            }
            
            if sender.title == "Atari ST/E Low" {
                scene.setBitplanes(4)
                scene.setBytesPerBitplane(2)
                scene.setPixelArrangement(PixelArrangementPlanar)
                scene.setScreenSize(CGSize(width: 320, height: 200))
            }
            
            if sender.title == "ZX Spectrum NEXT" {
                scene.setBitsPerColor(8)
                scene.setPixelArrangement(PixelArrangementPacked)
                scene.setScreenSize(CGSize(width: 256, height: 64))
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction func increaseWidth(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.increaseWidth()
        }
        
        updateAllMenus()
    }
    
    @IBAction func decreaseWidth(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.decreaseWidth()
        }
        
        updateAllMenus()
    }
    
    @IBAction func openDocument(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.mainScene.openDocument()
    }
    
    @IBAction func exportAs(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.exportAs()
        }
    }
    
    @IBAction func screenWidth(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            let w = Int(sender.title) ?? 0
            if w > 0 {
                let size = CGSize(width: CGFloat(w), height: scene.screenSize.height)
                scene.setScreenSize(size)
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction func screenHeight(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            let h = Int(sender.title) ?? 0
            if h > 0 {
                let size = CGSize(width: scene.screenSize.width, height: CGFloat(h))
                scene.setScreenSize(size)
            }
        }
        
        updateAllMenus()
    }
    
    @IBAction func pixelArrangement(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            scene.setPixelArrangement(sender.title == "Planar" ? PixelArrangementPlanar : PixelArrangementPacked)
        }
        
        updateAllMenus()
    }
    
    @IBAction func colors(_ sender: NSMenuItem) {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if sender.title == "4 Colors" {
                scene.setBitsPerColor(2)
            }
            
            if sender.title == "16 Colors" {
                scene.setBitsPerColor(4)
            }
            
            if sender.title == "Indexed Color" {
                scene.setBitsPerColor(8)
            }
        }
        updateAllMenus()
    }
    
    // MARK: - Private Methods
    
    private func updateScreenSizeMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if let menu = formatMenu.item(withTitle: "Screen Size")?.submenu {
                
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
    
    private func updateBitplaneMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if scene.pixelArrangement == PixelArrangementPlanar {
                formatMenu.item(withTitle: "Bitplane")?.isEnabled = true
                
                if let menu = formatMenu.item(withTitle: "Bitplane")?.submenu {
                    menu.item(withTitle: "8 Bits")?.state = scene.bytesPerBitplane == 1 ? .on : .off
                    menu.item(withTitle: "16 Bits")?.state = scene.bytesPerBitplane == 2 ? .on : .off
                    
                    menu.item(withTitle: "1")?.state = .off
                    menu.item(withTitle: "2")?.state = .off
                    menu.item(withTitle: "4")?.state = .off
                    menu.item(withTitle: String(scene.bitplanes))?.state = .on
                }
                
            } else {
                formatMenu.item(withTitle: "Bitplane")?.isEnabled = false
            }
            
        }
    }
    
    private func updatePixelArrangementMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if let menu = formatMenu.item(withTitle: "Pixel Arrangement")?.submenu {
                menu.item(withTitle: "Planar")?.state = scene.pixelArrangement == PixelArrangementPlanar ? .on : .off
                menu.item(withTitle: "Packed")?.state = scene.pixelArrangement == PixelArrangementPacked ? .on : .off
            }
        }
    }
    
    private func updateColorsMenu() {
        if let scene = Singleton.sharedInstance()?.mainScene {
            if scene.pixelArrangement == PixelArrangementPacked {
                formatMenu.item(withTitle: "Colors")?.isEnabled = true
                if let menu = formatMenu.item(withTitle: "Colors")?.submenu {
                    menu.item(withTitle: "4 Colors")?.state = scene.bitsPerColor == 2 ? .on : .off
                    menu.item(withTitle: "16 Colors")?.state = scene.bitsPerColor == 4 ? .on : .off
                    menu.item(withTitle: "RGB332 Color")?.state = scene.bitsPerColor == 8 ? .on : .off
                    menu.item(withTitle: "Indexed Color")?.state = scene.bitsPerColor == 8 ? .on : .off
                    
                    
                }
            } else {
                formatMenu.item(withTitle: "Colors")?.isEnabled = false
            }
        }
    }
    
    private func updateAllMenus() {
        updateScreenSizeMenu()
        updateBitplaneMenu()
        updatePixelArrangementMenu()
        updateColorsMenu()
    }
}
