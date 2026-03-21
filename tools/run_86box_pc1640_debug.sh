#!/usr/bin/env bash

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD_SCRIPT="$ROOT_DIR/tools/build_86box_debug.sh"
REPO_DIR="${EIGHTYSIXBOX_REPO:-/tmp/86Box_repo}"
BUILD_DIR="${EIGHTYSIXBOX_BUILD_DIR:-$REPO_DIR/build/pc1640-debug}"
EIGHTYSIXBOX_BIN="${EIGHTYSIXBOX_BIN:-$BUILD_DIR/src/86Box}"
VM_ROOT="${EIGHTYSIXBOX_VM_ROOT:-$ROOT_DIR/build/86box-vm}"
ROM_ROOT="${EIGHTYSIXBOX_ROM_ROOT:-$ROOT_DIR/build/86box-roms}"
CFG_PATH="${EIGHTYSIXBOX_CFG:-$VM_ROOT/pc1640.cfg}"
LOG_PATH="${EIGHTYSIXBOX_LOG:-$VM_ROOT/86box.log}"
VIDEO_ROM="${PC1640_VIDEO_ROM:-$ROOT_DIR/Original-firmware/40100}"
BIOS_EVEN="${PC1640_SYSTEM_ROM_EVEN:-$ROOT_DIR/build/40044.v3}"
BIOS_ODD="${PC1640_SYSTEM_ROM_ODD:-$ROOT_DIR/build/40043.v3}"
CAPTURE_COM1="${EIGHTYSIXBOX_CAPTURE_COM1:-0}"
SERIAL_LOG_PATH="${EIGHTYSIXBOX_SERIAL_LOG:-$VM_ROOT/com1.log}"
SERIAL_STDERR_PATH="${EIGHTYSIXBOX_SERIAL_STDERR:-$VM_ROOT/86box.stderr.log}"
AUTO_RESUME="${EIGHTYSIXBOX_AUTO_RESUME:-1}"
GDB_PORT="${EIGHTYSIXBOX_GDB_PORT:-12345}"
GFXCARD="${EIGHTYSIXBOX_GFXCARD:-internal}"
VIDEO_DEVICE_SECTION="${EIGHTYSIXBOX_VIDEO_DEVICE_SECTION:-}"
VIDEO_DEVICE_CONFIG="${EIGHTYSIXBOX_VIDEO_DEVICE_CONFIG:-}"
VID_RENDERER="${EIGHTYSIXBOX_VID_RENDERER:-software}"
SERIAL_MODE="${EIGHTYSIXBOX_SERIAL_MODE:-4}"
SERIAL_BAUD="${EIGHTYSIXBOX_SERIAL_BAUD:-9600}"
SERIAL_DATA_BITS="${EIGHTYSIXBOX_SERIAL_DATA_BITS:-8}"
SERIAL_STOP_BITS="${EIGHTYSIXBOX_SERIAL_STOP_BITS:-1}"
CONFIG_FILE="${EIGHTYSIXBOX_CONFIG_FILE:-}"
XTIDE_ENABLED="${EIGHTYSIXBOX_XTIDE_ENABLED:-0}"
XTIDE_BIOS="${EIGHTYSIXBOX_XTIDE_BIOS:-none}"
XTIDE_BIOS_ADDR="${EIGHTYSIXBOX_XTIDE_BIOS_ADDR:-0xd0000}"
XTIDE_BASE_IO="${EIGHTYSIXBOX_XTIDE_BASE_IO:-0x300}"
XTIDE_ROM_SOURCE_DIR="${EIGHTYSIXBOX_XTIDE_ROM_SOURCE_DIR:-/tmp/86Box_roms/hdd/xtide}"
IDE_HDD_IMAGE="${EIGHTYSIXBOX_IDE_HDD_IMAGE:-}"
IDE_HDD_CYLINDERS="${EIGHTYSIXBOX_IDE_HDD_CYLINDERS:-306}"
IDE_HDD_HEADS="${EIGHTYSIXBOX_IDE_HDD_HEADS:-4}"
IDE_HDD_SPT="${EIGHTYSIXBOX_IDE_HDD_SPT:-17}"
IDE_CDROM_IMAGE="${EIGHTYSIXBOX_IDE_CDROM_IMAGE:-}"
IDE_CDROM_CHANNEL="${EIGHTYSIXBOX_IDE_CDROM_CHANNEL:-0:1}"
RUN_META_PATH="${EIGHTYSIXBOX_RUN_META:-$VM_ROOT/run.meta}"
SERIAL_DEVICE_PATH="$SERIAL_LOG_PATH"
FLOPPY_IMAGE=
STAGED_FLOPPY_IMAGE=
STAGED_IDE_HDD_IMAGE=
STAGED_IDE_CDROM_IMAGE=
HEADLESS=0
TIMEOUT_SECS=

