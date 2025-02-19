// c_fifo_memory.c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#define ADDR_WIDTH 5
#define FIFO_DEPTH (1 << ADDR_WIDTH)

typedef struct {
    uint8_t memory[FIFO_DEPTH];
    unsigned int write_ptr;
    unsigned int read_ptr;
} FIFO_t;

void fifo_init(FIFO_t *fifo) {
    fifo->write_ptr = 0;
    fifo->read_ptr = 0;
}

bool fifo_empty(FIFO_t *fifo) {
    return (fifo->write_ptr == fifo->read_ptr);
}

bool fifo_full(FIFO_t *fifo) {
    return ((fifo->write_ptr - fifo->read_ptr) == FIFO_DEPTH);
}

bool fifo_write(FIFO_t *fifo, uint8_t data) {
    if (fifo_full(fifo))
        return false;
    fifo->memory[fifo->write_ptr % FIFO_DEPTH] = data;
    fifo->write_ptr++;
    return true;
}

bool fifo_read(FIFO_t *fifo, uint8_t *data) {
    if (fifo_empty(fifo))
        return false;
    *data = fifo->memory[fifo->read_ptr % FIFO_DEPTH];
    fifo->read_ptr++;
    return true;
}

int main() {
    FILE *infile, *outfile;
    FIFO_t fifo;
    fifo_init(&fifo);
    
    infile = fopen("input_hex.txt", "r");
    if (infile == NULL) {
        fprintf(stderr, "error for opening file   input_hex.txt\n");
        return 1;
    }
    
    outfile = fopen("c_fifo_memory.txt", "w");
    if (outfile == NULL) {
        fprintf(stderr, "error for opening file    c_fifo_memory.txt\n");
        fclose(infile);
        return 1;
    }
    
    uint8_t value;
    // بخش نوشتن: خواندن هر خط از فایل ورودی و وارد کردن به FIFO
    while (fscanf(infile, "%2hhX", &value) == 1) {
        if (!fifo_write(&fifo, value)) {
            fprintf(stderr, "خطا: FIFO پر است در زمان نوشتن.\n");
            break;
        }
    }
    fclose(infile);
    
    // بخش خواندن: خواندن از FIFO و نوشتن خروجی در فایل
    while (!fifo_empty(&fifo)) {
        if (fifo_read(&fifo, &value)) {
            fprintf(outfile, "%02x\n", value);
        }
    }
    
    fclose(outfile);
    return 0;
}

