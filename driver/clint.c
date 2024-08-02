#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define CLINT_BASE_ADDR     0x10004000
#define CLINT_REG_MSIP      *((volatile uint32_t *)(CLINT_BASE_ADDR))
#define CLINT_REG_MTIMEL    *((volatile uint32_t *)(CLINT_BASE_ADDR + 4))
#define CLINT_REG_MTIMEH    *((volatile uint32_t *)(CLINT_BASE_ADDR + 8))
#define CLINT_REG_MTIMECMPL *((volatile uint32_t *)(CLINT_BASE_ADDR + 12))
#define CLINT_REG_MTIMECMPH *((volatile uint32_t *)(CLINT_BASE_ADDR + 16))

int main(){
    putstr("clint test\n");
    for(int i = 0; i < 6; i++) {
        printf("i: %d, mtime: %llx\n", i, (((uint64_t) CLINT_REG_MTIMEH) << 32) | CLINT_REG_MTIMEL);
    }

    CLINT_REG_MTIMECMPH = 0;
    CLINT_REG_MTIMECMPL = (uint32_t) 0x1FFFF;
    printf("mtimecmp: %llx\n", (((uint64_t) CLINT_REG_MTIMECMPH) << 32) | CLINT_REG_MTIMECMPL);

    for(int i = 0; i < 6; i++) {
        while(1) {
            uint64_t mtime = (((uint64_t) CLINT_REG_MTIMEH) << 32) | CLINT_REG_MTIMEL;
            uint64_t mtimecmp = (((uint64_t) CLINT_REG_MTIMECMPH) << 32) | CLINT_REG_MTIMECMPL;
            if(mtime >= mtimecmp) break;
        }
        CLINT_REG_MTIMECMPL += (uint32_t) 0x10000;
        putstr("time overflow trigger\n");
    }
    putstr("test done\n");

    return 0;
}