format_86box_hex() {
    local width=$1
    local value=$2
    local parsed=

    case "$value" in
        0x*|0X*)
            parsed=$((16#${value#0[xX]}))
            ;;
        *)
            parsed=$((10#$value))
            ;;
    esac

    printf "%0${width}X" "$parsed"
}

usage() {
    cat <<'EOF'
Usage: tools/run_86box_pc1640_debug.sh [options]

Options:
  --image PATH       Attach PATH as floppy A:
  --headless         Run with dummy SDL video/audio drivers
  --timeout SECS     Stop 86Box after SECS seconds
  --help             Show this help

Environment overrides:
  EIGHTYSIXBOX_REPO
  EIGHTYSIXBOX_BUILD_DIR
  EIGHTYSIXBOX_BIN
  EIGHTYSIXBOX_VM_ROOT
  EIGHTYSIXBOX_ROM_ROOT
  EIGHTYSIXBOX_CFG
  EIGHTYSIXBOX_LOG
  EIGHTYSIXBOX_CAPTURE_COM1
  EIGHTYSIXBOX_SERIAL_LOG
  EIGHTYSIXBOX_SERIAL_STDERR
  EIGHTYSIXBOX_AUTO_RESUME
  EIGHTYSIXBOX_GDB_PORT
  EIGHTYSIXBOX_GFXCARD
  EIGHTYSIXBOX_VIDEO_DEVICE_SECTION
  EIGHTYSIXBOX_VIDEO_DEVICE_CONFIG
  EIGHTYSIXBOX_VID_RENDERER
  EIGHTYSIXBOX_SERIAL_MODE
  EIGHTYSIXBOX_SERIAL_BAUD
  EIGHTYSIXBOX_SERIAL_DATA_BITS
  EIGHTYSIXBOX_SERIAL_STOP_BITS
  EIGHTYSIXBOX_CONFIG_FILE
  EIGHTYSIXBOX_XTIDE_ENABLED
  EIGHTYSIXBOX_XTIDE_BIOS
  EIGHTYSIXBOX_XTIDE_BIOS_ADDR
  EIGHTYSIXBOX_XTIDE_BASE_IO
  EIGHTYSIXBOX_XTIDE_ROM_SOURCE_DIR
  EIGHTYSIXBOX_IDE_HDD_IMAGE
  EIGHTYSIXBOX_IDE_HDD_CYLINDERS
  EIGHTYSIXBOX_IDE_HDD_HEADS
  EIGHTYSIXBOX_IDE_HDD_SPT
  EIGHTYSIXBOX_RUN_META
  PC1640_SYSTEM_ROM_EVEN
  PC1640_SYSTEM_ROM_ODD
  PC1640_VIDEO_ROM
EOF
}

write_run_metadata() {
    mkdir -p "$(dirname -- "$RUN_META_PATH")"
    {
        printf 'timestamp_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf '86box_bin=%s\n' "$EIGHTYSIXBOX_BIN"
        printf 'vm_root=%s\n' "$VM_ROOT"
        printf 'rom_root=%s\n' "$ROM_ROOT"
        printf 'cfg_path=%s\n' "$CFG_PATH"
        printf 'log_path=%s\n' "$LOG_PATH"
        printf 'serial_stderr_path=%s\n' "$SERIAL_STDERR_PATH"
        printf 'system_rom_even=%s\n' "$BIOS_EVEN"
        printf 'system_rom_odd=%s\n' "$BIOS_ODD"
        printf 'video_rom=%s\n' "$VIDEO_ROM"
        printf 'gfxcard=%s\n' "$GFXCARD"
        printf 'vid_renderer=%s\n' "$VID_RENDERER"
        printf 'capture_com1=%s\n' "$CAPTURE_COM1"
        printf 'serial_mode=%s\n' "$SERIAL_MODE"
        printf 'serial_baud=%s\n' "$SERIAL_BAUD"
        printf 'serial_data_bits=%s\n' "$SERIAL_DATA_BITS"
        printf 'serial_stop_bits=%s\n' "$SERIAL_STOP_BITS"
        printf 'xtide_enabled=%s\n' "$XTIDE_ENABLED"
        printf 'xtide_bios=%s\n' "$XTIDE_BIOS"
        printf 'xtide_bios_addr=%s\n' "$XTIDE_BIOS_ADDR"
        printf 'xtide_bios_addr_cfg=%s\n' "$XTIDE_BIOS_ADDR_CFG"
        printf 'xtide_base_io=%s\n' "$XTIDE_BASE_IO"
        printf 'xtide_base_io_cfg=%s\n' "$XTIDE_BASE_IO_CFG"
        printf 'xtide_rom_source_dir=%s\n' "$XTIDE_ROM_SOURCE_DIR"
        printf 'serial_log_path=%s\n' "$SERIAL_LOG_PATH"
        printf 'serial_device_path=%s\n' "$SERIAL_DEVICE_PATH"
        printf 'auto_resume=%s\n' "$AUTO_RESUME"
        printf 'gdb_port=%s\n' "$GDB_PORT"
        printf 'headless=%s\n' "$HEADLESS"
        printf 'timeout_secs=%s\n' "${TIMEOUT_SECS:-}"
        printf 'floppy_image=%s\n' "${FLOPPY_IMAGE:-}"
        printf 'staged_floppy_image=%s\n' "${STAGED_FLOPPY_IMAGE:-}"
        printf 'ide_hdd_image=%s\n' "${IDE_HDD_IMAGE:-}"
        printf 'staged_ide_hdd_image=%s\n' "${STAGED_IDE_HDD_IMAGE:-}"
        printf 'ide_hdd_cylinders=%s\n' "$IDE_HDD_CYLINDERS"
        printf 'ide_hdd_heads=%s\n' "$IDE_HDD_HEADS"
        printf 'ide_hdd_spt=%s\n' "$IDE_HDD_SPT"
        printf 'ide_cdrom_image=%s\n' "${IDE_CDROM_IMAGE:-}"
        printf 'staged_ide_cdrom_image=%s\n' "${STAGED_IDE_CDROM_IMAGE:-}"
        printf 'ide_cdrom_channel=%s\n' "$IDE_CDROM_CHANNEL"
    } > "$RUN_META_PATH"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --image)
            if [ $# -lt 2 ]; then
                echo "missing argument for --image" >&2
                exit 1
            fi
            FLOPPY_IMAGE=$2
            shift 2
            ;;
        --headless)
            HEADLESS=1
            shift
            ;;
        --timeout)
            if [ $# -lt 2 ]; then
                echo "missing argument for --timeout" >&2
                exit 1
            fi
            TIMEOUT_SECS=$2
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ ! -x "$EIGHTYSIXBOX_BIN" ]; then
    "$BUILD_SCRIPT" >/dev/null
fi

MAKE_ARGS=()
if [ -n "$CONFIG_FILE" ]; then
    MAKE_ARGS+=("CONFIG_FILE=$CONFIG_FILE")
fi
if [ -n "${BIOS_DEBUG_DEFS:-}" ]; then
    MAKE_ARGS+=("BIOS_DEBUG_DEFS=$BIOS_DEBUG_DEFS")
fi
(cd "$ROOT_DIR" && make "${MAKE_ARGS[@]}" all >/dev/null)

if [ -z "$VIDEO_DEVICE_SECTION" ] && [ -z "$VIDEO_DEVICE_CONFIG" ]; then
    case "$GFXCARD" in
        ega)
            VIDEO_DEVICE_SECTION="IBM EGA"
            VIDEO_DEVICE_CONFIG=$'memory = 256\nmonitor_type = 9'
            ;;
    esac
