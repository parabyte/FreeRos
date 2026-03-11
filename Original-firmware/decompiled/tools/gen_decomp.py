from pathlib import Path
import re
from capstone import *
from capstone.x86 import *

md = Cs(CS_ARCH_X86, CS_MODE_16)
md.detail = True

PORT_NAMES = {
    0x20: 'PIC1_CMD',
    0x21: 'PIC1_DATA',
    0xA0: 'PIC2_CMD',
    0xA1: 'PIC2_DATA',
    0x40: 'PIT_CH0',
    0x41: 'PIT_CH1',
    0x42: 'PIT_CH2',
    0x43: 'PIT_MODE',
    0x60: 'KBD_DATA',
    0x61: 'PPI_PORT_B',
    0x64: 'KBD_STATUS',
    0x3F2: 'FDC_DOR',
    0x3F4: 'FDC_MSR',
    0x3F5: 'FDC_DATA',
    0x3F7: 'FDC_DIR_CCR',
    0x3B4: 'MDA_ADDR',
    0x3B5: 'MDA_DATA',
    0x70: 'CMOS_ADDR',
    0x71: 'CMOS_DATA',
    0x3C0: 'VGA_ATTR_ADDR',
    0x3C1: 'VGA_ATTR_DATA',
    0x3C2: 'VGA_MISC_OUTPUT',
    0x3C4: 'VGA_SEQ_ADDR',
    0x3C5: 'VGA_SEQ_DATA',
    0x3C6: 'VGA_DAC_MASK',
    0x3C7: 'VGA_DAC_READ_INDEX',
    0x3C8: 'VGA_DAC_WRITE_INDEX',
    0x3C9: 'VGA_DAC_DATA',
    0x3CE: 'VGA_GC_ADDR',
    0x3CF: 'VGA_GC_DATA',
    0x3D4: 'VGA_CRTC_ADDR',
    0x3D5: 'VGA_CRTC_DATA',
    0x3DA: 'VGA_INPUT_STATUS_1',
    0x3D8: 'CGA_MODE',
    0x3D9: 'CGA_COLOR',
}

PORT_COMMENTS = {
    0x20: '8259 PIC master command',
    0x21: '8259 PIC master data',
    0xA0: '8259 PIC slave command',
    0xA1: '8259 PIC slave data',
    0x3F2: 'Floppy controller DOR',
    0x3F4: 'Floppy controller MSR',
    0x3F5: 'Floppy controller DATA',
    0x3F7: 'Floppy controller DIR/CCR',
    0x3D4: 'CRT controller index',
    0x3D5: 'CRT controller data',
    0x3D8: 'CGA mode control',
    0x3DA: 'CGA status',
    0x3B4: 'MDA controller index',
    0x3B5: 'MDA controller data',
    0x40: 'PIT channel 0',
    0x41: 'PIT channel 1',
    0x42: 'PIT channel 2',
    0x43: 'PIT mode/command',
    0x60: 'Keyboard data',
    0x61: 'PPI port B (speaker/port)',
    0x64: 'Keyboard status',
}

INT_DESC = {
    0x05: 'Print Screen',
    0x08: 'System Timer',
    0x09: 'Keyboard',
    0x0A: 'IRQ2 Cascade (XT)',
    0x0B: 'COM2 (IRQ3)',
    0x0C: 'COM1 (IRQ4)',
    0x0D: 'LPT2 (IRQ5)',
    0x0E: 'Floppy (IRQ6)',
    0x0F: 'LPT1 (IRQ7)',
    0x10: 'Video Services',
    0x11: 'Equipment List',
    0x12: 'Conventional Memory Size',
    0x13: 'Disk Services',
    0x14: 'Serial Services',
    0x15: 'System Services',
    0x16: 'Keyboard Services',
    0x17: 'Printer Services',
    0x18: 'ROM BASIC / Boot Failure',
    0x19: 'Bootstrap Loader',
    0x1A: 'Time-of-Day',
    0x1B: 'Ctrl-Break',
    0x1C: 'User Timer Tick',
    0x1D: 'Video Parameter Table',
    0x1E: 'Diskette Parameter Table',
    0x1F: 'Video Graphics Table',
}

JCC_COND = {
    'je': 'ZF=1', 'jz': 'ZF=1',
    'jne': 'ZF=0', 'jnz': 'ZF=0',
    'jae': 'CF=0', 'jnc': 'CF=0',
    'jb': 'CF=1', 'jc': 'CF=1',
    'jbe': 'CF=1 or ZF=1',
    'ja': 'CF=0 and ZF=0',
    'jl': 'SF!=OF', 'jnge': 'SF!=OF',
    'jle': 'ZF=1 or SF!=OF',
    'jg': 'ZF=0 and SF==OF',
    'jge': 'SF==OF',
    'jo': 'OF=1',
    'jno': 'OF=0',
    'js': 'SF=1',
    'jns': 'SF=0',
    'jp': 'PF=1',
    'jnp': 'PF=0',
}

REG16 = { 'ax','bx','cx','dx','si','di','bp','sp','ip','cs','ds','es','ss' }
REG8L = { 'al','bl','cl','dl' }
REG8H = { 'ah','bh','ch','dh' }


def follow_target(ins):
    m = ins.mnemonic
    if m in ('ljmp','lcall'):
        if len(ins.operands)==2 and all(op.type==X86_OP_IMM for op in ins.operands):
            seg = ins.operands[0].imm & 0xFFFF
            off = ins.operands[1].imm & 0xFFFF
            return (seg<<4) + off
    if m in ('jmp','call'):
        if ins.operands and ins.operands[0].type==X86_OP_IMM:
            return ins.operands[0].imm
    return None


def decode_reachable(code: bytes, base: int, entrypoints):
    code_map = {}
    to_process = list(entrypoints)
    visited = set()
    max_addr = base + len(code)
    def in_range(addr):
        return base <= addr < max_addr
    while to_process:
        addr = to_process.pop()
        if addr in visited or not in_range(addr):
            continue
        visited.add(addr)
        cur = addr
        while in_range(cur) and cur not in code_map:
            insns = list(md.disasm(code[cur-base:], cur, 1))
            if not insns:
                break
            ins = insns[0]
            code_map[cur] = ins
            cur_next = cur + ins.size
            m = ins.mnemonic
            if m in ('ret','retf','iret'):
                break
            if m in ('jmp','ljmp'):
                tgt = follow_target(ins)
                if tgt is not None and in_range(tgt):
                    to_process.append(tgt)
                break
            if m in ('call','lcall'):
                tgt = follow_target(ins)
                if tgt is not None and in_range(tgt):
                    to_process.append(tgt)
            if m.startswith('j') or m in ('loop','loope','loopne','jcxz'):
                if ins.operands and ins.operands[0].type == X86_OP_IMM:
                    tgt = ins.operands[0].imm
                    if in_range(tgt):
                        to_process.append(tgt)
                cur = cur_next
                continue
            cur = cur_next
    return code_map


def ascii_comment(bs):
    return ''.join(chr(b) if 32 <= b < 127 else '.' for b in bs)


def reg_name(ins, reg_id):
    return ins.reg_name(reg_id)


def mem_expr(ins, op):
    seg = None
    if op.mem.segment != 0:
        seg = reg_name(ins, op.mem.segment)
    base = reg_name(ins, op.mem.base) if op.mem.base != 0 else None
    index = reg_name(ins, op.mem.index) if op.mem.index != 0 else None
    scale = op.mem.scale
    disp = op.mem.disp
    parts = []
    if base:
        parts.append(base)
    if index:
        if scale != 1:
            parts.append(f"{index}*{scale}")
        else:
            parts.append(index)
    if disp:
        if disp > 0:
            parts.append(f"0x{disp:x}")
        else:
            parts.append(f"-0x{(-disp):x}")
    expr = ' + '.join(parts) if parts else f"0x{disp & 0xFFFF:x}"
    return seg, expr


def op_to_expr(ins, op, consts):
    if op.type == X86_OP_REG:
        return reg_name(ins, op.reg)
    if op.type == X86_OP_IMM:
        return f"0x{op.imm & 0xFFFF:x}"
    if op.type == X86_OP_MEM:
        seg, expr = mem_expr(ins, op)
        size = op.size
        memfn = 'mem8' if size == 1 else 'mem16'
        seg_expr = seg if seg else 'ds/ss'
        return f"{memfn}({seg_expr}:{expr})"
    return '???'


