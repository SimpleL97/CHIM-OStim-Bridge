"""CHIM OStim Bridge - writes the game plugin build/CHIMOStimBridge.esp.

The plugin is tiny and has no art or world edits, so it is generated here byte by
byte instead of being saved from the Creation Kit or xEdit. Running this again gives
the same file. It holds:

  TES4 header   ESL flag (0x200), author SaurOff, master Skyrim.esm, form version 44
  0x800 QUST    COB_BridgeQuest  - script COB_Bridge  (CHIM actions -> OStim)
  0x801 QUST    COB_EventsQuest  - script COB_Events  (events, needs, settings to CHIM)
  0x802 QUST    COB_MCMQuest     - script COB_MCM     (MCM Helper menu) and a player
                                   alias with SkyUI's SKI_PlayerLoadGameAlias, which
                                   MCM Helper needs to re-register the menu on load

All three quests are start-game-enabled (DNAM flags 0x0111), so they also start
on an existing save. Run: python3 -I make_esp.py [output path]
"""
import os, struct, sys

ROOT = os.path.dirname(os.path.abspath(__file__))
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "build", "CHIMOStimBridge.esp")


def sub(tag, data):
    return tag + struct.pack('<H', len(data)) + data


def wstr(s):
    b = s.encode()
    return struct.pack('<H', len(b)) + b


def zstr(s):
    return s.encode() + b'\0'


def script(name):
    return wstr(name) + b'\x00' + struct.pack('<H', 0)  # status 0, no properties


def vmad_plain(name):
    return struct.pack('<hhH', 5, 2, 1) + script(name)  # VMAD version 5, object format 2, one script


def vmad_mcm(name, quest_fid):
    v = struct.pack('<hhH', 5, 2, 1) + script(name)
    v += b'\x02' + struct.pack('<H', 0) + struct.pack('<H', 0)  # quest fragments: version 2, none, no file
    v += struct.pack('<H', 1)                                   # one alias script block
    v += struct.pack('<HhI', 0, 0, quest_fid)                   # alias 0 of this quest
    v += struct.pack('<hhH', 5, 2, 1) + script('SKI_PlayerLoadGameAlias')
    return v


# start game enabled, run once off, priority 0xFF
DNAM = bytes.fromhex('110100ff0000000000000000')


def quest(fid, edid, full, vmad, alias=False):
    d = sub(b'EDID', zstr(edid)) + sub(b'VMAD', vmad) + sub(b'FULL', zstr(full)) + sub(b'DNAM', DNAM) + sub(b'NEXT', b'')
    if alias:
        d += sub(b'ANAM', struct.pack('<I', 1))
        d += sub(b'ALST', struct.pack('<I', 0)) + sub(b'ALID', zstr('PlayerAlias'))
        d += sub(b'FNAM', struct.pack('<I', 0)) + sub(b'ALFR', struct.pack('<I', 0x14))  # forced ref: the player (0x14)
        d += sub(b'VTCK', struct.pack('<I', 0)) + sub(b'ALED', b'')
    else:
        d += sub(b'ANAM', struct.pack('<I', 0))
    return b'QUST' + struct.pack('<IIIIHH', len(d), 0, fid, 0, 44, 0) + d


recs = quest(0x01000800, 'COB_BridgeQuest', 'CHIM OStim Bridge', vmad_plain('COB_Bridge'))
recs += quest(0x01000801, 'COB_EventsQuest', 'CHIM OStim Bridge Events', vmad_plain('COB_Events'))
recs += quest(0x01000802, 'COB_MCMQuest', 'CHIM OStim Bridge MCM', vmad_mcm('COB_MCM', 0x01000802), alias=True)
grup = b'GRUP' + struct.pack('<I', 24 + len(recs)) + b'QUST' + struct.pack('<IHHHH', 0, 0, 0, 0, 0) + recs

hdr = sub(b'HEDR', struct.pack('<fII', 1.71, 3, 0x803))  # version 1.71, 3 records, next object id
hdr += sub(b'CNAM', zstr('SaurOff'))
hdr += sub(b'SNAM', zstr('CHIM OStim Bridge - lets CHIM AI agents drive OStim scenes, react to events and live with simple needs.'))
hdr += sub(b'MAST', zstr('Skyrim.esm')) + sub(b'DATA', b'\0' * 8)
tes4 = b'TES4' + struct.pack('<IIIIHH', len(hdr), 0x200, 0, 0, 44, 0) + hdr

os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
open(out, 'wb').write(tes4 + grup)
print("written", out, len(tes4 + grup), "bytes")
