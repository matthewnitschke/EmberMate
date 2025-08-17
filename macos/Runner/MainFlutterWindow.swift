import Cocoa
import FlutterMacOS

// This class is no longer used since we're using a menubar popover
// The FlutterViewController is now created in AppDelegate.swift
class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    // Window creation is now handled in AppDelegate for the menubar popover
    super.awakeFromNib()
  }
}