fi

mkdir -p "$VM_ROOT" "$ROM_ROOT/machines/pc1640"

cp "$BIOS_EVEN" "$ROM_ROOT/machines/pc1640/40044.v3"
cp "$BIOS_ODD" "$ROM_ROOT/machines/pc1640/40043.v3"
cp "$VIDEO_ROM" "$ROM_ROOT/machines/pc1640/40100"

if [ "$XTIDE_ENABLED" -eq 1 ] && [ "$XTIDE_BIOS" != "none" ]; then
    mkdir -p "$ROM_ROOT/hdd/xtide"
    cp "$XTIDE_ROM_SOURCE_DIR/ide_xt.bin" "$ROM_ROOT/hdd/xtide/ide_xt.bin"
    cp "$XTIDE_ROM_SOURCE_DIR/ide_xtp.bin" "$ROM_ROOT/hdd/xtide/ide_xtp.bin"
fi

if [ -n "$FLOPPY_IMAGE" ]; then
    STAGED_FLOPPY_IMAGE=$FLOPPY_IMAGE
    case "$FLOPPY_IMAGE" in
        *" "*|*$'\t'*)
            STAGED_FLOPPY_IMAGE="$VM_ROOT/floppy-a.img"
            ln -sf "$FLOPPY_IMAGE" "$STAGED_FLOPPY_IMAGE"
            ;;
    esac
