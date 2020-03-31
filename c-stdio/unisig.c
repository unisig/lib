#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "unisig.h"

char *read_unisig(FILE *input, int *out_is_uuid)
{
    const unsigned char magic[7]
        = { 0xdc, 0xdc, 0x0d, 0x0a, 0x1a, 0x0a, 0x00 };
    unsigned char head[sizeof(magic) + 1];
    char *sig;
    size_t len;
    int is_uuid;

    if (fread(head, 1, sizeof(head), input) != sizeof(head))
        return 0;
    if (memcmp(head, magic, sizeof(magic)))
        return 0;
    len = head[sizeof(magic)];
    *out_is_uuid = is_uuid = (len == 0);
    if (is_uuid)
        len = 16;
    sig = calloc(len + 1, 1);
    if (sig == NULL)
        goto fail; // Out of memory
    if (fread(sig, 1, len, input) != len)
        goto fail; // Read error or truncated file
    if (!is_uuid) {
        if (memchr(sig, '\0', len))
            goto fail; // Sig contains null byte, not usable as a C string.
    }
    return sig;
fail:
    free(sig);
    return NULL;
}
