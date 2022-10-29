//
//  TextureViewerApp.swift
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

import SwiftUI

struct TextureViewerApp: App {
  var contentView = ContentView()
  var body: some Scene {
    WindowGroup {
      contentView.onOpenURL(perform: { url in
        contentView.metalView.coordinator.setTextureFromURL(
          url: url, withDevice: MTLCreateSystemDefaultDevice()!
        )
      })
    }
  }
}
