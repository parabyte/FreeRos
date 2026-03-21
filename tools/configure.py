#!/usr/bin/env python3

import argparse
import os
import sys

try:
    import curses
    HAS_CURSES = True
except ImportError:
    HAS_CURSES = False


OPTIONS = [
    {"section": "Identity"},
    {
        "key": "CONFIG_MACHINE_NAME",
        "label": "Machine name",
        "type": "string",
        "default": "FreeRos PC1640 Compatible BIOS",
    },
    {
        "key": "CONFIG_BIOS_BRAND",
        "label": "BIOS brand",
        "type": "string",
        "default": "FreeRos",
    },
    {
        "key": "CONFIG_BIOS_STYLE_NAME",
        "label": "BIOS style name",
        "type": "string",
        "default": "PC1640-Compatible System BIOS",
    },
    {
        "key": "CONFIG_WEBSITE",
        "label": "Website",
        "type": "string",
        "default": "www.xt-emporium.com",
    },
    {
        "key": "CONFIG_ROS_RELEASE",
        "label": "ROS release",
        "type": "int",
        "default": 0,
        "min": 0,
        "max": 255,
    },
    {
        "key": "CONFIG_ROS_ISSUE",
        "label": "ROS issue",
        "type": "int",
        "default": 2,
        "min": 0,
        "max": 255,
    },
    {"section": "Hardware"},
    {
        "key": "CONFIG_BASE_MEMORY_KB",
        "label": "Base memory (KB)",
        "type": "int",
        "default": 608,
        "min": 256,
        "max": 640,
    },
    {
        "key": "CONFIG_HAS_PARADISE_PEGA1A",
        "label": "Paradise PEGA1A video",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_HAS_AMSTRAD_MOUSE",
        "label": "Amstrad mouse port",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_HAS_BATTERY_BACKED_RTC",
        "label": "Battery-backed RTC",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_HAS_MATH_COPROCESSOR",
        "label": "Math coprocessor",
        "type": "bool",
        "default": False,
    },
    {"section": "Ports"},
    {
        "key": "CONFIG_COM1_BASE",
        "label": "COM1 base",
        "type": "hex",
        "default": 0x03F8,
        "min": 0x0000,
        "max": 0xFFFF,
    },
    {
        "key": "CONFIG_COM2_BASE",
        "label": "COM2 base",
        "type": "hex",
        "default": 0x02F8,
        "min": 0x0000,
        "max": 0xFFFF,
    },
    {
        "key": "CONFIG_LPT1_BASE",
        "label": "LPT1 base",
        "type": "hex",
        "default": 0x0378,
        "min": 0x0000,
        "max": 0xFFFF,
    },
    {
        "key": "CONFIG_LPT2_BASE",
        "label": "LPT2 base",
        "type": "hex",
        "default": 0x03BC,
        "min": 0x0000,
        "max": 0xFFFF,
    },
    {"section": "Video"},
    {
        "key": "CONFIG_VIDEO_EQUIPMENT",
        "label": "Fallback video equipment",
        "type": "choice",
        "default": "80x25_color",
        "choices": [
            ("ega_adapter", "EGA adapter"),
            ("40x25_color", "40x25 color"),
            ("80x25_color", "80x25 color"),
            ("mono", "mono"),
        ],
    },
    {
        "key": "CONFIG_VIDEO_ATTRIBUTE",
        "label": "Text attribute",
        "type": "hex",
        "default": 0x07,
        "min": 0x00,
        "max": 0xFF,
    },
    {
        "key": "CONFIG_VIDEO_DIRECT_TEXT_INIT",
        "label": "Direct text init before PEGA ROM",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_VIDEO_USE_PC1640_SWITCH_BLOCK",
        "label": "Use PC1640 switch block",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_VIDEO_QUERY_ROM_STATE",
        "label": "Query video ROM state",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_VIDEO_FIXUP_FROM_SWITCH_BLOCK",
        "label": "Fix up video state from switch block",
        "type": "bool",
        "default": True,
    },
    {"section": "Option ROMs"},
    {
        "key": "CONFIG_VIDEO_OPTION_ROM_SCAN_ENABLED",
        "label": "Scan video option ROM",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_OPTION_ROM_SCAN_ENABLED",
        "label": "Scan non-video option ROMs",
        "type": "bool",
        "default": True,
    },
    {"section": "Floppy"},
    {
        "key": "CONFIG_HAS_FLOPPY_CONTROLLER",
        "label": "Onboard floppy controller",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_FLOPPY_SUPPORT_35DD",
        "label": "Enable 720K 3.5\" DD support",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_FLOPPY_DRIVE_A",
        "label": "Drive A type",
        "type": "choice",
        "default": "360k_525dd",
        "choices": [
            ("none", "Not installed"),
            ("360k_525dd", "360K 5.25\" DD"),
            ("720k_35dd", "720K 3.5\" DD"),
        ],
    },
    {
        "key": "CONFIG_FLOPPY_DRIVE_B",
        "label": "Drive B type",
        "type": "choice",
        "default": "360k_525dd",
        "choices": [
            ("none", "Not installed"),
            ("360k_525dd", "360K 5.25\" DD"),
            ("720k_35dd", "720K 3.5\" DD"),
        ],
    },
    {
        "key": "CONFIG_FLOPPY_ENABLE_AH08_COMPAT",
        "label": "INT 13h AH=08 compatibility path",
        "type": "bool",
        "default": True,
    },
    {"section": "IDE"},
    {
        "key": "CONFIG_XTIDE_ENABLED",
        "label": "Built-in XTIDE-compatible IDE",
        "type": "bool",
        "default": False,
    },
    {
        "key": "CONFIG_XTIDE_BASE",
        "label": "XTIDE base I/O",
        "type": "hex",
        "default": 0x0300,
        "min": 0x0200,
        "max": 0x03F0,
    },
    {
        "key": "CONFIG_XTIDE_BOOT_ENABLED",
        "label": "Try XTIDE boot in INT 19h",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_XTIDE_PROBE_MASTER",
        "label": "Probe master device",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_XTIDE_PROBE_SLAVE",
        "label": "Probe slave device",
        "type": "bool",
        "default": False,
    },
    {
        "key": "CONFIG_XTIDE_PREFER_LBA",
        "label": "Prefer LBA28 translation",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_XTIDE_TRANSLATED_HEADS",
        "label": "Reported heads",
        "type": "int",
        "default": 255,
        "min": 1,
        "max": 255,
    },
    {
        "key": "CONFIG_XTIDE_TRANSLATED_SECTORS",
        "label": "Reported sectors/track",
        "type": "int",
        "default": 63,
        "min": 1,
        "max": 63,
    },
    {
        "key": "CONFIG_XTIDE_POLL_LOOPS",
        "label": "IDE poll loop count",
        "type": "int",
        "default": 16384,
        "min": 256,
        "max": 65535,
    },
    {
        "key": "CONFIG_XTIDE_EDD_ENABLED",
        "label": "INT 13h extensions (EDD)",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_XTIDE_EDD_MAX_BLOCKS",
        "label": "EDD max sectors/request",
        "type": "int",
        "default": 127,
        "min": 1,
        "max": 127,
    },
    {"section": "RTC"},
    {
        "key": "CONFIG_UART_INIT",
        "label": "RTC UART init byte",
        "type": "hex",
        "default": 0xE3,
        "min": 0x00,
        "max": 0xFF,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_SECONDS",
        "label": "Default RTC seconds",
        "type": "int",
        "default": 0,
        "min": 0,
        "max": 59,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_MINUTES",
        "label": "Default RTC minutes",
        "type": "int",
        "default": 0,
        "min": 0,
        "max": 59,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_HOURS",
        "label": "Default RTC hours",
        "type": "int",
        "default": 0,
        "min": 0,
        "max": 23,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_DAY_OF_MONTH",
        "label": "Default RTC day",
        "type": "int",
        "default": 1,
        "min": 1,
        "max": 31,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_MONTH",
        "label": "Default RTC month",
        "type": "int",
        "default": 1,
        "min": 1,
        "max": 12,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_YEAR",
        "label": "Default RTC year",
        "type": "int",
        "default": 88,
        "min": 0,
        "max": 99,
    },
    {
        "key": "CONFIG_RTC_DEFAULT_CENTURY",
        "label": "Default RTC century",
        "type": "int",
        "default": 19,
        "min": 0,
        "max": 99,
    },
    {"section": "POST"},
    {
        "key": "CONFIG_POST_PRETTY_WAIT_PANEL",
        "label": "Pretty wait panel",
        "type": "bool",
        "default": True,
    },
    {
        "key": "CONFIG_POST_SPACE_INVADERS_SOUND",
        "label": "Space Invaders speaker effect",
        "type": "bool",
        "default": False,
    },
    {"section": "Debug"},
    {
        "key": "CONFIG_DEBUG_PORT_E9",
        "label": "Route debug to port E9",
        "type": "bool",
        "default": False,
    },
    {
        "key": "CONFIG_DEBUG_COM1",
        "label": "Route debug to COM1",
        "type": "bool",
        "default": False,
    },
    {
        "key": "CONFIG_DEBUG_VIDEO_STATE",
        "label": "Trace video state",
        "type": "bool",
        "default": False,
    },
    {
        "key": "CONFIG_DEBUG_VIDEO_OVERLAY",
        "label": "Enable video overlay debug",
        "type": "bool",
        "default": False,
    },
    {
        "key": "CONFIG_TRACE_VIDEO_COM1",
        "label": "Mirror video trace to COM1",
        "type": "bool",
        "default": False,
    },
]