def mem_region_comment(seg_val, offset):
    # Basic BDA / IVT hints
    if seg_val is None:
        return ''
    if seg_val == 0x0000:
        if offset < 0x400:
            return 'IVT'
        if 0x400 <= offset < 0x500:
            return 'BDA'
    if seg_val == 0x0040:
        return 'BDA'
    return ''


def comment_for_ins(ins, consts):
    m = ins.mnemonic
    if m in ('repe scasw', 'repne stosw'):
        if m.startswith('repe'):
            return 'repeat SCASW while ZF=1 and CX>0'
        return 'repeat STOSW CX times (REPNE behaves like REP for STOSW)'

    ops = ins.operands
    def op(i):
        return ops[i] if i < len(ops) else None
    def expr(i):
        o = op(i)
        if not o:
            return ''
        return op_to_expr(ins, o, consts)

    if m == 'mov' and len(ops) == 2:
        return f"{expr(0)} = {expr(1)}"
    if m == 'xchg' and len(ops) == 2:
        return f"swap {expr(0)} <-> {expr(1)}"
    if m == 'add' and len(ops) == 2:
        return f"{expr(0)} += {expr(1)}; flags"
    if m == 'sub' and len(ops) == 2:
        return f"{expr(0)} -= {expr(1)}; flags"
    if m == 'cmp' and len(ops) == 2:
        return f"flags = {expr(0)} - {expr(1)}"
    if m == 'and' and len(ops) == 2:
        return f"{expr(0)} &= {expr(1)}; flags"
    if m == 'or' and len(ops) == 2:
        return f"{expr(0)} |= {expr(1)}; flags"
    if m == 'xor' and len(ops) == 2:
        return f"{expr(0)} ^= {expr(1)}; flags"
    if m == 'test' and len(ops) == 2:
        return f"flags = {expr(0)} & {expr(1)}"
    if m == 'inc' and len(ops) == 1:
        return f"{expr(0)}++ ; flags (CF unchanged)"
    if m == 'dec' and len(ops) == 1:
        return f"{expr(0)}-- ; flags (CF unchanged)"
    if m == 'shl' and len(ops) == 2:
        return f"{expr(0)} <<= {expr(1)}; flags"
    if m == 'shr' and len(ops) == 2:
        return f"{expr(0)} >>= {expr(1)}; flags"
    if m == 'push' and len(ops) == 1:
        return f"push {expr(0)}"
    if m == 'pop' and len(ops) == 1:
        return f"pop -> {expr(0)}"
    if m in ('call','lcall') and len(ops) >= 1:
        return f"call {expr(0)}"
    if m in ('ret','retf'):
        return "return"
    if m == 'int' and len(ops)==1:
        intno = op(0).imm & 0xFF
        desc = INT_DESC.get(intno)
        if desc:
            return f"BIOS interrupt 0x{intno:02X} ({desc})"
        return f"BIOS interrupt 0x{intno:02X}"
    if m == 'cli':
        return "IF=0 (disable maskable interrupts)"
    if m == 'sti':
        return "IF=1 (enable maskable interrupts)"
    if m == 'in' and len(ops)==2:
        port = None
        if op(1).type == X86_OP_IMM:
            port = op(1).imm & 0xFFFF
        elif op(1).type == X86_OP_REG:
            r = reg_name(ins, op(1).reg)
            if r in consts:
                port = consts[r]
        if port is not None and port in PORT_NAMES:
            return f"{expr(0)} = IO[{PORT_NAMES[port]}]"
        if port is not None:
            return f"{expr(0)} = IO[0x{port:x}]"
        return f"{expr(0)} = IO[{expr(1)}]"
    if m == 'out' and len(ops)==2:
        port = None
        if op(0).type == X86_OP_IMM:
            port = op(0).imm & 0xFFFF
        elif op(0).type == X86_OP_REG:
            r = reg_name(ins, op(0).reg)
            if r in consts:
                port = consts[r]
        if port is not None and port in PORT_NAMES:
            return f"IO[{PORT_NAMES[port]}] = {expr(1)}"
        if port is not None:
            return f"IO[0x{port:x}] = {expr(1)}"
        return f"IO[{expr(0)}] = {expr(1)}"
    if m == 'les' and len(ops)==2:
        return f"load far ptr: {expr(0)}=mem16, ES=mem16+2"
    if m == 'loop' and len(ops)==1:
        return f"CX-- ; if CX!=0 jump {expr(0)}"
    if m == 'jcxz' and len(ops)==1:
        return f"if CX==0 jump {expr(0)}"
    if m in ('jmp','ljmp') and len(ops)>=1:
        return f"jump {expr(0)}"
    if m.startswith('j') and len(ops)==1:
        cond = JCC_COND.get(m, m)
        return f"if {cond} then jump {expr(0)}"

    return ''


def update_consts(ins, consts):
    m = ins.mnemonic
    ops = ins.operands
    def set_reg(r, val):
        consts[r] = val & 0xFFFF
        if r in ('ax','bx','cx','dx'):
            lo = val & 0xFF
            hi = (val >> 8) & 0xFF
            consts[r[0]+'l'] = lo
            consts[r[0]+'h'] = hi
        if r in REG8L:
            full = r[0]+'x'
            if full in consts:
                consts[full] = (consts[full] & 0xFF00) | (val & 0xFF)
        if r in REG8H:
            full = r[0]+'x'
            if full in consts:
                consts[full] = (consts[full] & 0x00FF) | ((val & 0xFF) << 8)
    def kill_reg(r):
        if r in ('ax','bx','cx','dx','si','di','bp'):
            for k in (r, r[0]+'l', r[0]+'h'):
                consts.pop(k, None)
        elif r in REG8L or r in REG8H:
            consts.pop(r, None)
            consts.pop(r[0]+'x', None)
    if m == 'mov' and len(ops)==2:
        dst, src = ops
        if dst.type == X86_OP_REG:
            dreg = ins.reg_name(dst.reg)
            if src.type == X86_OP_IMM:
                set_reg(dreg, src.imm)
            elif src.type == X86_OP_REG:
                sreg = ins.reg_name(src.reg)
                if sreg in consts:
                    set_reg(dreg, consts[sreg])
                else:
                    kill_reg(dreg)
            else:
                kill_reg(dreg)
    elif m == 'xor' and len(ops)==2:
        dst, src = ops
        if dst.type == X86_OP_REG and src.type == X86_OP_REG and dst.reg == src.reg:
            set_reg(ins.reg_name(dst.reg), 0)
        elif dst.type == X86_OP_REG:
            kill_reg(ins.reg_name(dst.reg))
    elif m in ('add','sub','and','or','shl','shr') and len(ops)>=1:
        if ops[0].type == X86_OP_REG:
            kill_reg(ins.reg_name(ops[0].reg))
    elif m in ('inc','dec') and len(ops)==1 and ops[0].type == X86_OP_REG:
        kill_reg(ins.reg_name(ops[0].reg))
    elif m in ('in',) and len(ops)==2 and ops[0].type == X86_OP_REG:
        kill_reg(ins.reg_name(ops[0].reg))
    elif m in ('call','lcall','int'):
        for r in ['ax','bx','cx','dx','si','di','bp']:
            kill_reg(r)


# detect vector table for standard XT vectors

def detect_vector_table(rom: bytes):
    # scan for pattern:
    # mov si, imm16
    # mov di, 0
    # push ds
    # mov ax, cs
    # mov ds, ax
    # mov cx, imm16
    # movsw
    # stosw
    # loop
    base = 0xF8000
    code = rom
    insns = list(md.disasm(code, base))
    for i in range(len(insns)-9):
        a = insns[i:i+9]
        if a[0].mnemonic == 'mov' and a[0].op_str.startswith('si,'):
            if a[1].mnemonic == 'mov' and a[1].op_str == 'di, 0x0':
                if a[2].mnemonic == 'push' and a[2].op_str == 'ds':
                    if a[3].mnemonic == 'mov' and a[3].op_str == 'ax, cs':
                        if a[4].mnemonic == 'mov' and a[4].op_str == 'ds, ax':
                            if a[5].mnemonic == 'mov' and a[5].op_str.startswith('cx,'):
                                if a[6].mnemonic == 'movsw' and a[7].mnemonic == 'stosw' and a[8].mnemonic == 'loop':
                                    # parse imm
                                    si_imm = int(a[0].op_str.split(',')[1], 16)
                                    cx_imm = int(a[5].op_str.split(',')[1], 16)
                                    return si_imm, cx_imm
    # Fallback: known PC1640 layout (vector offsets table at CS:0x3EF3, 0x1F entries).
    fallback_off = 0x3EF3
    fallback_cnt = 0x1F
    if fallback_off + fallback_cnt * 2 <= len(rom):
        offs = read_vector_offsets(rom, fallback_off, fallback_cnt)
        # Heuristic: most entries should point within the 32 KiB image.
        in_range = sum(1 for o in offs if 0 <= o < 0x8000)
        if in_range >= (fallback_cnt * 3) // 4:
            return fallback_off, fallback_cnt
    return None, None


