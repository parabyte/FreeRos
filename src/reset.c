/* ================================================
 * FreeRos BIOS
 * reset.c: Reset vector entry point
 * ================================================ */

#include "bios.h"

/*
 * Reset vector assembly moved to `reset_entry.S` so the reset flow is plain
 * assembly with readable labels/comments instead of one giant inline C string.
 */