OPTION_BY_KEY = {}
for item in OPTIONS:
    key = item.get("key")
    if key is not None:
        OPTION_BY_KEY[key] = item


VIDEO_EQUIPMENT_MAP = {
    "ega_adapter": "BIOS_CFG_VIDEO_EQUIPMENT_EGA_ADAPTER",
    "40x25_color": "BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR",
    "80x25_color": "BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR",
    "mono": "BIOS_CFG_VIDEO_EQUIPMENT_MONO",
}

FLOPPY_TYPE_MAP = {
    "none": ("BIOS_FLOPPY_TYPE_NONE", 0x00, "none"),
    "360k_525dd": ("BIOS_FLOPPY_TYPE_360K_525DD", 0x01, "360K"),
    "720k_35dd": ("BIOS_FLOPPY_TYPE_720K_35DD", 0x03, "720K"),
}


def default_config():
    config = {}
    for item in OPTIONS:
        key = item.get("key")
        if key is not None:
            config[key] = item["default"]
    return config


def parse_value(item, raw):
    value_type = item["type"]
    raw = raw.strip()
    if value_type == "bool":
        return raw.lower() in ("y", "yes", "1", "true")
    if value_type == "string":
        if len(raw) >= 2 and raw[0] == '"' and raw[-1] == '"':
            raw = raw[1:-1]
        return raw.replace("\\\\", "\\").replace("\\\"", '"')
    if value_type == "choice":
        return raw
    if value_type == "hex":
        return int(raw, 16)
    if value_type == "int":
        return int(raw, 10)
    raise ValueError("unsupported value type")