def read_vector_offsets(rom: bytes, table_off: int, count: int):
    offs = []
    for i in range(count):
        off = rom[table_off + i*2] | (rom[table_off + i*2 + 1] << 8)
        offs.append(off)
    return offs


def generate_annotated(path_in, base, entrypoints, labels, path_out, header_note=None, preface=None):
    code = Path(path_in).read_bytes()
    code_map = decode_reachable(code, base, entrypoints)

    # strings
    strings = {}
    i = 0
    while i < len(code):
        if 32 <= code[i] < 127:
            j = i
            while j < len(code) and 32 <= code[j] < 127:
                j += 1
            if j < len(code) and code[j] == 0 and (j - i) >= 4:
                s = code[i:j].decode('ascii', errors='ignore')
                strings[base + i] = s
                i = j + 1
                continue
        i += 1

    out_lines = []
    if header_note:
        out_lines.append(f"; {header_note}")
    if preface:
        out_lines.extend([f"; {l}" for l in preface])
    out_lines.append(f"; File: {path_in}")
    out_lines.append(f"; Base: 0x{base:05X}")
    out_lines.append("")

    addr = base
    end = base + len(code)
    insn_at = code_map

    while addr < end:
        if addr in labels:
            out_lines.append(f"; ---- {labels[addr]} ----")
        if addr in insn_at:
            ins = insn_at[addr]
            bytes_hex = ' '.join(f'{b:02X}' for b in ins.bytes)
            comment = comment_for_ins(ins, {})
            line = f"{addr:08X}  {bytes_hex:<20} {ins.mnemonic:6} {ins.op_str:<20}"
            if comment:
                line += f" ; {comment}"
            out_lines.append(line)
            addr += ins.size
        else:
            if addr in strings:
                out_lines.append(f"; string: \"{strings[addr]}\"")
            start = addr
            chunk = []
            while addr < end and addr not in insn_at and len(chunk) < 16:
                chunk.append(code[addr - base])
                addr += 1
            bytes_hex = ', '.join(f'0x{b:02X}' for b in chunk)
            ascii_str = ascii_comment(chunk)
            out_lines.append(f"{start:08X}  db {bytes_hex} ; {ascii_str}")

    # Second pass: const propagation per block
    entry_set = set(entrypoints)
    for addr, ins in code_map.items():
        m = ins.mnemonic
        next_addr = addr + ins.size
        if m.startswith('j') or m in ('loop','loope','loopne','jcxz'):
            if ins.operands and ins.operands[0].type == X86_OP_IMM:
                entry_set.add(ins.operands[0].imm)
            entry_set.add(next_addr)
        elif m in ('call','lcall'):
            entry_set.add(next_addr)

    line_index = {}
    for i, line in enumerate(out_lines):
        if line and line[0] in '0123456789ABCDEF':
            try:
                addr_str = line.split()[0]
                addr_val = int(addr_str, 16)
                line_index[addr_val] = i
            except Exception:
                pass

    for entry in sorted(entry_set):
        if entry not in code_map:
            continue
        consts = {}
        addr = entry
        while addr in code_map:
            ins = code_map[addr]
            if addr != entry and addr in entry_set:
                break
            comment = comment_for_ins(ins, consts)
            idx = line_index.get(addr)
            if idx is not None:
                line = out_lines[idx]
                if ';' in line:
                    line = line.split(';')[0].rstrip()
                if comment:
                    line = f"{line} ; {comment}"
                out_lines[idx] = line
            update_consts(ins, consts)
            m = ins.mnemonic
            addr_next = addr + ins.size
            if m in ('ret','retf','iret','jmp','ljmp'):
                break
            if m.startswith('j') or m in ('loop','loope','loopne','jcxz'):
                break
            addr = addr_next

    Path(path_out).write_text('\n'.join(out_lines) + '\n')
    return code_map


# C decomp generator (instruction-accurate)

# Per-file macro maps (populated in generate_c).
C_PORT_CONSTS = {}
C_MEM_CONSTS = {}


def port_macro_name(port):
    name = PORT_NAMES.get(port)
    if name:
        return f"PORT_{name}"
    if port <= 0xFF:
        return f"PORT_0x{port:02X}"
    return f"PORT_0x{port:04X}"


def mem_macro_name(off):
    return f"OFF_{off:04X}"


def mem_macro_comment(off):
    if off < 0x400:
        return 'IVT offset'
    if 0x400 <= off < 0x500:
        return 'BDA offset'
    return ''


def collect_c_constants(code_map):
    port_vals = set()
    mem_vals = set()
    for ins in code_map.values():
        m = ins.mnemonic
        ops = ins.operands
        # Immediate port operands in IN/OUT instructions.
        if m in ('in', 'out') and len(ops) == 2:
            port_op = ops[1] if m == 'in' else ops[0]
            if port_op.type == X86_OP_IMM:
                port_vals.add(port_op.imm & 0xFFFF)
        # Capture well-known port constants loaded into DX.
        if m == 'mov' and len(ops) == 2:
            dst, src = ops[0], ops[1]
            if dst.type == X86_OP_REG and ins.reg_name(dst.reg) == 'dx' and src.type == X86_OP_IMM:
                imm = src.imm & 0xFFFF
                if imm in PORT_NAMES:
                    port_vals.add(imm)
        # Direct absolute memory operands (base/index omitted).
        for op in ops:
            if op.type == X86_OP_MEM and op.mem.base == 0 and op.mem.index == 0:
                mem_vals.add(op.mem.disp & 0xFFFF)
    return port_vals, mem_vals


def find_c_strings(data, min_len=4):
    results = []
    i = 0
    n = len(data)
    while i < n:
        if 32 <= data[i] < 127:
            j = i
            while j < n and 32 <= data[j] < 127:
                j += 1
            if j - i >= min_len and j < n and data[j] == 0x00:
                s = data[i:j].decode('ascii', errors='replace')
                if any(('A' <= ch <= 'Z') or ('a' <= ch <= 'z') for ch in s):
                    results.append((i, s))
                i = j + 1
            else:
                i = j + 1
        else:
            i += 1
    return results


def sanitize_comment(text):
    return text.replace('*/', '* /')


def c_escape_string(text):
    # Escape backslashes and quotes for C string literals.
    text = text.replace('\\', '\\\\')
    text = text.replace('"', '\\"')
    return text


def sanitize_name(text, fallback='entry'):
    name = re.sub(r'[^A-Za-z0-9]+', '_', text).strip('_')
    if not name:
        name = fallback
    if name[0].isdigit():
        name = f"{fallback}_{name}"
    return name


def label_to_macro(label, prefix, used):
    base = sanitize_name(label).upper()
    name = f"{prefix}_{base}"
    if name in used:
        name = f"{name}_{len(used)}"
    used.add(name)
    return name


def label_to_func(label, prefix, used):
    base = sanitize_name(label).lower()
    name = f"{prefix}_{base}"
    if name in used:
        name = f"{name}_{len(used)}"
    used.add(name)
    return name


def group_for_label(label):
    text = label.lower()
    groups = [
        ('Video', ['video', 'graphics', 'vdu', 'crtc']),
        ('Keyboard', ['keyboard', 'scancode']),
        ('Floppy/Disk', ['diskette', 'disk', 'floppy', 'fdc']),
        ('Serial', ['serial', 'com']),
        ('Printer', ['printer', 'lpt']),
        ('Timer/RTC', ['timer', 'time-of-day', 'rtc', 'cmos', 'tick']),
        ('System', ['system', 'equipment', 'memory', 'post', 'reset', 'bootstrap',
                    'boot', 'ctrl-break', 'ctrl-alt-del', 'beep', 'faulty', 'error']),
    ]
    for name, keys in groups:
        for k in keys:
            if k in text:
                return name
    return 'Misc'

def c_reg_read(reg):
    if reg in REG16:
        return f"cpu->{reg}"
    if reg == 'al':
        return 'get_al(cpu)'
    if reg == 'ah':
        return 'get_ah(cpu)'
    if reg == 'bl':
        return 'get_bl(cpu)'
    if reg == 'bh':
        return 'get_bh(cpu)'
    if reg == 'cl':
        return 'get_cl(cpu)'
    if reg == 'ch':
        return 'get_ch(cpu)'
    if reg == 'dl':
        return 'get_dl(cpu)'
    if reg == 'dh':
        return 'get_dh(cpu)'
    return f"/*reg {reg}*/0"