fi

if [ -n "$IDE_HDD_IMAGE" ]; then
    STAGED_IDE_HDD_IMAGE=$IDE_HDD_IMAGE
    case "$IDE_HDD_IMAGE" in
        *" "*|*$'\t'*)
            STAGED_IDE_HDD_IMAGE="$VM_ROOT/hdd-01.img"
            ln -sf "$IDE_HDD_IMAGE" "$STAGED_IDE_HDD_IMAGE"
            ;;
    esac
fi

if [ -n "$IDE_CDROM_IMAGE" ]; then
    STAGED_IDE_CDROM_IMAGE=$IDE_CDROM_IMAGE
    case "$IDE_CDROM_IMAGE" in
        *" "*|*$'\t'*)
            STAGED_IDE_CDROM_IMAGE="$VM_ROOT/cdrom.iso"
            ln -sf "$IDE_CDROM_IMAGE" "$STAGED_IDE_CDROM_IMAGE"
            ;;
    esac
fi

XTIDE_BIOS_ADDR_CFG=$(format_86box_hex 5 "$XTIDE_BIOS_ADDR")
XTIDE_BASE_IO_CFG=$(format_86box_hex 4 "$XTIDE_BASE_IO")

if [ "$CAPTURE_COM1" -eq 1 ]; then
    case "$SERIAL_LOG_PATH" in
        *" "*|*$'\t'*)
            SERIAL_DEVICE_PATH=$(mktemp /tmp/86box-com1.XXXXXX.log)
            rm -f "$SERIAL_DEVICE_PATH"
            ln -sf "$SERIAL_LOG_PATH" "$SERIAL_DEVICE_PATH"
            ;;
    esac
fi

cat > "$CFG_PATH" <<EOF
[General]
vid_renderer = ${VID_RENDERER}
window_remember = 0
hide_status_bar = 1
hide_tool_bar = 1
sound_muted = 1

[Machine]
machine = pc1640
mem_size = 640
cpu_use_dynarec = 0
time_sync = disabled

[Video]
gfxcard = ${GFXCARD}
monitor_edid = 0

[Input devices]
keyboard_type = keyboard_pc_xt
mouse_type = none
EOF

if [ -n "$VIDEO_DEVICE_SECTION" ] && [ -n "$VIDEO_DEVICE_CONFIG" ]; then
    printf '\n[%s]\n%s\n' "$VIDEO_DEVICE_SECTION" "$VIDEO_DEVICE_CONFIG" >> "$CFG_PATH"
fi

if [ "$CAPTURE_COM1" -eq 1 ]; then
    cat >> "$CFG_PATH" <<EOF

[Ports (COM & LPT)]
serial1_enabled = 1
serial1_passthrough_enabled = 1