def format_value(item, value):
    value_type = item["type"]
    if value_type == "bool":
        return "y" if value else "n"
    if value_type == "string":
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        return '"' + escaped + '"'
    if value_type == "choice":
        return value
    if value_type == "hex":
        width = 4 if value > 0xFF else 2
        return f"0x{value:0{width}X}"
    if value_type == "int":
        return str(value)
    raise ValueError("unsupported value type")


def display_value(item, config):
    value = config[item["key"]]
    value_type = item["type"]
    if value_type == "bool":
        return "Enabled" if value else "Disabled"
    if value_type == "choice":
        for option_value, label in item["choices"]:
            if option_value == value:
                return label
    if value_type == "hex":
        width = 4 if value > 0xFF else 2
        return f"0x{value:0{width}X}"
    return str(value)


def clamp_value(item, value):
    minimum = item.get("min")
    maximum = item.get("max")
    if minimum is not None and value < minimum:
        value = minimum
    if maximum is not None and value > maximum:
        value = maximum
    return value


def allowed_choices(item, config):
    choices = item["choices"]
    if item["key"] not in ("CONFIG_FLOPPY_DRIVE_A", "CONFIG_FLOPPY_DRIVE_B"):
        return choices
    if not config["CONFIG_HAS_FLOPPY_CONTROLLER"]:
        return [choice for choice in choices if choice[0] == "none"]
    if config["CONFIG_FLOPPY_SUPPORT_35DD"]:
        return choices
    return [choice for choice in choices if choice[0] != "720k_35dd"]


