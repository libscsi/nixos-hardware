{
  lib,
  fetchurl, # fetchpatch does unnecessary normalization
  ...
}@args:

{
  kernel,
  patchesFile,
}:
let
  inherit (builtins) readFile fromJSON;

  patchset = fromJSON (readFile patchesFile);
  t2-patches = map (
    { name, hash }:
    {
      inherit name;
      patch =
        if name == "2008-i915-4-lane-quirk-for-mbp15-1.patch" then fetchurl {
            inherit name;
            url = "https://gist.githubusercontent.com/libscsi/ac074c11a6d5a3c4c8df8f10371ab00b/raw/4c8488b28ecfd9b0b34b64b7d6a029068a59cad8/2008-i915-4-lane-quirk-for-mbp15-1.patch";
            hash = "sha256-D5Bn2ooZiv1JCkIRlFghX1ZEUyH4MBpOJXKqQ/KTFF8=";
            }

        else

          fetchurl {
            inherit name hash;
            url = patchset.base_url + name;
          };
    }
  ) patchset.patches;
in
kernel.override (
  args
  // {
    pname = "linux-t2";

    structuredExtraConfig = with lib.kernel; {
      APPLE_BCE = module;
      APPLE_GMUX = module;
      APFS_FS = module;
      BRCMFMAC = module;
      BT_BCM = module;
      BT_HCIBCM4377 = module;
      BT_HCIUART_BCM = yes;
      BT_HCIUART = module;
      HID_APPLETB_BL = module;
      HID_APPLETB_KBD = module;
      HID_APPLE = module;
      HID_MAGICMOUSE = module;
      DRM_APPLETBDRM = module;
      HID_SENSOR_ALS = module;
      SND_PCM = module;
      STAGING = yes;
    };

    kernelPatches = t2-patches ++ (args.kernelPatches or [ ]);

    argsOverride.extraMeta = {
      description = "The Linux kernel (with patches from the T2 Linux project)";

      # take responsibility for the downstream kernel
      maintainers = with lib.maintainers; [ soopyc ];
    };
  }
  // (args.argsOverride or { })
)
