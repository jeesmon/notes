#!/usr/bin/env python3

import argparse
import random
import string

SPECIAL_CHARS = "!@#$%^:?"
DIGITS = "23456789"
ASCII_LETTERS = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"

def generate_password(length, special_chars):
    chars = ASCII_LETTERS + DIGITS
    if special_chars:
        chars += SPECIAL_CHARS
    return ''.join(random.choice(chars) for _ in range(length))

def main():
    parser = argparse.ArgumentParser(description='Generate a random password')
    parser.add_argument('--length', type=int, default=20, help='Length of the password')
    parser.add_argument('--no-special-chars', action='store_true', help='Do not include special characters')
    args = parser.parse_args()
    print(generate_password(args.length, not args.no_special_chars))

if __name__ == '__main__':
    main()
