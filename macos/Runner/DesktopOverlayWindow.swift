import Cocoa
import FlutterMacOS

class DesktopOverlayWindow: NSPanel {
    private var flutterViewController: FlutterViewController?
    private var isMinimized: Bool = false
    private var expandedHeight: CGFloat = 500
    private var minimizedHeight: CGFloat = 40
    
    var onPositionChanged: ((NSPoint) -> Void)?
    var onSizeChanged: ((NSSize) -> Void)?
    
    convenience init(frame: NSRect) {
        self.init(contentRect: frame,
                  styleMask: [.borderless, .nonactivatingPanel, .hudWindow],
                  backing: .buffered,
                  defer: false)
        
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isFloatingPanel = true
        self.hidesOnDeactivate = false
        self.becomesKeyOnlyIfNeeded = true
        self.acceptsMouseMovedEvents = true
        self.isMovableByWindowBackground = true
        self.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        self.hasShadow = true
        
        self.expandedHeight = frame.size.height
    }
    
    func showOverlay() {
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
    }
    
    func hideOverlay() {
        orderOut(nil)
    }
    
    func setPosition(_ point: NSPoint) {
        setFrameOrigin(point)
        onPositionChanged?(point)
    }
    
    func setSize(_ size: NSSize) {
        var newFrame = frame
        newFrame.size.width = size.width
        if !isMinimized {
            newFrame.size.height = size.height
            expandedHeight = size.height
        }
        setFrame(newFrame, display: true)
        onSizeChanged?(newFrame.size)
    }
    
    func setAlwaysOnTop(_ alwaysOnTop: Bool) {
        if alwaysOnTop {
            level = .floating
        } else {
            level = .normal
        }
    }
    
    func minimize() {
        isMinimized = true
        var newFrame = frame
        newFrame.size.height = minimizedHeight
        setFrame(newFrame, display: true)
        onSizeChanged?(newFrame.size)
    }
    
    func expand() {
        isMinimized = false
        var newFrame = frame
        newFrame.size.height = expandedHeight
        setFrame(newFrame, display: true)
        onSizeChanged?(newFrame.size)
    }
    
    func isOverlayVisible() -> Bool {
        return isVisible
    }
    
    func isOverlayMinimized() -> Bool {
        return isMinimized
    }
    
    func setFlutterViewController(_ controller: FlutterViewController) {
        flutterViewController = controller
        contentView = controller.view
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    override func resignKey() {
        super.resignKey()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let currentLocation = NSEvent.mouseLocation
        let newOrigin = NSPoint(
            x: currentLocation.x - event.deltaX,
            y: currentLocation.y - event.deltaY
        )
        setFrameOrigin(newOrigin)
        onPositionChanged?(newOrigin)
    }
}