def normalize_config(config):
    for item in OPTIONS:
        key = item.get("key")
        if key is None:
            continue
        if key not in config:
            config[key] = item["default"]
        if item["type"] in ("int", "hex"):
            config[key] = clamp_value(item, int(config[key]))

    if not config["CONFIG_HAS_FLOPPY_CONTROLLER"]:
        config["CONFIG_FLOPPY_DRIVE_A"] = "none"
        config["CONFIG_FLOPPY_DRIVE_B"] = "none"

    if not config["CONFIG_FLOPPY_SUPPORT_35DD"]:
        if config["CONFIG_FLOPPY_DRIVE_A"] == "720k_35dd":
            config["CONFIG_FLOPPY_DRIVE_A"] = "360k_525dd"
        if config["CONFIG_FLOPPY_DRIVE_B"] == "720k_35dd":
            config["CONFIG_FLOPPY_DRIVE_B"] = "360k_525dd"

    if config["CONFIG_FLOPPY_DRIVE_A"] == "none" and config["CONFIG_FLOPPY_DRIVE_B"] != "none":
        config["CONFIG_FLOPPY_DRIVE_A"] = config["CONFIG_FLOPPY_DRIVE_B"]
        config["CONFIG_FLOPPY_DRIVE_B"] = "none"

    for key in ("CONFIG_FLOPPY_DRIVE_A", "CONFIG_FLOPPY_DRIVE_B"):
        choices = {choice[0] for choice in allowed_choices(OPTION_BY_KEY[key], config)}
        if config[key] not in choices:
            config[key] = OPTION_BY_KEY[key]["default"]

    return config


def load_config(path):
    config = default_config()
    if not os.path.exists(path):
        return normalize_config(config)

    with open(path, "r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, raw_value = line.split("=", 1)
            key = key.strip()
            if key not in OPTION_BY_KEY:
                continue
            try:
                config[key] = parse_value(OPTION_BY_KEY[key], raw_value)
            except ValueError:
                continue
    return normalize_config(config)


def write_config(path, config):
    config = normalize_config(dict(config))
    lines = ["# FreeRos build configuration", ""]
    for item in OPTIONS:
        section = item.get("section")
        if section is not None:
            if lines[-1] != "":
                lines.append("")
            lines.append(f"# {section}")
            continue
        key = item["key"]
        lines.append(f"{key}={format_value(item, config[key])}")
    lines.append("")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines))


def drive_count(config):
    count = 0
    if config["CONFIG_FLOPPY_DRIVE_A"] != "none":
        count += 1
    if config["CONFIG_FLOPPY_DRIVE_B"] != "none":
        count += 1
    return count


def boot_floppy_image(config):
    if not config["CONFIG_HAS_FLOPPY_CONTROLLER"]:
        return ""
    drive_a = config["CONFIG_FLOPPY_DRIVE_A"]
    if drive_a == "720k_35dd":
        return "test_media/svdos-720K-disk-1.img"
    if drive_a == "360k_525dd":
        return "test_media/ibm_dos_330_disk1_360k.img"
    return ""


