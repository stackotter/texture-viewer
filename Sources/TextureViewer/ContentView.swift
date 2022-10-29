//
//  ContentView.swift
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

import SwiftUI

struct ContentView: View {
  let metalView = MetalView()
  
  var body: some View {
    metalView
      .toolbar(content: {
        Button("Another") {
          metalView.changeTexture()
        }
      })
  }
}
