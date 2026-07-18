# MiDaS

**MiDaS (monocular depth estimation)** — Estimates a dense depth map from a single image — no stereo or sensor needed.

An **azphalt** AI-model plugin, packaged as a `.azp` (the azphalt analogue of a VS Code `.vsix`). It is
named for the *model*, not a single feature — the same model powers many tools, and it is **host-neutral**:
any azphalt host that understands its role can use it, not just one app. Install it from any host's
**Azphalt Storefront**.

## What it can do

- depth maps
- 2.5D parallax / camera moves
- depth-based bokeh & relighting
- fog / atmosphere by depth

## Roles (host-neutral routing)

This plugin contributes the role(s): `depth`. A host routes the model by role — it carries no
`targetApps`, so it is not tied to any single application.

**Example host — [Guillotine](https://github.com/HereLiesAz/Guillotine):** Desktop `effect_depth` — `apply_image_effect effect=depth`.

## Model file(s)

- **`midas.onnx`** (role `depth`) — [upstream](https://huggingface.co/julienkay/sentis-MiDaS/resolve/main/midas_v21_small_256.onnx)

Model license: **MIT (MiDaS, Intel ISL)**. This plugin's manifest/packaging is `MIT`.

## How it works — the VSCode Header Pattern

The `.azp` does **not** bundle the weights. The manifest declares each model as a *remote asset*
(`"path": ""` + `remoteUrl` + `checksum` + `byteSize`); the host downloads the weights on install and
verifies them against the pinned SHA-256 — exactly how a large VS Code extension fetches its language
server instead of shipping it inside the `.vsix`. `remoteUrl` points at this repo's own GitHub **Release**
asset (named the exact filename the host expects); the `release` workflow fetches the upstream model,
renames it, checksums it, and publishes it beside the packed `.azp`.

## Build / release

```sh
npm install && npm run build     # packs com.hereliesaz.azphalt.midas-1.0.0.azp
git tag v1.0.0 && git push --tags   # runs the release workflow: hosts the model + .azp
```