def sync_header(config, path):
    config = normalize_config(dict(config))
    drive_a_macro = FLOPPY_TYPE_MAP[config["CONFIG_FLOPPY_DRIVE_A"]][0]
    drive_b_macro = FLOPPY_TYPE_MAP[config["CONFIG_FLOPPY_DRIVE_B"]][0]

    header_lines = [
        "#ifndef FREEROS_CONFIG_AUTOGEN_H",
        "#define FREEROS_CONFIG_AUTOGEN_H",
        "",
        "/* Autogenerated by tools/configure.py. */",
        "",
    ]

    header_pairs = [
        ("BIOS_CFG_MACHINE_NAME", format_value(OPTION_BY_KEY["CONFIG_MACHINE_NAME"], config["CONFIG_MACHINE_NAME"])),
        ("BIOS_CFG_BIOS_BRAND", format_value(OPTION_BY_KEY["CONFIG_BIOS_BRAND"], config["CONFIG_BIOS_BRAND"])),
        ("BIOS_CFG_BIOS_STYLE_NAME", format_value(OPTION_BY_KEY["CONFIG_BIOS_STYLE_NAME"], config["CONFIG_BIOS_STYLE_NAME"])),
        ("BIOS_CFG_WEBSITE", format_value(OPTION_BY_KEY["CONFIG_WEBSITE"], config["CONFIG_WEBSITE"])),
        ("BIOS_CFG_BASE_MEMORY_KB", str(config["CONFIG_BASE_MEMORY_KB"])),
        ("BIOS_CFG_HAS_PARADISE_PEGA1A", "1" if config["CONFIG_HAS_PARADISE_PEGA1A"] else "0"),
        ("BIOS_CFG_HAS_AMSTRAD_MOUSE", "1" if config["CONFIG_HAS_AMSTRAD_MOUSE"] else "0"),
        ("BIOS_CFG_HAS_BATTERY_BACKED_RTC", "1" if config["CONFIG_HAS_BATTERY_BACKED_RTC"] else "0"),
        ("BIOS_CFG_HAS_MATH_COPROCESSOR", "1" if config["CONFIG_HAS_MATH_COPROCESSOR"] else "0"),
        ("BIOS_CFG_COM1_BASE", format_value(OPTION_BY_KEY["CONFIG_COM1_BASE"], config["CONFIG_COM1_BASE"])),
        ("BIOS_CFG_COM2_BASE", format_value(OPTION_BY_KEY["CONFIG_COM2_BASE"], config["CONFIG_COM2_BASE"])),
        ("BIOS_CFG_LPT1_BASE", format_value(OPTION_BY_KEY["CONFIG_LPT1_BASE"], config["CONFIG_LPT1_BASE"])),
        ("BIOS_CFG_LPT2_BASE", format_value(OPTION_BY_KEY["CONFIG_LPT2_BASE"], config["CONFIG_LPT2_BASE"])),
        ("BIOS_CFG_VIDEO_EQUIPMENT", VIDEO_EQUIPMENT_MAP[config["CONFIG_VIDEO_EQUIPMENT"]]),
        ("BIOS_CFG_VIDEO_ATTRIBUTE", format_value(OPTION_BY_KEY["CONFIG_VIDEO_ATTRIBUTE"], config["CONFIG_VIDEO_ATTRIBUTE"])),
        ("BIOS_CFG_VIDEO_OPTION_ROM_SCAN_ENABLED", "1" if config["CONFIG_VIDEO_OPTION_ROM_SCAN_ENABLED"] else "0"),
        ("BIOS_CFG_OPTION_ROM_SCAN_ENABLED", "1" if config["CONFIG_OPTION_ROM_SCAN_ENABLED"] else "0"),
        ("BIOS_CFG_VIDEO_DIRECT_TEXT_INIT", "1" if config["CONFIG_VIDEO_DIRECT_TEXT_INIT"] else "0"),
        ("BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK", "1" if config["CONFIG_VIDEO_USE_PC1640_SWITCH_BLOCK"] else "0"),
        ("BIOS_CFG_VIDEO_QUERY_ROM_STATE", "1" if config["CONFIG_VIDEO_QUERY_ROM_STATE"] else "0"),
        ("BIOS_CFG_VIDEO_FIXUP_FROM_SWITCH_BLOCK", "1" if config["CONFIG_VIDEO_FIXUP_FROM_SWITCH_BLOCK"] else "0"),
        ("BIOS_CFG_HAS_FLOPPY_CONTROLLER", "1" if config["CONFIG_HAS_FLOPPY_CONTROLLER"] else "0"),
        ("BIOS_CFG_FLOPPY_SUPPORT_35_DD", "1" if config["CONFIG_FLOPPY_SUPPORT_35DD"] else "0"),
        ("BIOS_CFG_FLOPPY_PROFILE", "BIOS_FLOPPY_PROFILE_CUSTOM"),
        ("BIOS_CFG_FLOPPY_TYPE_A", drive_a_macro),
        ("BIOS_CFG_FLOPPY_TYPE_B", drive_b_macro),
        ("BIOS_CFG_FLOPPY_DRIVES", str(drive_count(config))),
        ("BIOS_CFG_FLOPPY_ENABLE_AH08_COMPAT", "1" if config["CONFIG_FLOPPY_ENABLE_AH08_COMPAT"] else "0"),
        ("BIOS_CFG_XTIDE_ENABLED", "1" if config["CONFIG_XTIDE_ENABLED"] else "0"),
        ("BIOS_CFG_XTIDE_BASE", format_value(OPTION_BY_KEY["CONFIG_XTIDE_BASE"], config["CONFIG_XTIDE_BASE"])),
        ("BIOS_CFG_XTIDE_BOOT_ENABLED", "1" if config["CONFIG_XTIDE_BOOT_ENABLED"] else "0"),
        ("BIOS_CFG_XTIDE_PROBE_MASTER", "1" if config["CONFIG_XTIDE_PROBE_MASTER"] else "0"),
        ("BIOS_CFG_XTIDE_PROBE_SLAVE", "1" if config["CONFIG_XTIDE_PROBE_SLAVE"] else "0"),
        ("BIOS_CFG_XTIDE_PREFER_LBA", "1" if config["CONFIG_XTIDE_PREFER_LBA"] else "0"),
        ("BIOS_CFG_XTIDE_TRANSLATED_HEADS", str(config["CONFIG_XTIDE_TRANSLATED_HEADS"])),
        ("BIOS_CFG_XTIDE_TRANSLATED_SECTORS", str(config["CONFIG_XTIDE_TRANSLATED_SECTORS"])),
        ("BIOS_CFG_XTIDE_POLL_LOOPS", str(config["CONFIG_XTIDE_POLL_LOOPS"])),
        ("BIOS_CFG_XTIDE_EDD_ENABLED", "1" if config["CONFIG_XTIDE_EDD_ENABLED"] else "0"),
        ("BIOS_CFG_XTIDE_EDD_MAX_BLOCKS", str(config["CONFIG_XTIDE_EDD_MAX_BLOCKS"])),
        ("BIOS_CFG_ROS_RELEASE", str(config["CONFIG_ROS_RELEASE"])),
        ("BIOS_CFG_ROS_ISSUE", str(config["CONFIG_ROS_ISSUE"])),
        ("BIOS_CFG_UART_INIT", format_value(OPTION_BY_KEY["CONFIG_UART_INIT"], config["CONFIG_UART_INIT"])),
        ("BIOS_CFG_RTC_DEFAULT_SECONDS", str(config["CONFIG_RTC_DEFAULT_SECONDS"])),
        ("BIOS_CFG_RTC_DEFAULT_MINUTES", str(config["CONFIG_RTC_DEFAULT_MINUTES"])),
        ("BIOS_CFG_RTC_DEFAULT_HOURS", str(config["CONFIG_RTC_DEFAULT_HOURS"])),
        ("BIOS_CFG_RTC_DEFAULT_DAY_OF_MONTH", str(config["CONFIG_RTC_DEFAULT_DAY_OF_MONTH"])),
        ("BIOS_CFG_RTC_DEFAULT_MONTH", str(config["CONFIG_RTC_DEFAULT_MONTH"])),
        ("BIOS_CFG_RTC_DEFAULT_YEAR", str(config["CONFIG_RTC_DEFAULT_YEAR"])),
        ("BIOS_CFG_RTC_DEFAULT_CENTURY", str(config["CONFIG_RTC_DEFAULT_CENTURY"])),
        ("BIOS_CFG_POST_PRETTY_WAIT_PANEL", "1" if config["CONFIG_POST_PRETTY_WAIT_PANEL"] else "0"),
        ("BIOS_CFG_POST_SPACE_INVADERS_SOUND", "1" if config["CONFIG_POST_SPACE_INVADERS_SOUND"] else "0"),
    ]

    for name, value in header_pairs:
        header_lines.append(f"#undef {name}")
        header_lines.append(f"#define {name} {value}")

    header_lines.extend(["", "#endif", ""])
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(header_lines))


