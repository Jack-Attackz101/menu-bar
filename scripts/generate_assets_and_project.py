#!/usr/bin/env python3
"""Generate aurora/spade PNGs and the Xcode project on Linux."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path("/workspace")
ASSETS = ROOT / "MenuBar" / "Assets.xcassets"
ICONSET = ASSETS / "AppIcon.appiconset"


def png(width: int, height: int, pixels: bytes) -> bytes:
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b""
    stride = width * 4
    for y in range(height):
        raw += b"\x00" + pixels[y * stride : (y + 1) * stride]
    return b"".join(
        [
            b"\x89PNG\r\n\x1a\n",
            chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)),
            chunk(b"IDAT", zlib.compress(raw, 9)),
            chunk(b"IEND", b""),
        ]
    )


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def mix(c1, c2, t):
    return tuple(lerp(a, b, t) for a, b in zip(c1, c2))


def in_spade(nx: float, ny: float) -> bool:
    """Unit-square thin-ish spade. nx, ny in 0..1, y-down."""
    x = (nx - 0.5) * 2.0
    y = (ny - 0.42) * 2.15
    leaf = (x * x + (y + 0.18) * (y + 0.18)) < (0.42 - 0.55 * max(y, -0.2)) ** 2 and y < 0.35
    heartish = (abs(x) ** 1.35 + max(y + 0.55, 0) ** 1.6) < 0.42 and y < 0.15
    stem = abs(x) < 0.07 and 0.18 < ny < 0.86
    base = abs(x) < (0.22 if ny > 0.78 else 0.0) and 0.78 < ny < 0.88
    return leaf or heartish or stem or base


def render(size: int, for_menu: bool = False) -> bytes:
    pixels = bytearray(size * size * 4)
    for y in range(size):
        for x in range(size):
            u = x / max(size - 1, 1)
            v = y / max(size - 1, 1)
            # aurora: peach/pink/lavender/sky/teal
            peach = (1.0, 0.77, 0.72)
            pink = (0.96, 0.69, 0.82)
            lavender = (0.77, 0.71, 0.99)
            sky = (0.49, 0.83, 0.99)
            teal = (0.37, 0.91, 0.83)
            c = mix(peach, lavender, u)
            c = mix(c, pink, 0.35 * (1 - v))
            c = mix(c, sky, 0.40 * u * v)
            c = mix(c, teal, 0.30 * (1 - u) * v)
            # vignette
            dx, dy = u - 0.5, v - 0.5
            vig = min(1.0, (dx * dx + dy * dy) * 1.6)
            c = mix(c, (0.16, 0.12, 0.22), vig * 0.45)
            if in_spade(u, v):
                c = (0.16, 0.12, 0.24) if not for_menu else (1.0, 1.0, 1.0)
            a = 255
            i = (y * size + x) * 4
            pixels[i : i + 4] = bytes((int(c[0] * 255), int(c[1] * 255), int(c[2] * 255), a))
    return png(size, size, bytes(pixels))


def write_icons() -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)
    mapping = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }
    for name, size in mapping.items():
        (ICONSET / name).write_bytes(render(size))


def write_json() -> None:
    (ASSETS / "Contents.json").write_text(
        """{
  "info": {
    "author": "xcode",
    "version": 1
  }
}
"""
    )
    (ASSETS / "AccentColor.colorset" / "Contents.json").write_text(
        """{
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0xC4",
          "green": "0xB5",
          "blue": "0xFD",
          "alpha": "1.000"
        }
      }
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
"""
    )
    (ICONSET / "Contents.json").write_text(
        """{
  "images": [
    {"idiom": "mac", "size": "16x16", "scale": "1x", "filename": "icon_16x16.png"},
    {"idiom": "mac", "size": "16x16", "scale": "2x", "filename": "icon_16x16@2x.png"},
    {"idiom": "mac", "size": "32x32", "scale": "1x", "filename": "icon_32x32.png"},
    {"idiom": "mac", "size": "32x32", "scale": "2x", "filename": "icon_32x32@2x.png"},
    {"idiom": "mac", "size": "128x128", "scale": "1x", "filename": "icon_128x128.png"},
    {"idiom": "mac", "size": "128x128", "scale": "2x", "filename": "icon_128x128@2x.png"},
    {"idiom": "mac", "size": "256x256", "scale": "1x", "filename": "icon_256x256.png"},
    {"idiom": "mac", "size": "256x256", "scale": "2x", "filename": "icon_256x256@2x.png"},
    {"idiom": "mac", "size": "512x512", "scale": "1x", "filename": "icon_512x512.png"},
    {"idiom": "mac", "size": "512x512", "scale": "2x", "filename": "icon_512x512@2x.png"}
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
"""
    )


SOURCES = [
    "MenuBarApp.swift",
    "Theme.swift",
    "SpadeMark.swift",
    "GlassBubbleChrome.swift",
    "BubblePanel.swift",
    "KeepAwakeController.swift",
    "KeepAwakeWidget.swift",
    "FlipClockLogic.swift",
    "FlipClock.swift",
    "UsageStore.swift",
    "UsageMeter.swift",
    "MenuBarEnumerator.swift",
    "ImportStore.swift",
    "ImportStrip.swift",
    "SettingsSheet.swift",
    "AppModel.swift",
    "StatusBarController.swift",
    "BubblePresenter.swift",
]

TESTS = [
    "FlipClockLogicTests.swift",
    "ImportStoreTests.swift",
    "UsageMeterTests.swift",
    "KeepAwakeNameTests.swift",
]


def hid(n: int) -> str:
    return f"B39B{n:020X}"


def write_pbxproj() -> None:
    lines = [
        "// !$*UTF8*$!",
        "{",
        "\tarchiveVersion = 1;",
        "\tclasses = {",
        "\t};",
        "\tobjectVersion = 56;",
        "\tobjects = {",
        "",
        "/* Begin PBXBuildFile section */",
    ]
    for i, name in enumerate(SOURCES, start=1):
        lines.append(f"\t\t{hid(0x3100 + i)} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {hid(0x2100 + i)} /* {name} */; }};")
    for i, name in enumerate(TESTS, start=1):
        lines.append(f"\t\t{hid(0x3200 + i)} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {hid(0x2200 + i)} /* {name} */; }};")
    lines.append(f"\t\t{hid(0x3009)} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {hid(0x2009)} /* Assets.xcassets */; }};")
    lines.append(f"\t\t{hid(0x300A)} /* IOKit.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {hid(0x200A)} /* IOKit.framework */; }};")
    lines.append(f"\t\t{hid(0x300B)} /* ApplicationServices.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {hid(0x200D)} /* ApplicationServices.framework */; }};")
    lines += [
        "/* End PBXBuildFile section */",
        "",
        "/* Begin PBXContainerItemProxy section */",
        f"\t\t{hid(0x4001)} /* PBXContainerItemProxy */ = {{",
        "\t\t\tisa = PBXContainerItemProxy;",
        f"\t\t\tcontainerPortal = {hid(0x1003)} /* Project object */;",
        "\t\t\tproxyType = 1;",
        f"\t\t\tremoteGlobalIDString = {hid(0x1002)};",
        '\t\t\tremoteInfo = MenuBar;',
        "\t\t};",
        "/* End PBXContainerItemProxy section */",
        "",
        "/* Begin PBXFileReference section */",
        f'\t\t{hid(0x1001)} /* MenuBar.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MenuBar.app; sourceTree = BUILT_PRODUCTS_DIR; }};',
        f'\t\t{hid(0x1021)} /* MenuBarTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = MenuBarTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};',
    ]
    for i, name in enumerate(SOURCES, start=1):
        lines.append(
            f'\t\t{hid(0x2100 + i)} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};'
        )
    for i, name in enumerate(TESTS, start=1):
        lines.append(
            f'\t\t{hid(0x2200 + i)} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};'
        )
    lines += [
        f'\t\t{hid(0x2009)} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};',
        f'\t\t{hid(0x200A)} /* IOKit.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = IOKit.framework; path = System/Library/Frameworks/IOKit.framework; sourceTree = SDKROOT; }};',
        f'\t\t{hid(0x200D)} /* ApplicationServices.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = ApplicationServices.framework; path = System/Library/Frameworks/ApplicationServices.framework; sourceTree = SDKROOT; }};',
        f'\t\t{hid(0x200B)} /* MenuBar.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MenuBar.entitlements; sourceTree = "<group>"; }};',
        f'\t\t{hid(0x200C)} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};',
        "/* End PBXFileReference section */",
        "",
        "/* Begin PBXFrameworksBuildPhase section */",
        f"\t\t{hid(0x100A)} /* Frameworks */ = {{",
        "\t\t\tisa = PBXFrameworksBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\tfiles = (",
        f"\t\t\t\t{hid(0x300A)} /* IOKit.framework in Frameworks */,",
        f"\t\t\t\t{hid(0x300B)} /* ApplicationServices.framework in Frameworks */,",
        "\t\t\t);",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t};",
        f"\t\t{hid(0x102A)} /* Frameworks */ = {{",
        "\t\t\tisa = PBXFrameworksBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\tfiles = (",
        "\t\t\t);",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t};",
        "/* End PBXFrameworksBuildPhase section */",
        "",
        "/* Begin PBXGroup section */",
        f"\t\t{hid(0x1004)} /* Root */ = {{",
        "\t\t\tisa = PBXGroup;",
        "\t\t\tchildren = (",
        f"\t\t\t\t{hid(0x1006)} /* MenuBar */,",
        f"\t\t\t\t{hid(0x1008)} /* MenuBarTests */,",
        f"\t\t\t\t{hid(0x1007)} /* Frameworks */,",
        f"\t\t\t\t{hid(0x1005)} /* Products */,",
        "\t\t\t);",
        "\t\t\tsourceTree = \"<group>\";",
        "\t\t};",
        f"\t\t{hid(0x1005)} /* Products */ = {{",
        "\t\t\tisa = PBXGroup;",
        "\t\t\tchildren = (",
        f"\t\t\t\t{hid(0x1001)} /* MenuBar.app */,",
        f"\t\t\t\t{hid(0x1021)} /* MenuBarTests.xctest */,",
        "\t\t\t);",
        "\t\t\tname = Products;",
        "\t\t\tsourceTree = \"<group>\";",
        "\t\t};",
        f"\t\t{hid(0x1006)} /* MenuBar */ = {{",
        "\t\t\tisa = PBXGroup;",
        "\t\t\tchildren = (",
    ]
    for i, name in enumerate(SOURCES, start=1):
        lines.append(f"\t\t\t\t{hid(0x2100 + i)} /* {name} */,")
    lines += [
        f"\t\t\t\t{hid(0x2009)} /* Assets.xcassets */,",
        f"\t\t\t\t{hid(0x200B)} /* MenuBar.entitlements */,",
        f"\t\t\t\t{hid(0x200C)} /* Info.plist */,",
        "\t\t\t);",
        "\t\t\tpath = MenuBar;",
        "\t\t\tsourceTree = \"<group>\";",
        "\t\t};",
        f"\t\t{hid(0x1008)} /* MenuBarTests */ = {{",
        "\t\t\tisa = PBXGroup;",
        "\t\t\tchildren = (",
    ]
    for i, name in enumerate(TESTS, start=1):
        lines.append(f"\t\t\t\t{hid(0x2200 + i)} /* {name} */,")
    lines += [
        "\t\t\t);",
        "\t\t\tpath = MenuBarTests;",
        "\t\t\tsourceTree = \"<group>\";",
        "\t\t};",
        f"\t\t{hid(0x1007)} /* Frameworks */ = {{",
        "\t\t\tisa = PBXGroup;",
        "\t\t\tchildren = (",
        f"\t\t\t\t{hid(0x200A)} /* IOKit.framework */,",
        f"\t\t\t\t{hid(0x200D)} /* ApplicationServices.framework */,",
        "\t\t\t);",
        "\t\t\tname = Frameworks;",
        "\t\t\tsourceTree = \"<group>\";",
        "\t\t};",
        "/* End PBXGroup section */",
        "",
        "/* Begin PBXNativeTarget section */",
        f"\t\t{hid(0x1002)} /* MenuBar */ = {{",
        "\t\t\tisa = PBXNativeTarget;",
        f"\t\t\tbuildConfigurationList = {hid(0x100C)} /* Build configuration list for PBXNativeTarget \"MenuBar\" */;",
        "\t\t\tbuildPhases = (",
        f"\t\t\t\t{hid(0x1008 + 0x10)} /* Sources */,",
        f"\t\t\t\t{hid(0x100A)} /* Frameworks */,",
        f"\t\t\t\t{hid(0x1009)} /* Resources */,",
        "\t\t\t);",
        "\t\t\tbuildRules = (",
        "\t\t\t);",
        "\t\t\tdependencies = (",
        "\t\t\t);",
        "\t\t\tname = MenuBar;",
        "\t\t\tproductName = MenuBar;",
        f"\t\t\tproductReference = {hid(0x1001)} /* MenuBar.app */;",
        '\t\t\tproductType = "com.apple.product-type.application";',
        "\t\t};",
        f"\t\t{hid(0x1022)} /* MenuBarTests */ = {{",
        "\t\t\tisa = PBXNativeTarget;",
        f"\t\t\tbuildConfigurationList = {hid(0x102C)} /* Build configuration list for PBXNativeTarget \"MenuBarTests\" */;",
        "\t\t\tbuildPhases = (",
        f"\t\t\t\t{hid(0x1028)} /* Sources */,",
        f"\t\t\t\t{hid(0x102A)} /* Frameworks */,",
        f"\t\t\t\t{hid(0x1029)} /* Resources */,",
        "\t\t\t);",
        "\t\t\tbuildRules = (",
        "\t\t\t);",
        "\t\t\tdependencies = (",
        f"\t\t\t\t{hid(0x4002)} /* PBXTargetDependency */,",
        "\t\t\t);",
        "\t\t\tname = MenuBarTests;",
        "\t\t\tproductName = MenuBarTests;",
        f"\t\t\tproductReference = {hid(0x1021)} /* MenuBarTests.xctest */;",
        '\t\t\tproductType = "com.apple.product-type.bundle.unit-test";',
        "\t\t};",
        "/* End PBXNativeTarget section */",
        "",
        "/* Begin PBXProject section */",
        f"\t\t{hid(0x1003)} /* Project object */ = {{",
        "\t\t\tisa = PBXProject;",
        "\t\t\tattributes = {",
        "\t\t\t\tBuildIndependentTargetsInParallel = 1;",
        "\t\t\t\tLastSwiftUpdateCheck = 1500;",
        "\t\t\t\tLastUpgradeCheck = 1500;",
        "\t\t\t\tTargetAttributes = {",
        f"\t\t\t\t\t{hid(0x1002)} = {{",
        "\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;",
        "\t\t\t\t\t};",
        f"\t\t\t\t\t{hid(0x1022)} = {{",
        "\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;",
        "\t\t\t\t\t\tTestTargetID = " + hid(0x1002) + ";",
        "\t\t\t\t\t};",
        "\t\t\t\t};",
        "\t\t\t};",
        f"\t\t\tbuildConfigurationList = {hid(0x100B)} /* Build configuration list for PBXProject \"MenuBar\" */;",
        '\t\t\tcompatibilityVersion = "Xcode 14.0";',
        "\t\t\tdevelopmentRegion = en;",
        "\t\t\thasScannedForEncodings = 0;",
        "\t\t\tknownRegions = (",
        "\t\t\t\ten,",
        "\t\t\t\tBase,",
        "\t\t\t);",
        f"\t\t\tmainGroup = {hid(0x1004)} /* Root */;",
        f"\t\t\tproductRefGroup = {hid(0x1005)} /* Products */;",
        '\t\t\tprojectDirPath = "";',
        '\t\t\tprojectRoot = "";',
        "\t\t\ttargets = (",
        f"\t\t\t\t{hid(0x1002)} /* MenuBar */,",
        f"\t\t\t\t{hid(0x1022)} /* MenuBarTests */,",
        "\t\t\t);",
        "\t\t};",
        "/* End PBXProject section */",
        "",
        "/* Begin PBXResourcesBuildPhase section */",
        f"\t\t{hid(0x1009)} /* Resources */ = {{",
        "\t\t\tisa = PBXResourcesBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\tfiles = (",
        f"\t\t\t\t{hid(0x3009)} /* Assets.xcassets in Resources */,",
        "\t\t\t);",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t};",
        f"\t\t{hid(0x1029)} /* Resources */ = {{",
        "\t\t\tisa = PBXResourcesBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\tfiles = (",
        "\t\t\t);",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t};",
        "/* End PBXResourcesBuildPhase section */",
        "",
        "/* Begin PBXSourcesBuildPhase section */",
        f"\t\t{hid(0x1018)} /* Sources */ = {{",
        "\t\t\tisa = PBXSourcesBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\tfiles = (",
    ]
    for i, name in enumerate(SOURCES, start=1):
        lines.append(f"\t\t\t\t{hid(0x3100 + i)} /* {name} in Sources */,")
    lines += [
        "\t\t\t);",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t};",
        f"\t\t{hid(0x1028)} /* Sources */ = {{",
        "\t\t\tisa = PBXSourcesBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\tfiles = (",
    ]
    for i, name in enumerate(TESTS, start=1):
        lines.append(f"\t\t\t\t{hid(0x3200 + i)} /* {name} in Sources */,")
    lines += [
        "\t\t\t);",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t};",
        "/* End PBXSourcesBuildPhase section */",
        "",
        "/* Begin PBXTargetDependency section */",
        f"\t\t{hid(0x4002)} /* PBXTargetDependency */ = {{",
        "\t\t\tisa = PBXTargetDependency;",
        "\t\t\ttarget = " + hid(0x1002) + " /* MenuBar */;",
        f"\t\t\ttargetProxy = {hid(0x4001)} /* PBXContainerItemProxy */;",
        "\t\t};",
        "/* End PBXTargetDependency section */",
        "",
        "/* Begin XCBuildConfiguration section */",
    ]

    project_debug = """
		ALWAYS_SEARCH_USER_PATHS = NO;
		ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
		CLANG_ANALYZER_NONNULL = YES;
		CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
		CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
		CLANG_ENABLE_MODULES = YES;
		CLANG_ENABLE_OBJC_ARC = YES;
		CLANG_ENABLE_OBJC_WEAK = YES;
		CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
		CLANG_WARN_BOOL_CONVERSION = YES;
		CLANG_WARN_COMMA = YES;
		CLANG_WARN_CONSTANT_CONVERSION = YES;
		CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
		CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
		CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
		CLANG_WARN_EMPTY_BODY = YES;
		CLANG_WARN_ENUM_CONVERSION = YES;
		CLANG_WARN_INFINITE_RECURSION = YES;
		CLANG_WARN_INT_CONVERSION = YES;
		CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
		CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
		CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
		CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
		CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
		CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
		CLANG_WARN_STRICT_PROTOTYPES = YES;
		CLANG_WARN_SUSPICIOUS_MOVE = YES;
		CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
		CLANG_WARN_UNREACHABLE_CODE = YES;
		CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
		COPY_PHASE_STRIP = NO;
		DEAD_CODE_STRIPPING = YES;
		DEBUG_INFORMATION_FORMAT = dwarf;
		ENABLE_STRICT_OBJC_MSGSEND = YES;
		ENABLE_TESTABILITY = YES;
		ENABLE_USER_SCRIPT_SANDBOXING = YES;
		GCC_C_LANGUAGE_STANDARD = gnu17;
		GCC_DYNAMIC_NO_PIC = NO;
		GCC_NO_COMMON_BLOCKS = YES;
		GCC_OPTIMIZATION_LEVEL = 0;
		GCC_PREPROCESSOR_DEFINITIONS = (
			"DEBUG=1",
			"$(inherited)",
		);
		GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
		GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
		GCC_WARN_UNDECLARED_SELECTOR = YES;
		GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
		GCC_WARN_UNUSED_FUNCTION = YES;
		GCC_WARN_UNUSED_VARIABLE = YES;
		MACOSX_DEPLOYMENT_TARGET = 14.0;
		MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
		MTL_FAST_MATH = YES;
		ONLY_ACTIVE_ARCH = YES;
		SDKROOT = macosx;
		SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
		SWIFT_OPTIMIZATION_LEVEL = "-Onone";
		SWIFT_VERSION = 5.0;
"""
    project_release = """
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEAD_CODE_STRIPPING = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 5.0;
"""

    lines += [
        f"\t\t{hid(0x100D)} /* Debug */ = {{",
        "\t\t\tisa = XCBuildConfiguration;",
        "\t\t\tbuildSettings = {" + project_debug + "\t\t\t};",
        "\t\t\tname = Debug;",
        "\t\t};",
        f"\t\t{hid(0x100E)} /* Release */ = {{",
        "\t\t\tisa = XCBuildConfiguration;",
        "\t\t\tbuildSettings = {" + project_release + "\t\t\t};",
        "\t\t\tname = Release;",
        "\t\t};",
    ]

    app_settings = """
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = MenuBar/MenuBar.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = MenuBar/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "Super Spade";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.utilities";
				INFOPLIST_KEY_LSUIElement = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.jack-attackz101.menu-bar";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
"""
    test_settings = """
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.jack-attackz101.menu-bar.tests";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MenuBar.app/Contents/MacOS/MenuBar";
"""
    lines += [
        f"\t\t{hid(0x100F)} /* Debug */ = {{",
        "\t\t\tisa = XCBuildConfiguration;",
        "\t\t\tbuildSettings = {" + app_settings + "\t\t\t};",
        "\t\t\tname = Debug;",
        "\t\t};",
        f"\t\t{hid(0x1010)} /* Release */ = {{",
        "\t\t\tisa = XCBuildConfiguration;",
        "\t\t\tbuildSettings = {" + app_settings + "\t\t\t};",
        "\t\t\tname = Release;",
        "\t\t};",
        f"\t\t{hid(0x102F)} /* Debug */ = {{",
        "\t\t\tisa = XCBuildConfiguration;",
        "\t\t\tbuildSettings = {" + test_settings + "\t\t\t};",
        "\t\t\tname = Debug;",
        "\t\t};",
        f"\t\t{hid(0x1030)} /* Release */ = {{",
        "\t\t\tisa = XCBuildConfiguration;",
        "\t\t\tbuildSettings = {" + test_settings + "\t\t\t};",
        "\t\t\tname = Release;",
        "\t\t};",
        "/* End XCBuildConfiguration section */",
        "",
        "/* Begin XCConfigurationList section */",
        f'\t\t{hid(0x100B)} /* Build configuration list for PBXProject "MenuBar" */ = {{',
        "\t\t\tisa = XCConfigurationList;",
        "\t\t\tbuildConfigurations = (",
        f"\t\t\t\t{hid(0x100D)} /* Debug */,",
        f"\t\t\t\t{hid(0x100E)} /* Release */,",
        "\t\t\t);",
        "\t\t\tdefaultConfigurationIsVisible = 0;",
        "\t\t\tdefaultConfigurationName = Release;",
        "\t\t};",
        f'\t\t{hid(0x100C)} /* Build configuration list for PBXNativeTarget "MenuBar" */ = {{',
        "\t\t\tisa = XCConfigurationList;",
        "\t\t\tbuildConfigurations = (",
        f"\t\t\t\t{hid(0x100F)} /* Debug */,",
        f"\t\t\t\t{hid(0x1010)} /* Release */,",
        "\t\t\t);",
        "\t\t\tdefaultConfigurationIsVisible = 0;",
        "\t\t\tdefaultConfigurationName = Release;",
        "\t\t};",
        f'\t\t{hid(0x102C)} /* Build configuration list for PBXNativeTarget "MenuBarTests" */ = {{',
        "\t\t\tisa = XCConfigurationList;",
        "\t\t\tbuildConfigurations = (",
        f"\t\t\t\t{hid(0x102F)} /* Debug */,",
        f"\t\t\t\t{hid(0x1030)} /* Release */,",
        "\t\t\t);",
        "\t\t\tdefaultConfigurationIsVisible = 0;",
        "\t\t\tdefaultConfigurationName = Release;",
        "\t\t};",
        "/* End XCConfigurationList section */",
        "\t};",
        f"\trootObject = {hid(0x1003)} /* Project object */;",
        "}",
        "",
    ]
    (ROOT / "MenuBar.xcodeproj" / "project.pbxproj").write_text("\n".join(lines))


def write_workspace_and_scheme() -> None:
    (ROOT / "MenuBar.xcodeproj" / "project.xcworkspace" / "contents.xcworkspacedata").write_text(
        """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.00">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    )
    (ROOT / "MenuBar.xcodeproj" / "xcshareddata" / "xcschemes" / "MenuBar.xcscheme").write_text(
        f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{hid(0x1002)}"
               BuildableName = "MenuBar.app"
               BlueprintName = "MenuBar"
               ReferencedContainer = "container:MenuBar.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{hid(0x1022)}"
               BuildableName = "MenuBarTests.xctest"
               BlueprintName = "MenuBarTests"
               ReferencedContainer = "container:MenuBar.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{hid(0x1002)}"
            BuildableName = "MenuBar.app"
            BlueprintName = "MenuBar"
            ReferencedContainer = "container:MenuBar.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{hid(0x1002)}"
            BuildableName = "MenuBar.app"
            BlueprintName = "MenuBar"
            ReferencedContainer = "container:MenuBar.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    )


if __name__ == "__main__":
    write_json()
    write_icons()
    write_pbxproj()
    write_workspace_and_scheme()
    print("generated assets + xcodeproj")
