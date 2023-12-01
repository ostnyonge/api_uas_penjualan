#!/bin/bash

while true; do
    dart run bin/server.dart
    sleep 1  # Menunggu 1 detik sebelum memeriksa perubahan lagi
done
