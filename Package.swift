// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "TextureViewer",
  platforms: [
    .macOS(.v11)
  ],
  dependencies: [
    .package(name: "DeltaLogger", url: "https://github.com/stackotter/delta-logger", .branch("main"))
  ],
  targets: [
    .executableTarget(
      name: "TextureViewer",
      dependencies: [
        "DeltaLogger"
      ],
      resources: [
        .process("Metal/")
      ]
    )
  ]
)