def sync_make(config, path):
    config = normalize_config(dict(config))
    lines = [
        "# Autogenerated by tools/configure.py.",
        f"CONFIG_BOOT_FLOPPY_IMAGE := {boot_floppy_image(config)}",
        f"CONFIG_FLOPPY_DRIVE_A_LABEL := {FLOPPY_TYPE_MAP[config['CONFIG_FLOPPY_DRIVE_A']][2]}",
        f"CONFIG_FLOPPY_DRIVE_B_LABEL := {FLOPPY_TYPE_MAP[config['CONFIG_FLOPPY_DRIVE_B']][2]}",
        f"CONFIG_FLOPPY_DRIVES := {drive_count(config)}",
        "CONFIG_BIOS_DEBUG_DEFS :=",
    ]

    debug_map = [
        ("CONFIG_DEBUG_PORT_E9", "-DBIOS_CFG_DEBUG_PORT_E9=1"),
        ("CONFIG_DEBUG_COM1", "-DBIOS_CFG_DEBUG_COM1=1"),
        ("CONFIG_DEBUG_VIDEO_STATE", "-DBIOS_CFG_DEBUG_VIDEO_STATE=1"),
        ("CONFIG_DEBUG_VIDEO_OVERLAY", "-DBIOS_CFG_DEBUG_VIDEO_OVERLAY=1"),
        ("CONFIG_TRACE_VIDEO_COM1", "-DBIOS_CFG_TRACE_VIDEO_COM1=1"),
    ]
    for key, define in debug_map:
        if config[key]:
            lines.append(f"CONFIG_BIOS_DEBUG_DEFS += {define}")

    lines.append("")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines))


