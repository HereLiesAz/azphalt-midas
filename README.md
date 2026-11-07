# MiDaS

**MiDaS (monocular depth estimation)** — Estimates a dense, **relative** depth map from a single image — no stereo or sensor needed.

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

- **`midas.onnx`** (role `depth`) — MiDaS v2.1 small, 256×256, ONNX opset 15, float32, 66,389,153 bytes,
  `sha256-b0a5b3f12625137e626805167907fe0410665bec671685d59daaa2daab19f977`.
  Unmodified copy of [`onnx/midas_v21_small_256.onnx`](https://huggingface.co/julienkay/sentis-MiDaS/blob/main/onnx/midas_v21_small_256.onnx)
  from [julienkay/sentis-MiDaS](https://huggingface.co/julienkay/sentis-MiDaS) (the `onnx/` directory is part of the path).

Model license: **MIT** (MiDaS © 2019 Intel ISL; ONNX conversion by julienkay). This plugin's manifest/packaging is `MIT`.
See `NOTICE` for the full attribution.

### Input / output (verified by inspecting the graph and running it)

| | name | dtype | shape | notes |
|---|---|---|---|---|
| input | `input_image` | float32 | `[1, 3, 256, 256]` (NCHW, RGB) | values in **[0, 1]** (`x/255`). The ImageNet mean/std normalization is already baked into the graph; do not normalize again. Static size: resize the image to 256×256 first. |
| output | `output_depth` | float32 | `[1, 256, 256]` (no channel axis) | **relative inverse depth**, see below. |

**What the output means.** It is *relative inverse depth* (disparity-like): a **larger value is nearer**, smaller is farther.
It is **not metric** and has an **arbitrary, per-image scale and shift**, so values are not comparable between images
and are not bounded to a fixed range (observed roughly 0 to several hundred or more). Normalize each result (for example
min–max per image) before display or before combining it with other depth sources, and resize it back to the source
resolution yourself. Do not read it as metres or as `1/metres` without a separate calibration.

## How it works — the VSCode Header Pattern

The `.azp` does **not** bundle the weights. The manifest declares each model as a *remote asset*
(`"path": ""` + `remoteUrl` + `checksum` + `byteSize`); the host downloads the weights on install and
verifies them against the pinned SHA-256 — exactly how a large VS Code extension fetches its language
server instead of shipping it inside the `.vsix`. `remoteUrl` points at this repo's own GitHub **Release**
asset (named the exact filename the host expects); `scripts/release.sh` fetches the upstream model, refuses to
publish it unless its size and SHA-256 match the committed manifest, and uploads it as `midas.onnx`. The URL is pinned to a
versioned tag (never `latest`), so a signed manifest keeps resolving to the exact bytes it was checksummed against.

## Build / release

```sh
npm install && npm run build     # packs com.hereliesaz.azphalt.midas-<version>.azp (unsigned; signing is the owner's step)
scripts/release.sh               # verify upstream bytes against manifest.json (size + sha256)
scripts/release.sh --publish     # create release v<version> carrying midas.onnx (needs an authenticated gh)
```
