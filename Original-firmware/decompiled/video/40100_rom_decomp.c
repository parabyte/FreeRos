#include <stdint.h>

/*
 * Instruction-accurate decompilation of the PC1640 video option ROM.
 * Paradise PEGA1A video BIOS.
 * 
 * Each switch case corresponds to a single original instruction at the
 * physical address shown in the case label (e.g. 0xC0123 == 0xC0000:0x0123).
 * Control flow is reconstructed via a dispatch loop over the linear `pc`.
 * 
 * Expectations:
 * - cpu->mem points to a linear 1 MiB memory image; physical address = seg<<4+off.
 * - cpu->cs should be 0xC000 for this ROM.
 * - io_in8/io_out8/int_call are callbacks for port I/O and INT handling.
 * 
 * This is meant for analysis and traceability, not hand-written source.
 */

/* I/O port constants used by this ROM. */
#define PORT_PIT_CH2 0x0042 /* PIT channel 2 */
#define PORT_PIT_MODE 0x0043 /* PIT mode/command */
#define PORT_PPI_PORT_B 0x0061 /* PPI port B (speaker/port) */
#define PORT_VGA_ATTR_ADDR 0x03C0
#define PORT_VGA_MISC_OUTPUT 0x03C2
#define PORT_VGA_SEQ_ADDR 0x03C4
#define PORT_CGA_MODE 0x03D8 /* CGA mode control */
#define PORT_VGA_INPUT_STATUS_1 0x03DA /* CGA status */

/* Absolute memory offsets used by this ROM. */
#define OFF_0040 0x0040 /* IVT offset */
#define OFF_0042 0x0042 /* IVT offset */
#define OFF_0108 0x0108 /* IVT offset */
#define OFF_010A 0x010A /* IVT offset */
#define OFF_010C 0x010C /* IVT offset */
#define OFF_010E 0x010E /* IVT offset */
#define OFF_0410 0x0410 /* BDA offset */
#define OFF_0463 0x0463 /* BDA offset */
#define OFF_0472 0x0472 /* BDA offset */
#define OFF_0487 0x0487 /* BDA offset */
#define OFF_0488 0x0488 /* BDA offset */
#define OFF_04A8 0x04A8 /* BDA offset */
#define OFF_04AA 0x04AA /* BDA offset */
#define OFF_3FE4 0x3FE4

/* Entry point addresses. */
#define VIDEO_VIDEO_ROM_ENTRY_HEADER_JUMP 0xC143F

/* Minimal 8086 CPU state used by the execution model. */
typedef struct CPU {
    uint16_t ax,bx,cx,dx,si,di,bp,sp,ip;
    uint16_t cs,ds,es,ss;
    uint8_t cf,pf,af,zf,sf,of,df;
    uint8_t iff;
    uint8_t *mem;
    uint8_t (*io_in8)(struct CPU*, uint16_t port);
    void (*io_out8)(struct CPU*, uint16_t port, uint8_t value);
    void (*int_call)(struct CPU*, uint8_t intno);
} CPU;

/* Segment:offset helpers and linear memory access. */
static inline uint16_t addr16(uint32_t v){ return (uint16_t)(v & 0xFFFF); }
static inline uint8_t mem8(CPU* cpu, uint16_t seg, uint16_t off){ return cpu->mem[((uint32_t)seg<<4)+off]; }
static inline uint16_t mem16(CPU* cpu, uint16_t seg, uint16_t off){ uint32_t a=((uint32_t)seg<<4)+off; return cpu->mem[a] | (cpu->mem[a+1]<<8); }
static inline void mem8_write(CPU* cpu, uint16_t seg, uint16_t off, uint8_t v){ cpu->mem[((uint32_t)seg<<4)+off]=v; }
static inline void mem16_write(CPU* cpu, uint16_t seg, uint16_t off, uint16_t v){ uint32_t a=((uint32_t)seg<<4)+off; cpu->mem[a]=v&0xFF; cpu->mem[a+1]=v>>8; }

static inline uint8_t parity8(uint8_t v){ return (__builtin_parity((unsigned)v) == 0); }

static inline uint16_t pack_flags(CPU* cpu){
    return (uint16_t)((cpu->cf ? 1 : 0) |
        ((cpu->pf ? 1 : 0) << 2) |
        ((cpu->af ? 1 : 0) << 4) |
        ((cpu->zf ? 1 : 0) << 6) |
        ((cpu->sf ? 1 : 0) << 7) |
        ((cpu->iff ? 1 : 0) << 9) |
        ((cpu->df ? 1 : 0) << 10) |
        ((cpu->of ? 1 : 0) << 11) |
        0x0002);
}
static inline void unpack_flags(CPU* cpu, uint16_t flags){
    cpu->cf = flags & 0x1;
    cpu->pf = (flags >> 2) & 1;
    cpu->af = (flags >> 4) & 1;
    cpu->zf = (flags >> 6) & 1;
    cpu->sf = (flags >> 7) & 1;
    cpu->iff = (flags >> 9) & 1;
    cpu->df = (flags >> 10) & 1;
    cpu->of = (flags >> 11) & 1;
}

