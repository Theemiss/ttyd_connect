#!/bin/bash

SHELL=${SHELL:-/bin/bash}

if [ -n "$PASSWORD" ] && [ -z "$PASSWORD_HASH" ]; then
    PASSWORD_HASH=$(openssl passwd -1 "$PASSWORD" 2>/dev/null)
    export PASSWORD_HASH
fi

ARGS=()

if [ -n "$USERNAME" ] && [ -n "$PASSWORD_HASH" ]; then
    ARGS+=("--credential" "$USERNAME:$PASSWORD_HASH")
fi

if [ -f "/ssl/tls.crt" ] && [ -f "/ssl/tls.key" ]; then
    ARGS+=("--ssl" "--ssl-cert" "/ssl/tls.crt" "--ssl-key" "/ssl/tls.key")
fi

if [ -n "$TTYD_OPTIONS" ]; then
    IFS=' ' read -ra OPTIONS_ARRAY <<< "$TTYD_OPTIONS"
    ARGS+=("${OPTIONS_ARRAY[@]}")
fi

ARGS+=("--writable")
ARGS+=("-t" "enableSixel=true")
ARGS+=("-t" "enableTrzsz=true")
ARGS+=("-t" "enableZmodem=true")
ARGS+=("-t" "cursorStyle=bar")
ARGS+=("-t" "lineHeight=1.5")
ARGS+=("$SHELL")

cat > /usr/local/bin/ssh-to-host << 'EOF'
#!/bin/bash
ssh -i /root/.ssh/key.pem "$@"
EOF

chmod +x /usr/local/bin/ssh-to-host

echo "SSH configuration:"
echo "- Private key path: /root/.ssh/key.pem"
echo "- Config file: /root/.ssh/config"
if [ ! -f /root/.ssh/key.pem ]; then
    echo "WARNING: No private key mounted. Bind-mount key.pem at run time."
fi
if [ -f "/root/.ssh/config" ]; then
    echo "- Available hosts:"
    grep "Host " /root/.ssh/config | grep -v "*" | awk '{print "  - "$2}'
fi
echo ""
echo "Use: ssh <hostname>  or  ssh-to-host user@host"
echo "Starting ttyd..."

exec ttyd "${ARGS[@]}"
