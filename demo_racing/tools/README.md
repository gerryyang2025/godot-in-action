# demo_racing Tools

## Runtime Asset Export

When source OBJ or audio files under `assets/third_party/` or `assets/audio/` change, regenerate the committed runtime resources:

```sh
godot --headless --path demo_racing --script res://tools/export_runtime_assets.gd
```

This updates `assets/runtime/`, which is the resource set used by scenes and scripts at runtime.

## Fresh Checkout Verification

Before pushing asset-related changes, verify that a clean copy without project-level `.godot/` cache still starts correctly:

```sh
./demo_racing/tools/verify_fresh_checkout.sh
```

The script copies `demo_racing/` to a temporary directory, excludes `.godot/`, then runs:

```sh
godot --headless --path <temp_demo_racing> --quit-after 1
godot --headless --editor --quit --path <temp_demo_racing>
```
