# GachaMetaGenerator

This repository is for generating GachaMetaDB to serve those apps conforming to UIGFv4 standard (or newer).

### Usage: 

- Method 1: Use it as a Swift Package in Xcode.
- Method 2: Cross-platform usage.
  - Step 1: Install Swift.
  - Step 2: Compile the package.
    - `swift build -c release`
    - Built executable file path is `.build/release/GachaMetaGenerator`.
  - Step 3: Run the compiled executable and pipeline the output contents into a new JSON file.
    - You only need one parameter to specify whether it writes for Genshin or HSR.
    - GI: `./GachaMetaGenerator -GI > ./OUTPUT-GI.json`.
      - HSR: `./GachaMetaGenerator -HSR > ./OUTPUT-HSR.json`
    - The above pipeline commands are proved effective in Bash and ZSH. Be careful that some other shells like `nu` may have different pipeline commands.

### Supported Games:

- Genshin Impact.
- Houkai: Star Rail. // `Honkai` is a deliberate typo to help native English speakers pronounce it unweirdly.

$ EOF.
