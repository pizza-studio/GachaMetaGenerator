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
      - GI using Yatta.moe API: `./GachaMetaGenerator -GI > ./OUTPUT-GI.json`.
      - HSR using Yatta.moe API: `./GachaMetaGenerator -HSR > ./OUTPUT-HSR.json`
      - GID using Dimbreath's Repo: `./GachaMetaGenerator -GID > ./OUTPUT-GI.json`.
      - HSRD using Dimbreath's Repo: `./GachaMetaGenerator -HSRD > ./OUTPUT-HSR.json`
    - The above pipeline commands are proved effective in Bash and ZSH. Be careful that some other shells like `nu` may have different pipeline commands.

### Supported Games:

- Genshin Impact.
- Star Rail.

> Support for ZZZ (Zenless Zone Zero) is currently not planned regardless Dimbreath has made its ExcelConfigData repository (ZenlessData) available to the public. It's just too hard for me to figure out how to spot and organize intels needed to summarize GachaMetaDB from ZenlessData repo. Voluntary PRs are welcomed as long as you keep the generated JSON file structure consistent with existing ones for Genshin and StarRail, regardless the scripting language you familiar with (e.g. Python, etc.).

### License & Legal Notice

**⚠️ IMPORTANT:** Please review all legal documentation in the [LEGAL](./LEGAL/) directory before using this software package.

> Copyright (excl. the Swift program part of this app): (c) All rights reserved by miHoYo and its subsidiaries. Other properties and any right, title, and interest thereof and therein (intellectual property rights included) not derived from miHoYo's game titles ("Star Rail", "Genshin Impact", "Zenless Zone Zero", etc.) belong to their respective owners.

> Copyright (the Swift program part of this app, excluding the data models used for decoding external JSON files): (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).

All Swift program files (but not the data structures used for decoding & encoding data) are licensed under AGPLv3 or later. See [LEGAL/LICENSE](./LEGAL/LICENSE) for full terms.

**Prohibited Use:** This software package is **NOT DESIGNED** to decode, analyze, or process any game data derived from confidential, non-public sources protected by Non-Disclosure Agreements (NDAs). See [LEGAL/NDA_RESTRICTION.md](./LEGAL/NDA_RESTRICTION.md) for details.

```
// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.
```
