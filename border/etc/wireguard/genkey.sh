#!/bin/bash
set -e

private=$(wg genkey); echo private/public key: ; echo $private; ( echo $private | wg pubkey)
