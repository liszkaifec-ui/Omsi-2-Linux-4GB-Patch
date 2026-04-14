#!/bin/bash

# ============================================================
# OMSI 2 Linux Patcher v1.0
# Készítette: Omsi 2 linuxosoknak (Google Sites)
# Funkció: 4GB Patch (LAA) + Intel UHD/Mesa optimalizáció
# ============================================================

# Színek a terminálhoz
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================${NC}"
echo -e "${GREEN}   Omsi 2 optimization pack for linux        ${NC}"
echo -e "${BLUE}==============================================${NC}"

# 1. Útvonal meghatározása (Steam alapértelmezett)
OMSI_DIR="$HOME/.steam/steam/steamapps/common/OMSI 2"
EXE_NAME="Omsi.exe"
TARGET="$OMSI_DIR/$EXE_NAME"

# Ellenőrizzük, létezik-e a játék
if [ ! -f "$TARGET" ]; then
    echo -e "${RED}HIBA: Game not found!${NC}"
    echo "Pls chek the steam version installed"
    exit 1
fi

echo -e "${BLUE}[1/3] Saving...${NC}"
cp "$TARGET" "$TARGET.bak"
echo "Save done: Omsi.exe.bak"

# 2. A 4GB Patch alkalmazása Python segítségével
echo -e "${BLUE}[2/3] Applying 4GB Patch (LAA bit)...${NC}"

python3 -c "
import os
path = '$TARGET'
try:
    with open(path, 'r+b') as f:
        f.seek(0x3C)
        pe_offset = int.from_bytes(f.read(4), 'little')
        flag_pos = pe_offset + 4 + 18
        f.seek(flag_pos)
        flags = int.from_bytes(f.read(2), 'little')
        
        if flags & 0x0020:
            print('The game has the 4gb patch')
        else:
            new_flags = flags | 0x0020
            f.seek(flag_pos)
            f.write(new_flags.to_bytes(2, 'little'))
            print('Modified successfully!')
except Exception as e:
    print(f'Error during modification: {e}')
"

# 3. Intel UHD / Mesa optimalizáció (dxvk.conf)
echo -e "${BLUE}[3/3] Intel UHD Optimization Settings...${NC}"
cat <<EOF > "$OMSI_DIR/dxvk.conf"
d3d9.maxAvailableMemory = 2048
d3d9.projectionMethod = app
EOF

echo -e "${GREEN}Done! All settings done${NC}"
echo -e "${BLUE}==============================================${NC}"
echo -e "Utolsó lépés: Copy and paste into Steam's launch options:"
echo -e "${GREEN}gamemoderun PROTON_USE_WINED3D=0 %command%${NC}"
echo -e "${BLUE}==============================================${NC}"