def c_reg_write(reg, value):
    if reg in REG16:
        return f"cpu->{reg} = (uint16_t)({value});"
    if reg == 'al':
        return f"set_al(cpu, (uint8_t)({value}));"
    if reg == 'ah':
        return f"set_ah(cpu, (uint8_t)({value}));"
    if reg == 'bl':
        return f"set_bl(cpu, (uint8_t)({value}));"
    if reg == 'bh':
        return f"set_bh(cpu, (uint8_t)({value}));"
    if reg == 'cl':
        return f"set_cl(cpu, (uint8_t)({value}));"
    if reg == 'ch':
        return f"set_ch(cpu, (uint8_t)({value}));"
    if reg == 'dl':
        return f"set_dl(cpu, (uint8_t)({value}));"
    if reg == 'dh':
        return f"set_dh(cpu, (uint8_t)({value}));"
    return f"/*reg {reg}*/(void)({value});"


def c_mem_addr(ins, op):
    seg, expr = mem_expr(ins, op)
    if op.mem.base == 0 and op.mem.index == 0:
        disp = op.mem.disp & 0xFFFF
        if disp in C_MEM_CONSTS:
            expr = C_MEM_CONSTS[disp]
    if seg is None:
        base = ins.reg_name(op.mem.base) if op.mem.base != 0 else None
        if base in ('bp', 'sp'):
            seg = 'ss'
        else:
            seg = 'ds'
    return seg, expr


def c_read_op(ins, op):
    if op.type == X86_OP_REG:
        return c_reg_read(ins.reg_name(op.reg))
    if op.type == X86_OP_IMM:
        return f"0x{op.imm & 0xFFFF:x}"
    if op.type == X86_OP_MEM:
        seg, expr = c_mem_addr(ins, op)
        size = op.size
        if size == 1:
            return f"mem8(cpu, cpu->{seg}, addr16({expr}))"
        else:
            return f"mem16(cpu, cpu->{seg}, addr16({expr}))"
    return '0'


def c_port_expr(ins, op):
    if op.type == X86_OP_IMM:
        imm = op.imm & 0xFFFF
        if imm in C_PORT_CONSTS:
            return C_PORT_CONSTS[imm]
        return f"0x{imm:x}"
    return c_read_op(ins, op)


def c_write_op(ins, op, value):
    if op.type == X86_OP_REG:
        return c_reg_write(ins.reg_name(op.reg), value)
    if op.type == X86_OP_MEM:
        seg, expr = c_mem_addr(ins, op)
        size = op.size
        if size == 1:
            return f"mem8_write(cpu, cpu->{seg}, addr16({expr}), (uint8_t)({value}));"
        else:
            return f"mem16_write(cpu, cpu->{seg}, addr16({expr}), (uint16_t)({value}));"
    return f"/*write to imm?*/ (void)({value});"