/* Byte accessors for 16-bit registers. */
#define GET_LO(x) ((uint8_t)((x)&0xFF))
#define GET_HI(x) ((uint8_t)(((x)>>8)&0xFF))
static inline uint8_t get_al(CPU* cpu){ return GET_LO(cpu->ax); }
static inline uint8_t get_ah(CPU* cpu){ return GET_HI(cpu->ax); }
static inline uint8_t get_bl(CPU* cpu){ return GET_LO(cpu->bx); }
static inline uint8_t get_bh(CPU* cpu){ return GET_HI(cpu->bx); }
static inline uint8_t get_cl(CPU* cpu){ return GET_LO(cpu->cx); }
static inline uint8_t get_ch(CPU* cpu){ return GET_HI(cpu->cx); }
static inline uint8_t get_dl(CPU* cpu){ return GET_LO(cpu->dx); }
static inline uint8_t get_dh(CPU* cpu){ return GET_HI(cpu->dx); }
static inline void set_al(CPU* cpu, uint8_t v){ cpu->ax = (cpu->ax & 0xFF00) | v; }
static inline void set_ah(CPU* cpu, uint8_t v){ cpu->ax = (cpu->ax & 0x00FF) | ((uint16_t)v<<8); }
static inline void set_bl(CPU* cpu, uint8_t v){ cpu->bx = (cpu->bx & 0xFF00) | v; }
static inline void set_bh(CPU* cpu, uint8_t v){ cpu->bx = (cpu->bx & 0x00FF) | ((uint16_t)v<<8); }
static inline void set_cl(CPU* cpu, uint8_t v){ cpu->cx = (cpu->cx & 0xFF00) | v; }
static inline void set_ch(CPU* cpu, uint8_t v){ cpu->cx = (cpu->cx & 0x00FF) | ((uint16_t)v<<8); }
static inline void set_dl(CPU* cpu, uint8_t v){ cpu->dx = (cpu->dx & 0xFF00) | v; }
static inline void set_dh(CPU* cpu, uint8_t v){ cpu->dx = (cpu->dx & 0x00FF) | ((uint16_t)v<<8); }

/* Flag helpers for logical ops. */
static inline void set_flags_logic8(CPU* cpu, uint8_t r){ cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->pf=parity8(r); cpu->cf=0; cpu->of=0; cpu->af=0; }
static inline void set_flags_logic16(CPU* cpu, uint16_t r){ cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->pf=parity8((uint8_t)r); cpu->cf=0; cpu->of=0; cpu->af=0; }
static inline uint8_t logic8(CPU* cpu, uint8_t r){ set_flags_logic8(cpu,r); return r; }
static inline uint16_t logic16(CPU* cpu, uint16_t r){ set_flags_logic16(cpu,r); return r; }

