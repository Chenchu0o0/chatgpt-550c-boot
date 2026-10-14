# 版权声明与来源 / Notices

本文件记录本项目**非原创部分**的来源与版权归属，并保留原作者要求的版权声明。
本文件构成本项目许可条款的一部分，请与 [LICENSE](LICENSE) 一并阅读。

---

## 1. `550c-overlay.html` —— 派生作品

**本项目中的 `550c-overlay.html` 并非原创，而是下列来源的派生作品。**

### 1.1 上游许可要求保留的版权声明

依据 MIT 许可证「上述版权声明和本许可声明应包含在本软件的所有副本或实质性部分中」的要求，
在此完整保留上游的版权声明：

```
MIT License

Copyright (c) 2026 Ziyang Song
```

上游项目：[dsh-550c-boot](https://github.com/yannicksong0106/dsh-550c-boot)（MIT 许可），
对应文件：`assets/550C-source.html`。

### 1.2 动画原稿作者

`dsh-550c-boot` 的 `CREDITS.md` 明确说明该动画**不是重写的，而是移植的**：
其 `assets/550C-source.html` 是 **Voidpoket** 提供的 550C 片头页面原稿，
上游仅通过 `scripts/extract.mjs` 做定点改写（`:host` 作用域、可取消定时器、
去除页面级噪点等）。配色（琥珀 CRT）、面板布局、时间线节奏均出自这份原稿。

- 动画原稿作者：**Voidpoket** — https://github.com/Voidpoket

### 1.3 派生关系说明

```
Voidpoket                     550C 片头页面原稿（动画的实际创作者）
      │  移植 + 定点改写（scripts/extract.mjs）
      ▼
dsh-550c-boot                 Copyright (c) 2026 Ziyang Song，MIT
      │  少量调整（跳过按钮、触屏合成点击抑制等）
      ▼
本项目 550c-overlay.html      派生作品
```

经逐行比对，本项目的 `550c-overlay.html` 与 `dsh-550c-boot` 的
`assets/550C-source.html` 有约 94% 的内容行完全一致。

### 1.4 本项目新增的部分

`launcher/`、`tools/` 与文档由本项目独立编写，**不包含**上游代码，
不属于上述派生部分：

- `launcher/ChatGPT-boot.ps1`、`launcher/ChatGPT.cmd`
- `tools/Create-ChatGPTShortcut.ps1`、`tools/install.bat`
- `README.md`、`docs/使用说明.md`

---

## 2. `icons/` —— OpenAI 商标素材

`icons/` 中的 ChatGPT 图标为 OpenAI 的商标素材，**不在 MIT 授权范围内**，
仅用于个人使用与展示。详见 [TRADEMARKS.md](TRADEMARKS.md)。

---

## 3. 「550C」设定

「550C」设定出自电影《流浪地球2》（The Wandering Earth II）。
该美术设定与名称的相关权利**不属于本项目，也不属于上述任何一位代码作者**。
本项目对 550C 界面的呈现属于致敬性质的演绎，不主张任何相关权利。

若任何权利人认为本项目中的使用方式不当，请提出 issue，我们会配合调整或移除。

---

## 4. 关于 AI 辅助生成

本项目部分代码由 AI 编程工具辅助生成。`550c-overlay.html` 与上游文件的高度一致性，
是在事后核查中发现的，现主动声明如上。若发现其他文件存在类似未标注的来源，欢迎指出。