[Serial Passthrough Device #1]
mode = ${SERIAL_MODE}
baudrate = ${SERIAL_BAUD}
data_bits = ${SERIAL_DATA_BITS}
stop_bits = ${SERIAL_STOP_BITS}
output_file_path = ${SERIAL_DEVICE_PATH}
EOF
fi

if [ "$XTIDE_ENABLED" -eq 1 ]; then
    cat >> "$CFG_PATH" <<EOF

[Storage controllers]
hdc_1 = xtide
EOF
    if [ "$XTIDE_BIOS" = "none" ]; then
        cat >> "$CFG_PATH" <<EOF

[PC/XT XTIDE #1]
bios = none
base = ${XTIDE_BASE_IO_CFG}
EOF
    else
        cat >> "$CFG_PATH" <<EOF

[PC/XT XTIDE #1]
bios = ${XTIDE_BIOS}
bios_addr = ${XTIDE_BIOS_ADDR_CFG}
base = ${XTIDE_BASE_IO_CFG}
EOF
    fi
fi

if [ -n "$STAGED_IDE_HDD_IMAGE" ]; then
    cat >> "$CFG_PATH" <<EOF

[Hard disks]
hdd_01_parameters = ${IDE_HDD_SPT}, ${IDE_HDD_HEADS}, ${IDE_HDD_CYLINDERS}, 0, ide
hdd_01_ide_channel = 0:0
hdd_01_fn = ${STAGED_IDE_HDD_IMAGE}
EOF
fi

if [ -n "$STAGED_IDE_CDROM_IMAGE" ]; then
    cat >> "$CFG_PATH" <<EOF

[CD-ROM drives]
cdrom_01_host_drive = 0
cdrom_01_parameters = 1, atapi
cdrom_01_ide_channel = ${IDE_CDROM_CHANNEL}
cdrom_01_image_path = ${STAGED_IDE_CDROM_IMAGE}
cdrom_01_type = 86box_cd-rom
EOF
fi

write_run_metadata

set -- "$EIGHTYSIXBOX_BIN" \
    -P "$VM_ROOT" \
    -R "$ROM_ROOT" \
    -C "$CFG_PATH" \
    -L "$LOG_PATH" \
    -N

if [ -n "$STAGED_FLOPPY_IMAGE" ]; then
    set -- "$@" -I "A:$STAGED_FLOPPY_IMAGE"
fi

run_86box() {
    if [ "$HEADLESS" -eq 1 ]; then
        env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software ALSOFT_DRIVERS=null "$@"
        return
    fi

    "$@"
}

auto_resume_gdb_stub() {
    local ready=0
    local _=
    local stub_port=

    if [ "$AUTO_RESUME" -eq 0 ]; then
        return
    fi

    for _ in $(seq 1 100); do
        if [ -f "$LOG_PATH" ] && grep -q "GDB Stub: Listening on port $GDB_PORT" "$LOG_PATH"; then
            ready=1
            break
        fi
        sleep 0.1
    done

    if [ "$ready" -eq 0 ]; then
        return
    fi

    stub_port=$(sed -n 's/.*GDB Stub: Listening on port \([0-9][0-9]*\).*/\1/p' \
                     "$LOG_PATH" | tail -n 1)
    if [ -z "$stub_port" ]; then
        stub_port=$GDB_PORT
    fi

    python3 - "$stub_port" >/dev/null 2>&1 <<'PY' || true
import socket
import sys


def checksum(payload):
    return sum(payload) & 0xFF


def send_packet(sock, payload):
    packet = b"$" + payload + b"#" + f"{checksum(payload):02x}".encode("ascii")
    sock.sendall(packet)


def recv_packet(sock):
    while True:
        ch = sock.recv(1)
        if not ch:
            raise EOFError
        if ch == b"$":
            break
        if ch == b"+":
            continue
    payload = bytearray()
    while True:
        ch = sock.recv(1)
        if not ch:
            raise EOFError
        if ch == b"#":
            trailer = sock.recv(2)
            if len(trailer) != 2:
                raise EOFError
            sock.sendall(b"+")
            return bytes(payload)
        payload.extend(ch)


port = int(sys.argv[1], 10)
with socket.create_connection(("127.0.0.1", port), timeout=2.0) as sock:
    sock.settimeout(2.0)
    recv_packet(sock)
    send_packet(sock, b"c")
PY
}

run_86box_managed() {
    local emu_pid
    local rc=0
    local deadline=

    rm -f "$SERIAL_LOG_PATH" "$SERIAL_STDERR_PATH"
    if [ "$HEADLESS" -eq 1 ]; then
        env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software ALSOFT_DRIVERS=null "$@" \
            2>"$SERIAL_STDERR_PATH" &
    else
        "$@" 2>"$SERIAL_STDERR_PATH" &
    fi
    emu_pid=$!

    auto_resume_gdb_stub

    if [ -n "$TIMEOUT_SECS" ]; then
        deadline=$((SECONDS + TIMEOUT_SECS))
        while kill -0 "$emu_pid" 2>/dev/null; do
            if [ "$SECONDS" -ge "$deadline" ]; then
                kill "$emu_pid" 2>/dev/null || true
                wait "$emu_pid" 2>/dev/null || true
                rc=0
                break
            fi
            sleep 0.1
        done
    fi

    if kill -0 "$emu_pid" 2>/dev/null; then
        wait "$emu_pid"
        rc=$?
    fi

    if [ "$SERIAL_DEVICE_PATH" != "$SERIAL_LOG_PATH" ]; then
        rm -f "$SERIAL_DEVICE_PATH"
    fi

    return "$rc"
}

if [ "$CAPTURE_COM1" -eq 1 ] || [ "$AUTO_RESUME" -eq 1 ] || [ -n "$TIMEOUT_SECS" ]; then
    run_86box_managed "$@"
    exit $?
fi

if [ "$HEADLESS" -eq 1 ]; then
    exec env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software ALSOFT_DRIVERS=null "$@"
fi

exec "$@"