/* ALU helpers that update flags in the 8086-compatible way. */
static inline uint8_t add8(CPU* cpu, uint8_t a, uint8_t b){ uint16_t r=a+b; cpu->cf=(r>0xFF); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=((~(a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }
static inline uint16_t add16(CPU* cpu, uint16_t a, uint16_t b){ uint32_t r=a+b; cpu->cf=(r>0xFFFF); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=((~(a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }
static inline uint8_t sub8(CPU* cpu, uint8_t a, uint8_t b){ uint16_t r=a-b; cpu->cf=(a<b); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=(((a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }
static inline uint16_t sub16(CPU* cpu, uint16_t a, uint16_t b){ uint32_t r=a-b; cpu->cf=(a<b); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=(((a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }
static inline void cmp8(CPU* cpu, uint8_t a, uint8_t b){ (void)sub8(cpu,a,b); }
static inline void cmp16(CPU* cpu, uint16_t a, uint16_t b){ (void)sub16(cpu,a,b); }
static inline uint8_t inc8(CPU* cpu, uint8_t a){ uint8_t r=a+1; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->of=(r==0x80); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8(r); return r; }
static inline uint16_t inc16(CPU* cpu, uint16_t a){ uint16_t r=a+1; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->of=(r==0x8000); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return r; }
static inline uint8_t dec8(CPU* cpu, uint8_t a){ uint8_t r=a-1; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->of=(r==0x7F); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8(r); return r; }
static inline uint16_t dec16(CPU* cpu, uint16_t a){ uint16_t r=a-1; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->of=(r==0x7FFF); cpu->af=((a ^ 1 ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return r; }
static inline uint8_t shl8(CPU* cpu, uint8_t a, uint8_t c){ uint8_t r=a<<c; if(c){ cpu->cf=(a>>(8-c))&1; cpu->of=(c==1)?(((r>>7)&1) ^ cpu->cf):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->pf=parity8(r); cpu->af=0;} return r; }
static inline uint16_t shl16(CPU* cpu, uint16_t a, uint8_t c){ uint16_t r=a<<c; if(c){ cpu->cf=(a>>(16-c))&1; cpu->of=(c==1)?(((r>>15)&1) ^ cpu->cf):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->pf=parity8((uint8_t)r); cpu->af=0;} return r; }
static inline uint8_t shr8(CPU* cpu, uint8_t a, uint8_t c){ uint8_t r=a>>c; if(c){ cpu->cf=(a>>(c-1))&1; cpu->of=(c==1)?((a>>7)&1):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>7)&1; cpu->pf=parity8(r); cpu->af=0;} return r; }
static inline uint16_t shr16(CPU* cpu, uint16_t a, uint8_t c){ uint16_t r=a>>c; if(c){ cpu->cf=(a>>(c-1))&1; cpu->of=(c==1)?((a>>15)&1):cpu->of; cpu->zf=(r==0); cpu->sf=(r>>15)&1; cpu->pf=parity8((uint8_t)r); cpu->af=0;} return r; }
static inline uint8_t adc8(CPU* cpu, uint8_t a, uint8_t b, uint8_t c){ uint16_t r=a+b+c; cpu->cf=(r>0xFF); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=((~(a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }
static inline uint16_t adc16(CPU* cpu, uint16_t a, uint16_t b, uint8_t c){ uint32_t r=a+b+c; cpu->cf=(r>0xFFFF); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=((~(a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }
static inline uint8_t sbb8(CPU* cpu, uint8_t a, uint8_t b, uint8_t c){ uint16_t r=a-b-c; cpu->cf=(a < (uint16_t)(b+c)); cpu->zf=((uint8_t)r==0); cpu->sf=(r>>7)&1; cpu->of=(((a^b) & (a^r))>>7)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint8_t)r; }
static inline uint16_t sbb16(CPU* cpu, uint16_t a, uint16_t b, uint8_t c){ uint32_t r=a-b-c; cpu->cf=(a < (uint32_t)(b+c)); cpu->zf=((uint16_t)r==0); cpu->sf=(r>>15)&1; cpu->of=(((a^b) & (a^r))>>15)&1; cpu->af=((a ^ b ^ r) & 0x10)!=0; cpu->pf=parity8((uint8_t)r); return (uint16_t)r; }
static inline uint8_t rcl8(CPU* cpu, uint8_t a, uint8_t c){ if(!c) return a; c &= 7; uint16_t v = (uint16_t)(a | ((cpu->cf & 1) << 8)); v = (uint16_t)((v << c) | (v >> (9 - c))); cpu->cf = (v >> 8) & 1; a = (uint8_t)(v & 0xFF); if(c==1) cpu->of = ((a >> 7) & 1) ^ cpu->cf; return a; }
static inline uint16_t rcl16(CPU* cpu, uint16_t a, uint8_t c){ if(!c) return a; c &= 15; uint32_t v = (uint32_t)(a | ((cpu->cf & 1) << 16)); v = (uint32_t)((v << c) | (v >> (17 - c))); cpu->cf = (v >> 16) & 1; a = (uint16_t)(v & 0xFFFF); if(c==1) cpu->of = ((a >> 15) & 1) ^ cpu->cf; return a; }

/* Stack and I/O helpers. */
static inline void push16(CPU* cpu, uint16_t v){ cpu->sp -= 2; mem16_write(cpu, cpu->ss, cpu->sp, v); }
static inline uint16_t pop16(CPU* cpu){ uint16_t v = mem16(cpu, cpu->ss, cpu->sp); cpu->sp += 2; return v; }
static inline uint8_t io_in8(CPU* cpu, uint16_t port){ return cpu->io_in8 ? cpu->io_in8(cpu, port) : 0xFF; }
static inline void io_out8(CPU* cpu, uint16_t port, uint8_t v){ if(cpu->io_out8) cpu->io_out8(cpu, port, v); }
static inline void bios_int(CPU* cpu, uint8_t n){ if(cpu->int_call) cpu->int_call(cpu, n); }

/* String op helpers used by REP-prefixed instructions. */
static inline void rep_stosw(CPU* cpu, int repne){ (void)repne; while(cpu->cx){ mem16_write(cpu, cpu->es, cpu->di, cpu->ax); cpu->di += (cpu->df ? -2 : 2); cpu->cx--; } }
static inline void rep_scasw(CPU* cpu, int repe){ while(cpu->cx){ uint16_t v = mem16(cpu, cpu->es, cpu->di); cmp16(cpu, cpu->ax, v); cpu->di += (cpu->df ? -2 : 2); cpu->cx--; if(repe && !cpu->zf) break; if(!repe && cpu->zf) break; } }

/* Entry point wrappers for easier testing and customization. */
static void video_rom_exec_exec(CPU* cpu, uint32_t entry_pc);
void video_rom_exec(CPU* cpu) { video_rom_exec_exec(cpu, VIDEO_VIDEO_ROM_ENTRY_HEADER_JUMP); }

/* Video */
void video_video_rom_entry_header_jump(CPU* cpu) { video_rom_exec_exec(cpu, VIDEO_VIDEO_ROM_ENTRY_HEADER_JUMP); }

/* Instruction-accurate execution engine. */
static void video_rom_exec_exec(CPU* cpu, uint32_t entry_pc) {
    uint32_t pc = entry_pc;
    for(;;){
        switch(pc){
        default:
            /* Unknown PC: stop to avoid executing garbage. */
            return;
        }
    }
}