def sync_files(config, header_path, make_path):
    os.makedirs(os.path.dirname(header_path), exist_ok=True)
    os.makedirs(os.path.dirname(make_path), exist_ok=True)
    sync_header(config, header_path)
    sync_make(config, make_path)


def set_config_values(config, assignments):
    config = normalize_config(dict(config))
    for assignment in assignments:
        if "=" not in assignment:
            raise ValueError(f"invalid assignment: {assignment}")
        key, raw_value = assignment.split("=", 1)
        key = key.strip()
        if key not in OPTION_BY_KEY:
            raise ValueError(f"unknown option: {key}")
        config[key] = parse_value(OPTION_BY_KEY[key], raw_value)
    return normalize_config(config)


def prompt_input(stdscr, prompt, current):
    height, width = stdscr.getmaxyx()
    stdscr.move(height - 2, 0)
    stdscr.clrtoeol()
    stdscr.addstr(height - 2, 0, f"{prompt} [{current}]: ")
    curses.echo()
    curses.curs_set(1)
    try:
        raw = stdscr.getstr(height - 2, len(prompt) + len(str(current)) + 4).decode("utf-8")
    finally:
        curses.noecho()
        curses.curs_set(0)
    if not raw.strip():
        return current
    return raw


def edit_option(stdscr, item, config):
    key = item["key"]
    value_type = item["type"]
    if value_type == "bool":
        config[key] = not config[key]
        return normalize_config(config)
    if value_type == "choice":
        choices = allowed_choices(item, config)
        values = [choice[0] for choice in choices]
        current_index = values.index(config[key])
        config[key] = values[(current_index + 1) % len(values)]
        return normalize_config(config)
    if value_type in ("int", "hex", "string"):
        current = display_value(item, config)
        raw = prompt_input(stdscr, item["label"], current)
        if value_type == "string":
            config[key] = raw
        elif value_type == "int":
            config[key] = clamp_value(item, int(raw, 10))
        else:
            config[key] = clamp_value(item, int(raw, 16))
        return normalize_config(config)
    return config


def menuconfig(stdscr, config):
    curses.curs_set(0)
    stdscr.keypad(True)
    index = 0

    selectable = [i for i, item in enumerate(OPTIONS) if "key" in item]
    if selectable:
        index = selectable[0]

    while True:
        stdscr.erase()
        height, width = stdscr.getmaxyx()
        stdscr.addstr(0, 0, "FreeRos menuconfig")
        stdscr.addstr(1, 0, "Arrows navigate, Enter edits, S saves, Q quits")

        row = 3
        for item_index, item in enumerate(OPTIONS):
            if row >= height - 3:
                break
            if "section" in item:
                stdscr.addstr(row, 0, f"[{item['section']}]")
            else:
                marker = ">" if item_index == index else " "
                value = display_value(item, config)
                label = f"{marker} {item['label']}"
                stdscr.addstr(row, 0, label[: max(0, width - 22)])
                if len(value) > 20:
                    value = value[:17] + "..."
                stdscr.addstr(row, max(0, width - len(value) - 1), value)
            row += 1

        item = OPTIONS[index]
        if "key" in item:
            stdscr.move(height - 1, 0)
            stdscr.clrtoeol()
            stdscr.addstr(height - 1, 0, f"{item['label']}: {display_value(item, config)}")

        stdscr.refresh()
        key = stdscr.getch()

        if key in (ord("q"), ord("Q")):
            return None
        if key in (ord("s"), ord("S")):
            return config
        if key in (curses.KEY_UP, ord("k")):
            current = selectable.index(index)
            index = selectable[(current - 1) % len(selectable)]
            continue
        if key in (curses.KEY_DOWN, ord("j")):
            current = selectable.index(index)
            index = selectable[(current + 1) % len(selectable)]
            continue
        if key in (curses.KEY_ENTER, ord("\n"), ord("\r"), ord(" ")):
            try:
                config = edit_option(stdscr, OPTIONS[index], config)
            except ValueError:
                pass


