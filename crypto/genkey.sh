#!/usr/bin/env bash

# generates key pair for sopos
gpg --batch --gen-key genkey-batch.txt
gpg -k