def gen_c_for_instruction(ins):
    m = ins.mnemonic
    ops = ins.operands
    next_pc = ins.address + ins.size
    lines = []
    if ins.address in C_CODE_STRINGS:
        for s in C_CODE_STRINGS[ins.address]:
            lines.append(f"            // data: \"{sanitize_comment(s)}\"")
    desc = comment_for_ins(ins, {})
    if desc:
        lines.append(f"            // [0x{ins.address:05X}] {desc}")
    else:
        lines.append(f"            // [0x{ins.address:05X}]")

    if m == 'repe scasw':
        lines.append("            rep_scasw(cpu, /*repe=*/1);")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'repne stosw':
        lines.append("            rep_stosw(cpu, /*repne=*/1);")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines

    def op(i):
        return ops[i] if i < len(ops) else None

    if m == 'mov' and len(ops)==2:
        src = c_read_op(ins, op(1))
        lines.append("            {")
        lines.append(f"                uint16_t tmp = (uint16_t)({src});")
        lines.append(f"                {c_write_op(ins, op(0), 'tmp')}")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'lea' and len(ops)==2:
        seg, expr = c_mem_addr(ins, op(1))
        lines.append("            {")
        lines.append(f"                uint16_t tmp = (uint16_t)({expr});")
        lines.append(f"                {c_write_op(ins, op(0), 'tmp')}")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'xchg' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        lines.append("            {")
        lines.append(f"                uint16_t tmp = (uint16_t)({a});")
        lines.append(f"                {c_write_op(ins, op(0), b)}")
        lines.append(f"                {c_write_op(ins, op(1), 'tmp')}")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'arpl' and len(ops)==2:
        a = c_read_op(ins, op(0))
        b = c_read_op(ins, op(1))
        lines.append("            {")
        lines.append(f"                uint16_t dst = (uint16_t)({a});")
        lines.append(f"                uint16_t src = (uint16_t)({b});")
        lines.append("                if ((dst & 0x3) < (src & 0x3)) {")
        lines.append("                    dst = (dst & ~0x3) | (src & 0x3);")
        lines.append("                    cpu->zf = 1;")
        lines.append("                } else {")
        lines.append("                    cpu->zf = 0;")
        lines.append("                }")
        lines.append(f"                {c_write_op(ins, op(0), 'dst')}")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'add' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = add8(cpu, (uint8_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = add16(cpu, (uint16_t){a}, (uint16_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'sub' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = sub8(cpu, (uint8_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = sub16(cpu, (uint16_t){a}, (uint16_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'sbb' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = sbb8(cpu, (uint8_t){a}, (uint8_t){b}, (cpu->cf ? 1 : 0));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = sbb16(cpu, (uint16_t){a}, (uint16_t){b}, (cpu->cf ? 1 : 0));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'cmp' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            cmp8(cpu, (uint8_t){a}, (uint8_t){b});")
        else:
            lines.append(f"            cmp16(cpu, (uint16_t){a}, (uint16_t){b});")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'and' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = logic8(cpu, (uint8_t)({a} & {b}));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = logic16(cpu, (uint16_t)({a} & {b}));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'or' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = logic8(cpu, (uint8_t)({a} | {b}));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = logic16(cpu, (uint16_t)({a} | {b}));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'xor' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = logic8(cpu, (uint8_t)({a} ^ {b}));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = logic16(cpu, (uint16_t)({a} ^ {b}));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'test' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            (void)logic8(cpu, (uint8_t)({a} & {b}));")
        else:
            lines.append(f"            (void)logic16(cpu, (uint16_t)({a} & {b}));")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'inc' and len(ops)==1:
        a = c_read_op(ins, op(0))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = inc8(cpu, (uint8_t){a});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = inc16(cpu, (uint16_t){a});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'dec' and len(ops)==1:
        a = c_read_op(ins, op(0))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = dec8(cpu, (uint8_t){a});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = dec16(cpu, (uint16_t){a});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'shl' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = shl8(cpu, (uint8_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = shl16(cpu, (uint16_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'shr' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = shr8(cpu, (uint8_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = shr16(cpu, (uint16_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'rcl' and len(ops)==2:
        a = c_read_op(ins, op(0)); b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = rcl8(cpu, (uint8_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = rcl16(cpu, (uint16_t){a}, (uint8_t){b});")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'push' and len(ops)==1:
        a = c_read_op(ins, op(0))
        lines.append(f"            push16(cpu, (uint16_t)({a}));")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'pop' and len(ops)==1:
        lines.append("            {")
        lines.append("                uint16_t tmp = pop16(cpu);")
        lines.append(f"                {c_write_op(ins, op(0), 'tmp')}")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m in ('popaw', 'popa'):
        lines.append("            {")
        lines.append("                uint16_t di = pop16(cpu);")
        lines.append("                uint16_t si = pop16(cpu);")
        lines.append("                uint16_t bp = pop16(cpu);")
        lines.append("                (void)pop16(cpu); /* SP discarded */")
        lines.append("                uint16_t bx = pop16(cpu);")
        lines.append("                uint16_t dx = pop16(cpu);")
        lines.append("                uint16_t cx = pop16(cpu);")
        lines.append("                uint16_t ax = pop16(cpu);")
        lines.append("                cpu->di = di; cpu->si = si; cpu->bp = bp;")
        lines.append("                cpu->bx = bx; cpu->dx = dx; cpu->cx = cx; cpu->ax = ax;")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'pushf':
        lines.append("            push16(cpu, pack_flags(cpu));")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'popf':
        lines.append("            {")
        lines.append("                uint16_t flags = pop16(cpu);")
        lines.append("                unpack_flags(cpu, flags);")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'call' and len(ops)==1:
        lines.append("            {")
        lines.append(f"                uint16_t next_ip = (uint16_t)((pc + {ins.size}) - ((uint32_t)cpu->cs << 4));")
        lines.append("                push16(cpu, next_ip);")
        lines.append("            }")
        if op(0).type == X86_OP_IMM:
            tgt = op(0).imm & 0xFFFF
            lines.append(f"            pc = 0x{tgt:05X};")
        else:
            tgt = c_read_op(ins, op(0))
            lines.append(f"            pc = ((uint32_t)cpu->cs << 4) + (uint16_t)({tgt});")
        lines.append("            break;")
        return lines
    if m == 'lcall' and len(ops)==2 and op(0).type == X86_OP_IMM and op(1).type == X86_OP_IMM:
        seg = op(0).imm & 0xFFFF
        off = op(1).imm & 0xFFFF
        lines.append("            {")
        lines.append(f"                uint16_t next_ip = (uint16_t)((pc + {ins.size}) - ((uint32_t)cpu->cs << 4));")
        lines.append("                push16(cpu, cpu->cs);")
        lines.append("                push16(cpu, next_ip);")
        lines.append("            }")
        lines.append(f"            cpu->cs = 0x{seg:04X};")
        lines.append(f"            pc = ((uint32_t)cpu->cs << 4) + 0x{off:04X};")
        lines.append("            break;")
        return lines
    if m == 'jmp' and len(ops)==1:
        if op(0).type == X86_OP_IMM:
            tgt = op(0).imm & 0xFFFF
            lines.append(f"            pc = 0x{tgt:05X};")
        else:
            tgt = c_read_op(ins, op(0))
            lines.append(f"            pc = ((uint32_t)cpu->cs << 4) + (uint16_t)({tgt});")
        lines.append("            break;")
        return lines
    if m == 'ljmp' and len(ops)==2 and op(0).type == X86_OP_IMM and op(1).type == X86_OP_IMM:
        seg = op(0).imm & 0xFFFF
        off = op(1).imm & 0xFFFF
        lines.append(f"            cpu->cs = 0x{seg:04X};")
        lines.append(f"            pc = ((uint32_t)cpu->cs << 4) + 0x{off:04X};")
        lines.append("            break;")
        return lines
    if m == 'je' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (cpu->zf) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jne' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (!cpu->zf) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jae' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (!cpu->cf) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jb' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (cpu->cf) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'ja' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (!cpu->cf && !cpu->zf) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jl' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (cpu->sf != cpu->of) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jle' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (cpu->zf || (cpu->sf != cpu->of)) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jo' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (cpu->of) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jno' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (!cpu->of) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jcxz' and len(ops)==1:
        tgt = op(0).imm
        lines.append(f"            if (cpu->cx == 0) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'loop' and len(ops)==1:
        tgt = op(0).imm
        lines.append("            cpu->cx--; ")
        lines.append(f"            if (cpu->cx != 0) pc = 0x{tgt:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'ret':
        lines.append("            {")
        lines.append("                uint16_t ip = pop16(cpu);")
        lines.append("                pc = ((uint32_t)cpu->cs << 4) + ip;")
        lines.append("            }")
        lines.append("            break;")
        return lines
    if m == 'retf':
        lines.append("            {")
        lines.append("                uint16_t ip = pop16(cpu);")
        lines.append("                uint16_t cs = pop16(cpu);")
        lines.append("                cpu->cs = cs;")
        lines.append("                pc = ((uint32_t)cs << 4) + ip;")
        lines.append("            }")
        lines.append("            break;")
        return lines
    if m == 'iret':
        lines.append("            {")
        lines.append("                uint16_t ip = pop16(cpu);")
        lines.append("                uint16_t cs = pop16(cpu);")
        lines.append("                uint16_t flags = pop16(cpu);")
        lines.append("                cpu->cs = cs;")
        lines.append("                unpack_flags(cpu, flags);")
        lines.append("                pc = ((uint32_t)cs << 4) + ip;")
        lines.append("            }")
        lines.append("            break;")
        return lines
    if m == 'nop':
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'jmp' and len(ops) == 1:
        if ops[0].type == X86_OP_IMM:
            target = ops[0].imm & 0xFFFF
            lines.append(f"            pc = 0x{target:05X};")
            lines.append("            break;")
            return lines
        if ops[0].type in (X86_OP_MEM, X86_OP_REG):
            target = c_read_op(ins, op(0))
            lines.append("            {")
            lines.append(f"                uint16_t ip = (uint16_t)({target});")
            lines.append("                pc = ((uint32_t)cpu->cs << 4) + ip;")
            lines.append("            }")
            lines.append("            break;")
            return lines
    if m == 'int' and len(ops)==1:
        imm = op(0).imm & 0xFF
        lines.append(f"            bios_int(cpu, 0x{imm:02X});")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'cli':
        lines.append("            cpu->iff = 0;")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'sti':
        lines.append("            cpu->iff = 1;")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'clc':
        lines.append("            cpu->cf = 0;")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'stc':
        lines.append("            cpu->cf = 1;")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'cmc':
        lines.append("            cpu->cf = !cpu->cf;")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'lahf':
        lines.append("            set_ah(cpu, (uint8_t)(pack_flags(cpu) & 0xFF));")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'cld':
        lines.append("            cpu->df = 0;")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'cwde':
        lines.append("            /* no-op for 16-bit model (EAX not modeled) */")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'fild':
        lines.append("            /* FPU op ignored in this model */")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'lodsb':
        lines.append("            set_al(cpu, mem8(cpu, cpu->ds, cpu->si));")
        lines.append("            cpu->si += (cpu->df ? -1 : 1);")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'lodsw':
        lines.append("            cpu->ax = mem16(cpu, cpu->ds, cpu->si);")
        lines.append("            cpu->si += (cpu->df ? -2 : 2);")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'stosb':
        lines.append("            mem8_write(cpu, cpu->es, cpu->di, get_al(cpu));")
        lines.append("            cpu->di += (cpu->df ? -1 : 1);")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'stosw':
        lines.append("            mem16_write(cpu, cpu->es, cpu->di, cpu->ax);")
        lines.append("            cpu->di += (cpu->df ? -2 : 2);")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m in ('js', 'jns', 'jp') and len(ops) == 1 and ops[0].type == X86_OP_IMM:
        target = ops[0].imm & 0xFFFF
        if m == 'js':
            cond = 'cpu->sf'
        elif m == 'jns':
            cond = '!cpu->sf'
        else:
            # jp/jpe: parity flag
            cond = "cpu->pf"
        lines.append(f"            if ({cond}) pc = 0x{target:05X}; else pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'div' and len(ops) == 1:
        divisor = c_read_op(ins, op(0))
        if op(0).size == 1:
            lines.append("            {")
            lines.append("                uint16_t dividend = cpu->ax;")
            lines.append(f"                uint8_t d = (uint8_t)({divisor});")
            lines.append("                if (d != 0) { set_al(cpu, (uint8_t)(dividend / d)); set_ah(cpu, (uint8_t)(dividend % d)); }")
            lines.append("            }")
        else:
            lines.append("            {")
            lines.append("                uint32_t dividend = ((uint32_t)cpu->dx << 16) | cpu->ax;")
            lines.append(f"                uint16_t d = (uint16_t)({divisor});")
            lines.append("                if (d != 0) { cpu->ax = (uint16_t)(dividend / d); cpu->dx = (uint16_t)(dividend % d); }")
            lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'rol' and len(ops) == 2:
        val = c_read_op(ins, op(0))
        cnt = c_read_op(ins, op(1))
        if op(0).size == 1:
            lines.append("            {")
            lines.append(f"                uint8_t v = (uint8_t){val};")
            lines.append(f"                uint8_t c = (uint8_t)({cnt} & 7);")
            lines.append("                if (c) { v = (uint8_t)((v << c) | (v >> (8 - c))); cpu->cf = v & 1; }")
            lines.append(f"                {c_write_op(ins, op(0), 'v')}")
            lines.append("            }")
        else:
            lines.append("            {")
            lines.append(f"                uint16_t v = (uint16_t){val};")
            lines.append(f"                uint8_t c = (uint8_t)({cnt} & 15);")
            lines.append("                if (c) { v = (uint16_t)((v << c) | (v >> (16 - c))); cpu->cf = v & 1; }")
            lines.append(f"                {c_write_op(ins, op(0), 'v')}")
            lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'adc' and len(ops) == 2:
        a = c_read_op(ins, op(0))
        b = c_read_op(ins, op(1))
        size = op(0).size
        if size == 1:
            lines.append(f"            uint8_t res = adc8(cpu, (uint8_t){a}, (uint8_t){b}, (cpu->cf ? 1 : 0));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        else:
            lines.append(f"            uint16_t res = adc16(cpu, (uint16_t){a}, (uint16_t){b}, (cpu->cf ? 1 : 0));")
            lines.append(f"            {c_write_op(ins, op(0), 'res')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'daa':
        # Decimal adjust after addition (AL).
        lines.append("            {")
        lines.append("                uint8_t al = get_al(cpu);")
        lines.append("                uint8_t old_cf = cpu->cf;")
        lines.append("                uint8_t old_af = cpu->af;")
        lines.append("                if (((al & 0x0F) > 9) || old_af) { al += 0x06; cpu->af = 1; } else { cpu->af = 0; }")
        lines.append("                if (old_cf || al > 0x9F) { al += 0x60; cpu->cf = 1; } else { cpu->cf = 0; }")
        lines.append("                set_al(cpu, al);")
        lines.append("                cpu->zf = (al == 0); cpu->sf = (al >> 7) & 1; cpu->pf = parity8(al);")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'in' and len(ops)==2:
        dst = op(0); src = op(1)
        port = c_port_expr(ins, src)
        lines.append(f"            uint8_t v = io_in8(cpu, (uint16_t)({port}));")
        lines.append(f"            {c_write_op(ins, dst, 'v')}")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'out' and len(ops)==2:
        port = c_port_expr(ins, op(0))
        val = c_read_op(ins, op(1))
        lines.append(f"            io_out8(cpu, (uint16_t)({port}), (uint8_t)({val}));")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines
    if m == 'les' and len(ops)==2:
        src = op(1)
        seg, expr = c_mem_addr(ins, src)
        lines.append("            {")
        lines.append(f"                uint16_t off = mem16(cpu, cpu->{seg}, addr16({expr}));")
        lines.append(f"                uint16_t segv = mem16(cpu, cpu->{seg}, addr16({expr} + 2));")
        lines.append(f"                {c_write_op(ins, op(0), 'off')}")
        lines.append("                cpu->es = segv;")
        lines.append("            }")
        lines.append(f"            pc = 0x{next_pc:05X};")
        lines.append("            break;")
        return lines

    lines.append(f"            // TODO: unhandled instruction {m}")
    lines.append(f"            pc = 0x{next_pc:05X};")
    lines.append("            break;")
    return lines


def generate_c(path_in, base, entrypoints, labels, path_out, func_name, header_note=None, macro_prefix=None, func_prefix=None, include_strings=False):
    code = Path(path_in).read_bytes()
    code_map = decode_reachable(code, base, entrypoints)
    addrs = sorted(code_map.keys())
    port_vals, mem_vals = collect_c_constants(code_map)
    port_macros = {p: port_macro_name(p) for p in sorted(port_vals)}
    mem_macros = {m: mem_macro_name(m) for m in sorted(mem_vals)}

    if macro_prefix is None:
        macro_prefix = func_name.upper()
    if func_prefix is None:
        func_prefix = func_name.lower()

    label_macros = {}
    label_funcs = {}
    used_macros = set()
    used_funcs = set()
    for addr, label in sorted(labels.items()):
        label_macros[addr] = label_to_macro(label, macro_prefix, used_macros)
        label_funcs[addr] = label_to_func(label, func_prefix, used_funcs)

    group_map = {}
    for addr, label in labels.items():
        group = group_for_label(label)
        group_map.setdefault(group, []).append(addr)

    default_entry = entrypoints[0]
    default_macro = label_macros.get(default_entry)
    if not default_macro:
        default_macro = f"{macro_prefix}_ENTRY_{default_entry:05X}"
        label_macros[default_entry] = default_macro

    global C_PORT_CONSTS, C_MEM_CONSTS, C_CODE_STRINGS
    C_PORT_CONSTS = port_macros
    C_MEM_CONSTS = mem_macros
    C_CODE_STRINGS = {}

    for off, s in find_c_strings(code, min_len=4):
        addr = base + off
        if addr in code_map:
            C_CODE_STRINGS.setdefault(addr, []).append(s)

    strings = []
    if include_strings:
        for off, s in find_c_strings(code, min_len=4):
            strings.append((off, s))

    out = []
    out.append('#include <stdint.h>')
    out.append('')
    if header_note:
        out.append('/*')
        for line in header_note.splitlines():
            out.append(f' * {line}')
        out.append(' */')
        out.append('')
    if port_macros:
        out.append('/* I/O port constants used by this ROM. */')
        for p in sorted(port_macros.keys()):
            name = port_macros[p]
            comment = PORT_COMMENTS.get(p, '')
            if comment:
                out.append(f'#define {name} 0x{p:04X} /* {comment} */')
            else:
                out.append(f'#define {name} 0x{p:04X}')
        out.append('')
    if mem_macros:
        out.append('/* Absolute memory offsets used by this ROM. */')
        for m in sorted(mem_macros.keys()):
            name = mem_macros[m]
            comment = mem_macro_comment(m)
            if comment:
                out.append(f'#define {name} 0x{m:04X} /* {comment} */')
            else:
                out.append(f'#define {name} 0x{m:04X}')
        out.append('')
    if label_macros:
        out.append('/* Entry point addresses. */')
        for addr in sorted(label_macros.keys()):
            out.append(f'#define {label_macros[addr]} 0x{addr:05X}')
        out.append('')
    if include_strings and strings:
        out.append('/* ROM strings extracted from the original image (offsets relative to base). */')
        out.append('typedef struct { uint16_t off; const char *s; } RomString;')
        out.append('static const RomString rom_strings[] = {')
        for off, s in strings:
            out.append(f'    {{ 0x{off:04X}, "{c_escape_string(s)}" }},')
        out.append('};')
        out.append('static const uint16_t rom_string_count = sizeof(rom_strings)/sizeof(rom_strings[0]);')
        out.append('')
    out.append('/* Minimal 8086 CPU state used by the execution model. */')
    out.append('typedef struct CPU {')
    out.append('    uint16_t ax,bx,cx,dx,si,di,bp,sp,ip;')
    out.append('    uint16_t cs,ds,es,ss;')
    out.append('    uint8_t cf,pf,af,zf,sf,of,df;')
    out.append('    uint8_t iff;')
    out.append('    uint8_t *mem;')
    out.append('    uint8_t (*io_in8)(struct CPU*, uint16_t port);')
    out.append('    void (*io_out8)(struct CPU*, uint16_t port, uint8_t value);')
    out.append('    void (*int_call)(struct CPU*, uint8_t intno);')
    out.append('} CPU;')
    out.append('')
    out.append('/* Segment:offset helpers and linear memory access. */')
    out.append('static inline uint16_t addr16(uint32_t v){ return (uint16_t)(v & 0xFFFF); }')
    out.append('static inline uint8_t mem8(CPU* cpu, uint16_t seg, uint16_t off){ return cpu->mem[((uint32_t)seg<<4)+off]; }')
    out.append('static inline uint16_t mem16(CPU* cpu, uint16_t seg, uint16_t off){ uint32_t a=((uint32_t)seg<<4)+off; return cpu->mem[a] | (cpu->mem[a+1]<<8); }')
    out.append('static inline void mem8_write(CPU* cpu, uint16_t seg, uint16_t off, uint8_t v){ cpu->mem[((uint32_t)seg<<4)+off]=v; }')
    out.append('static inline void mem16_write(CPU* cpu, uint16_t seg, uint16_t off, uint16_t v){ uint32_t a=((uint32_t)seg<<4)+off; cpu->mem[a]=v&0xFF; cpu->mem[a+1]=v>>8; }')
    out.append('')
    out.append('static inline uint8_t parity8(uint8_t v){ return (__builtin_parity((unsigned)v) == 0); }')
    out.append('')
    out.append('static inline uint16_t pack_flags(CPU* cpu){')
    out.append('    return (uint16_t)((cpu->cf ? 1 : 0) |')
    out.append('        ((cpu->pf ? 1 : 0) << 2) |')
    out.append('        ((cpu->af ? 1 : 0) << 4) |')
    out.append('        ((cpu->zf ? 1 : 0) << 6) |')
    out.append('        ((cpu->sf ? 1 : 0) << 7) |')
    out.append('        ((cpu->iff ? 1 : 0) << 9) |')
    out.append('        ((cpu->df ? 1 : 0) << 10) |')
    out.append('        ((cpu->of ? 1 : 0) << 11) |')
    out.append('        0x0002);')
    out.append('}')
    out.append('static inline void unpack_flags(CPU* cpu, uint16_t flags){')
    out.append('    cpu->cf = flags & 0x1;')
    out.append('    cpu->pf = (flags >> 2) & 1;')
    out.append('    cpu->af = (flags >> 4) & 1;')
    out.append('    cpu->zf = (flags >> 6) & 1;')
    out.append('    cpu->sf = (flags >> 7) & 1;')
    out.append('    cpu->iff = (flags >> 9) & 1;')
    out.append('    cpu->df = (flags >> 10) & 1;')
    out.append('    cpu->of = (flags >> 11) & 1;')
    out.append('}')
    out.append('')
    out.append('/* Byte accessors for 16-bit registers. */')
    out.append('#define GET_LO(x) ((uint8_t)((x)&0xFF))')
    out.append('#define GET_HI(x) ((uint8_t)(((x)>>8)&0xFF))')
    out.append('static inline uint8_t get_al(CPU* cpu){ return GET_LO(cpu->ax); }')
    out.append('static inline uint8_t get_ah(CPU* cpu){ return GET_HI(cpu->ax); }')
    out.append('static inline uint8_t get_bl(CPU* cpu){ return GET_LO(cpu->bx); }')
    out.append('static inline uint8_t get_bh(CPU* cpu){ return GET_HI(cpu->bx); }')
    out.append('static inline uint8_t get_cl(CPU* cpu){ return GET_LO(cpu->cx); }')
    out.append('static inline uint8_t get_ch(CPU* cpu){ return GET_HI(cpu->cx); }')
    out.append('static inline uint8_t get_dl(CPU* cpu){ return GET_LO(cpu->dx); }')
    out.append('static inline uint8_t get_dh(CPU* cpu){ return GET_HI(cpu->dx); }')
    out.append('static inline void set_al(CPU* cpu, uint8_t v){ cpu->ax = (cpu->ax & 0xFF00) | v; }')
    out.append('static inline void set_ah(CPU* cpu, uint8_t v){ cpu->ax = (cpu->ax & 0x00FF) | ((uint16_t)v<<8); }')
    out.append('static inline void set_bl(CPU* cpu, uint8_t v){ cpu->bx = (cpu->bx & 0xFF00) | v; }')
    out.append('static inline void set_bh(CPU* cpu, uint8_t v){ cpu->bx = (cpu->bx & 0x00FF) | ((uint16_t)v<<8); }')
    out.append('static inline void set_cl(CPU* cpu, uint8_t v){ cpu->cx = (cpu->cx & 0xFF00) | v; }')
    out.append('static inline void set_ch(CPU* cpu, uint8_t v){ cpu->cx = (cpu->cx & 0x00FF) | ((uint16_t)v<<8); }')
    out.append('static inline void set_dl(CPU* cpu, uint8_t v){ cpu->dx = (cpu->dx & 0xFF00) | v; }')
    out.append('static inline void set_dh(CPU* cpu, uint8_t v){ cpu->dx = (cpu->dx & 0x00FF) | ((uint16_t)v<<8); }')
    out.append('')
    out.append('/* Flag helpers for logical ops. */')
    out.append('static inline void set_flags_logic8(CPU* cpu, uint8_t r){ cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->pf=parity8(r); cpu->cf=0; cpu->of=0; cpu->af=0; }')
    out.append('static inline void set_flags_logic16(CPU* cpu, uint16_t r){ cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->pf=parity8((uint8_t)r); cpu->cf=0; cpu->of=0; cpu->af=0; }')
    out.append('static inline uint8_t logic8(CPU* cpu, uint8_t r){ set_flags_logic8(cpu,r); return r; }')
    out.append('static inline uint16_t logic16(CPU* cpu, uint16_t r){ set_flags_logic16(cpu,r); return r; }')
    out.append('')
    out.append('/* ALU helpers that update flags in the 8086-compatible way. */')
    out.append('static inline uint8_t add8(CPU* cpu, uint8_t a, uint8_t b){ uint16_t r=a+b; cpu->cf=(r>0xFF); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=((~(a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }')
    out.append('static inline uint16_t add16(CPU* cpu, uint16_t a, uint16_t b){ uint32_t r=a+b; cpu->cf=(r>0xFFFF); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=((~(a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }')
    out.append('static inline uint8_t sub8(CPU* cpu, uint8_t a, uint8_t b){ uint16_t r=a-b; cpu->cf=(a<b); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=(((a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }')
    out.append('static inline uint16_t sub16(CPU* cpu, uint16_t a, uint16_t b){ uint32_t r=a-b; cpu->cf=(a<b); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=(((a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }')
    out.append('static inline void cmp8(CPU* cpu, uint8_t a, uint8_t b){ (void)sub8(cpu,a,b); }')
    out.append('static inline void cmp16(CPU* cpu, uint16_t a, uint16_t b){ (void)sub16(cpu,a,b); }')
    out.append('static inline uint8_t inc8(CPU* cpu, uint8_t a){ uint8_t r=a+1; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->of=(r==0x80); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8(r); return r; }')
    out.append('static inline uint16_t inc16(CPU* cpu, uint16_t a){ uint16_t r=a+1; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->of=(r==0x8000); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return r; }')
    out.append('static inline uint8_t dec8(CPU* cpu, uint8_t a){ uint8_t r=a-1; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->of=(r==0x7F); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8(r); return r; }')
    out.append('static inline uint16_t dec16(CPU* cpu, uint16_t a){ uint16_t r=a-1; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->of=(r==0x7FFF); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return r; }')
    out.append('static inline uint8_t shl8(CPU* cpu, uint8_t a, uint8_t c){ uint8_t r=a<<c; if(c){ cpu->cf=(a>>(8-c))&1; cpu->of=(c==1)?(((r>>7)&1) ^ cpu->cf):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->pf=parity8(r); cpu->af=0;} return r; }')
    out.append('static inline uint16_t shl16(CPU* cpu, uint16_t a, uint8_t c){ uint16_t r=a<<c; if(c){ cpu->cf=(a>>(16-c))&1; cpu->of=(c==1)?(((r>>15)&1) ^ cpu->cf):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->pf=parity8((uint8_t)r); cpu->af=0;} return r; }')
    out.append('static inline uint8_t shr8(CPU* cpu, uint8_t a, uint8_t c){ uint8_t r=a>>c; if(c){ cpu->cf=(a>>(c-1))&1; cpu->of=(c==1)?((a>>7)&1):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->pf=parity8(r); cpu->af=0;} return r; }')
    out.append('static inline uint16_t shr16(CPU* cpu, uint16_t a, uint8_t c){ uint16_t r=a>>c; if(c){ cpu->cf=(a>>(c-1))&1; cpu->of=(c==1)?((a>>15)&1):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->pf=parity8((uint8_t)r); cpu->af=0;} return r; }')
    out.append('static inline uint8_t adc8(CPU* cpu, uint8_t a, uint8_t b, uint8_t c){ uint16_t r=a+b+c; cpu->cf=(r>0xFF); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=((~(a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }')
    out.append('static inline uint16_t adc16(CPU* cpu, uint16_t a, uint16_t b, uint8_t c){ uint32_t r=a+b+c; cpu->cf=(r>0xFFFF); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=((~(a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }')
    out.append('static inline uint8_t sbb8(CPU* cpu, uint8_t a, uint8_t b, uint8_t c){ uint16_t r=a-b-c; cpu->cf=(a < (uint16_t)(b+c)); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=(((a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }')
    out.append('static inline uint16_t sbb16(CPU* cpu, uint16_t a, uint16_t b, uint8_t c){ uint32_t r=a-b-c; cpu->cf=(a < (uint32_t)(b+c)); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=(((a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }')
    out.append('static inline uint8_t rcl8(CPU* cpu, uint8_t a, uint8_t c){ if(!c) return a; c &= 7; uint16_t v = (uint16_t)(a | ((cpu->cf & 1) << 8)); v = (uint16_t)((v << c) | (v >> (9 - c))); cpu->cf = (v >> 8) & 1; a = (uint8_t)(v & 0xFF); if(c==1) cpu->of = ((a >> 7) & 1) ^ cpu->cf; return a; }')
    out.append('static inline uint16_t rcl16(CPU* cpu, uint16_t a, uint8_t c){ if(!c) return a; c &= 15; uint32_t v = (uint32_t)(a | ((cpu->cf & 1) << 16)); v = (uint32_t)((v << c) | (v >> (17 - c))); cpu->cf = (v >> 16) & 1; a = (uint16_t)(v & 0xFFFF); if(c==1) cpu->of = ((a >> 15) & 1) ^ cpu->cf; return a; }')
    out.append('')
    out.append('/* Stack and I/O helpers. */')
    out.append('static inline void push16(CPU* cpu, uint16_t v){ cpu->sp -= 2; mem16_write(cpu, cpu->ss, cpu->sp, v); }')
    out.append('static inline uint16_t pop16(CPU* cpu){ uint16_t v = mem16(cpu, cpu->ss, cpu->sp); cpu->sp += 2; return v; }')
    out.append('static inline uint8_t io_in8(CPU* cpu, uint16_t port){ return cpu->io_in8 ? cpu->io_in8(cpu, port) : 0xFF; }')
    out.append('static inline void io_out8(CPU* cpu, uint16_t port, uint8_t v){ if(cpu->io_out8) cpu->io_out8(cpu, port, v); }')
    out.append('static inline void bios_int(CPU* cpu, uint8_t n){ if(cpu->int_call) cpu->int_call(cpu, n); }')
    out.append('')
    out.append('/* String op helpers used by REP-prefixed instructions. */')
    out.append('static inline void rep_stosw(CPU* cpu, int repne){ (void)repne; while(cpu->cx){ mem16_write(cpu, cpu->es, cpu->di, cpu->ax); cpu->di += (cpu->df ? -2 : 2); cpu->cx--; } }')
    out.append('static inline void rep_scasw(CPU* cpu, int repe){ while(cpu->cx){ uint16_t v = mem16(cpu, cpu->es, cpu->di); cmp16(cpu, cpu->ax, v); cpu->di += (cpu->df ? -2 : 2); cpu->cx--; if(repe && !cpu->zf) break; if(!repe && cpu->zf) break; } }')
    out.append('')

    out.append('/* Entry point wrappers for easier testing and customization. */')
    out.append(f"static void {func_name}_exec(CPU* cpu, uint32_t entry_pc);")
    out.append(f"void {func_name}(CPU* cpu) {{ {func_name}_exec(cpu, {default_macro}); }}")
    out.append('')
    group_order = ['Video', 'Keyboard', 'Floppy/Disk', 'Serial', 'Printer', 'Timer/RTC', 'System', 'Misc']
    for group in group_order:
        addrs = group_map.get(group, [])
        if not addrs:
            continue
        out.append(f"/* {group} */")
        for addr in sorted(addrs):
            out.append(f"void {label_funcs[addr]}(CPU* cpu) {{ {func_name}_exec(cpu, {label_macros[addr]}); }}")
        out.append('')

    out.append('/* Instruction-accurate execution engine. */')
    out.append(f"static void {func_name}_exec(CPU* cpu, uint32_t entry_pc) {{")
    out.append("    uint32_t pc = entry_pc;")
    out.append("    for(;;){")
    out.append("        switch(pc){")

    for addr in addrs:
        label = labels.get(addr)
        if label:
            out.append(f"        case 0x{addr:05X}: /* {label} */ {{")
        else:
            out.append(f"        case 0x{addr:05X}: {{")
        out.extend(gen_c_for_instruction(code_map[addr]))
        out.append("        }")

    out.append("        default:")
    out.append("            /* Unknown PC: stop to avoid executing garbage. */")
    out.append("            return;")
    out.append("        }")
    out.append("    }")
    out.append("}")

    Path(path_out).write_text('\n'.join(out) + '\n')


# Entry points and labels
root = Path('/home/gatekeeper/.pcem/roms/pc1640/decompiled')

# Video ROM
video_base = 0xC0000
video_entry = 0xC143F
video_labels = {
    video_entry: 'Video ROM entry (header jump)',
}

# System BIOS
bios_base = 0xF8000
bios_entry = 0xFFFF0
bios_labels = {
    bios_entry: 'Reset vector',
    0xFE05B: 'Reset continuation (ljmp FC00:00C9)',
    0xFC000: 'POST entry (FC00:0000)',
    0xFE833: 'Scancode handler (FC00:2833)',
    0xFE838: 'Beep routine (FC00:2838)',
    0xFE83D: 'Ctrl-Alt-Del handler (FC00:283D)',
    0xFFEAC: 'Display error (FC00:3EAC)',
    0xFFEB0: 'Report faulty hardware (FC00:3EB0)',
}

bios_bin = root / 'system' / 'bios.bin'
rom = bios_bin.read_bytes()

table_off, table_cnt = detect_vector_table(rom)
if table_off is not None:
    offs = read_vector_offsets(rom, table_off, table_cnt)
    for i, off in enumerate(offs):
        phys = (0xFC00 << 4) + off
        name = INT_DESC.get(i, f'INT {i:02X}')
        bios_labels[phys] = f'Vector INT {i:02X} ({name})'
else:
    table_off = 0
    table_cnt = 0

# Assemble entrypoints list
bios_entrypoints = [bios_entry]
for addr in bios_labels.keys():
    if addr not in bios_entrypoints:
        bios_entrypoints.append(addr)

# Generate annotated ASM + C decomp
_ = generate_annotated(
    path_in=str(root / 'video' / '40100_rom.bin'),
    base=video_base,
    entrypoints=[video_entry],
    labels=video_labels,
    path_out=str(root / 'video' / '40100_rom_annotated.asm'),
    header_note='Video option ROM (code + data).',
    preface=[
        'ROM header: 0xC0000 = 0x55 0xAA, size byte 0x20 -> 16 KiB.',
        'ROM header jump at 0xC0003 targets entry 0xC143F.'
    ]
)

video_c_header = (
    'Instruction-accurate decompilation of the PC1640 video option ROM.\n'
    'Paradise PEGA1A video BIOS.\n'
    '\n'
    'Each switch case corresponds to a single original instruction at the\n'
    'physical address shown in the case label (e.g. 0xC0123 == 0xC0000:0x0123).\n'
    'Control flow is reconstructed via a dispatch loop over the linear `pc`.\n'
    '\n'
    'Expectations:\n'
    '- cpu->mem points to a linear 1 MiB memory image; physical address = seg<<4+off.\n'
    '- cpu->cs should be 0xC000 for this ROM.\n'
    '- io_in8/io_out8/int_call are callbacks for port I/O and INT handling.\n'
    '\n'
    'This is meant for analysis and traceability, not hand-written source.'
)

generate_c(
    path_in=str(root / 'video' / '40100_rom.bin'),
    base=video_base,
    entrypoints=[video_entry],
    labels=video_labels,
    path_out=str(root / 'video' / '40100_rom_decomp.c'),
    func_name='video_rom_exec',
    header_note=video_c_header,
    macro_prefix='VIDEO',
    func_prefix='video'
)

_ = generate_annotated(
    path_in=str(root / 'system' / 'bios.bin'),
    base=bios_base,
    entrypoints=bios_entrypoints,
    labels=bios_labels,
    path_out=str(root / 'system' / 'bios_annotated.asm'),
    header_note='System BIOS (32 KiB, mapped at 0xF8000-0xFFFFF).',
    preface=[
        'Reset vector at physical 0xFFFF0 (offset 0x7FF0).',
        'Reset ljmp targets 0xFC00:0x205B (physical 0xFE05B) within this image.',
        f'Vector table offsets at CS:0x{table_off:04X}, {table_cnt} entries (offsets; segment = CS).'
    ]
)

bios_c_header = (
    'Instruction-accurate decompilation of the PC1640 system BIOS.\n'
    '\n'
    'Each switch case corresponds to a single original instruction at the\n'
    'physical address shown in the case label (e.g. 0xFC0C9 == 0xFC00:0x00C9).\n'
    'Control flow is reconstructed via a dispatch loop over the linear `pc`.\n'
    '\n'
    'Expectations:\n'
    '- cpu->mem points to a linear 1 MiB memory image; physical address = seg<<4+off.\n'
    '- The entry PC is the reset vector at 0xFFFF0.\n'
    '- io_in8/io_out8/int_call are callbacks for port I/O and INT handling.\n'
    '\n'
    'This is meant for analysis and traceability, not hand-written source.'
)

generate_c(
    path_in=str(root / 'system' / 'bios.bin'),
    base=bios_base,
    entrypoints=bios_entrypoints,
    labels=bios_labels,
    path_out=str(root / 'system' / 'bios_decomp.c'),
    func_name='system_bios_exec',
    header_note=bios_c_header,
    macro_prefix='BIOS',
    func_prefix='bios',
    include_strings=True
)

print('regenerated')
