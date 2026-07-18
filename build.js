import fs from "fs";
import { writeAzp } from "@azphalt/azp";

// A remote-header plugin: model weights are fetched at install time from each asset's `remoteUrl`, so
// there is no bundled payload — the .azp carries only the manifest (the VSCode Header Pattern).
const manifest = JSON.parse(fs.readFileSync("manifest.json", "utf-8"));
const { azp } = writeAzp({ manifest, payload: {}, license: manifest.license || "All Rights Reserved" });
const outName = `${manifest.id}-${manifest.version}.azp`;
fs.writeFileSync(outName, azp);
console.log(`Built ${outName} (${azp.length} bytes)`);
