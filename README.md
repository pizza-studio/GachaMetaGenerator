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
- Star Rail.

> Support for ZZZ (Zenless Zone Zero) is currently not planned regardless Dimbreath has made its ExcelConfigData repository (ZenlessData) available to the public. It's just too hard for me to figure out how to spot and organize intels needed to summarize GachaMetaDB from ZenlessData repo. Voluntary PRs are welcomed as long as you keep the generated JSON file structure consistent with existing ones for Genshin and StarRail, regardless the scripting language you familiar with (e.g. Python, etc.).

$ EOF.