def menuconfig_text(config):
    selectable = [i for i, item in enumerate(OPTIONS) if "key" in item]
    index = 0

    while True:
        print("\n--- FreeRos menuconfig (text mode) ---\n")
        num = 1
        item_map = {}
        for item in OPTIONS:
            if "section" in item:
                print(f"  [{item['section']}]")
            else:
                key = item["key"]
                value = display_value(item, config)
                marker = ">" if OPTIONS.index(item) == selectable[index] else " "
                print(f"  {marker} {num:2d}. {item['label']:40s} {value}")
                item_map[num] = item
                num += 1

        print()
        print("Enter number to edit, S to save, Q to quit: ", end="", flush=True)
        try:
            raw = input().strip()
        except (EOFError, KeyboardInterrupt):
            return None

        if raw.lower() == "q":
            return None
        if raw.lower() == "s":
            return config

        try:
            choice = int(raw)
        except ValueError:
            continue
        if choice not in item_map:
            continue

        item = item_map[choice]
        key = item["key"]
        value_type = item["type"]

        if value_type == "bool":
            config[key] = not config[key]
            config = normalize_config(config)
        elif value_type == "choice":
            choices = allowed_choices(item, config)
            values = [c[0] for c in choices]
            labels = [c[1] for c in choices]
            print(f"  Current: {display_value(item, config)}")
            for ci, (cv, cl) in enumerate(choices, 1):
                print(f"    {ci}. {cl}")
            print("  Choice: ", end="", flush=True)
            try:
                craw = input().strip()
            except (EOFError, KeyboardInterrupt):
                continue
            try:
                ci = int(craw) - 1
                if 0 <= ci < len(values):
                    config[key] = values[ci]
                    config = normalize_config(config)
            except ValueError:
                pass
        elif value_type in ("int", "hex", "string"):
            current = display_value(item, config)
            print(f"  {item['label']} [{current}]: ", end="", flush=True)
            try:
                raw = input().strip()
            except (EOFError, KeyboardInterrupt):
                continue
            if raw:
                try:
                    if value_type == "string":
                        config[key] = raw
                    elif value_type == "int":
                        config[key] = clamp_value(item, int(raw, 10))
                    else:
                        config[key] = clamp_value(item, int(raw, 16))
                    config = normalize_config(config)
                except ValueError:
                    print("  Invalid value.")


def show_config(config):
    for item in OPTIONS:
        if "section" in item:
            print(f"[{item['section']}]")
            continue
        print(f"{item['label']}: {display_value(item, config)}")


def ensure_config_exists(path):
    if not os.path.exists(path):
        write_config(path, default_config())


def main():
    parser = argparse.ArgumentParser(description="FreeRos build configuration helper")
    subparsers = parser.add_subparsers(dest="command", required=True)

    defconfig_parser = subparsers.add_parser("defconfig")
    defconfig_parser.add_argument("--output", required=True)

    sync_parser = subparsers.add_parser("sync")
    sync_parser.add_argument("--config", required=True)
    sync_parser.add_argument("--header", required=True)
    sync_parser.add_argument("--make", required=True)

    show_parser = subparsers.add_parser("show")
    show_parser.add_argument("--config", required=True)

    set_parser = subparsers.add_parser("set")
    set_parser.add_argument("--config", required=True)
    set_parser.add_argument("assignments", nargs="+")

    menu_parser = subparsers.add_parser("menuconfig")
    menu_parser.add_argument("--config", required=True)

    args = parser.parse_args()

    if args.command == "defconfig":
        write_config(args.output, default_config())
        return 0

    if args.command == "sync":
        ensure_config_exists(args.config)
        sync_files(load_config(args.config), args.header, args.make)
        return 0

    if args.command == "show":
        ensure_config_exists(args.config)
        show_config(load_config(args.config))
        return 0

    if args.command == "set":
        ensure_config_exists(args.config)
        config = set_config_values(load_config(args.config), args.assignments)
        write_config(args.config, config)
        return 0

    if args.command == "menuconfig":
        ensure_config_exists(args.config)
        config = load_config(args.config)
        use_curses = (HAS_CURSES
                      and sys.stdin.isatty()
                      and sys.stdout.isatty())
        if use_curses:
            try:
                result = curses.wrapper(menuconfig, config)
            except curses.error:
                print("curses failed, falling back to text mode",
                      file=sys.stderr)
                result = menuconfig_text(config)
        else:
            if not sys.stdin.isatty():
                print("menuconfig requires an interactive terminal",
                      file=sys.stderr)
                return 1
            result = menuconfig_text(config)
        if result is not None:
            write_config(args.config, result)
        return 0

    return 1


if __name__ == "__main__":
    sys.exit(main())
