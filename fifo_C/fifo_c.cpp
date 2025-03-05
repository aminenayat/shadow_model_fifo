#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define FIFO_SIZE 1024

typedef struct {
    uint8_t buffer[FIFO_SIZE];
    int write_ptr;
    int read_ptr;
    int count;
} FIFO_t;

FIFO_t fifo;

// مقداردهی اولیه FIFO
void fifo_init() {
    fifo.write_ptr = 0;
    fifo.read_ptr = 0;
    fifo.count = 0;
}

// بررسی پر بودن FIFO
int fifo_is_full() {
    return (fifo.count == FIFO_SIZE);
}

// بررسی خالی بودن FIFO
int fifo_is_empty() {
    return (fifo.count == 0);
}

// نوشتن در FIFO
int fifo_write(uint8_t data) {
    if (fifo_is_full()) {
        return -1; // FIFO پر است
    }
    fifo.buffer[fifo.write_ptr] = data;
    fifo.write_ptr = (fifo.write_ptr + 1) % FIFO_SIZE;
    fifo.count++;
    return 0; // موفقیت‌آمیز
}

// خواندن از FIFO
int fifo_read(uint8_t *data) {
    if (fifo_is_empty()) {
        return -1; // FIFO خالی است
    }
    *data = fifo.buffer[fifo.read_ptr];
    fifo.read_ptr = (fifo.read_ptr + 1) % FIFO_SIZE;
    fifo.count--;
    return 0; // موفقیت‌آمیز
}

// اجرای تست‌های FIFO
void run_fifo_tests() {
    int i;
    uint8_t data;
    int result;

    printf("--------------------------------------------------\n");
    printf("Test #1: Writing 1050 data and then reading 1050 data\n");

    fifo_init();
    
    for (i = 1; i <= 1050; i++) {
        uint8_t random_value = rand() & 0xFF;
        result = fifo_write(random_value);
        if (result == 0) {
            printf("  Writing data %d: %02X\n", i, random_value);
        } else {
            printf("  FIFO is full; cannot write data %d\n", i);
        }
    }

    printf("Now reading 1050 data from FIFO...\n");
    for (i = 1; i <= 1050; i++) {
        result = fifo_read(&data);
        if (result == 0) {
            printf("  Reading data %d: %02X\n", i, data);
        } else {
            printf("  FIFO is empty; cannot read data %d\n", i);
        }
    }

    printf("\n--------------------------------------------------\n");
    printf("Test #2: Writing 100 data and then reading 1050 data\n");

    fifo_init();
    
    for (i = 1; i <= 100; i++) {
        uint8_t random_value = rand() & 0xFF;
        result = fifo_write(random_value);
        if (result == 0) {
            printf("  Writing data %d: %02X\n", i, random_value);
        } else {
            printf("  FIFO is full; cannot write data %d\n", i);
        }
    }

    printf("Now reading 1050 data from FIFO...\n");
    for (i = 1; i <= 1050; i++) {
        result = fifo_read(&data);
        if (result == 0) {
            printf("  Reading data %d: %02X\n", i, data);
        } else {
            printf("  FIFO is empty; cannot read data %d\n", i);
        }
    }

    printf("\n--------------------------------------------------\n");
    printf("Test #3: Writing 1024 data and then reading 1024 data\n");

    fifo_init();
    
    for (i = 1; i <= 1024; i++) {
        uint8_t random_value = rand() & 0xFF;
        result = fifo_write(random_value);
        if (result == 0) {
            printf("  Writing data %d: %02X\n", i, random_value);
        } else {
            printf("  FIFO is full; cannot write data %d\n", i);
        }
    }

    printf("Now reading 1024 data from FIFO...\n");
    for (i = 1; i <= 1024; i++) {
        result = fifo_read(&data);
        if (result == 0) {
            printf("  Reading data %d: %02X\n", i, data);
        } else {
            printf("  FIFO is empty; cannot read data %d\n", i);
        }
    }
}

int main() {
    run_fifo_tests();
    return 0;
}
