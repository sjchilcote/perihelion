"""Empirical check: does carving both sides of a breach at the SAME width
produce a scale-free portal transform, and does a mismatch produce scale?

This is the exact failure that made a previous build's reinforcements unable
to fit through the gate, so it is verified against the real engine, not read.
"""
import math, necore

def probe(width_a, width_b):
    s = necore.Sim()
    # two far-apart square chambers, 400 units on a side
    a = s.add_polygon([(0, 0), (400, 0), (400, 400), (0, 400)])
    b = s.add_polygon([(2000, 0), (2400, 0), (2400, 400), (2000, 400)])
    # carve a sub-edge of the requested width on edge 0 of each
    ea = s.split_edge(a, 0, 0.5 - width_a / 800.0, 0.5 + width_a / 800.0)
    eb = s.split_edge(b, 0, 0.5 - width_b / 800.0, 0.5 + width_b / 800.0)
    la = math.dist(*[s.edge_endpoints(a, ea)[i:i+2] for i in (0, 2)])
    lb = math.dist(*[s.edge_endpoints(b, eb)[i:i+2] for i in (0, 2)])
    s.connect(a, ea, b, eb)
    m = s.portal_xform(a, ea)
    # uniform scale of a 3x3 affine = length of its first column
    scale = math.hypot(m[0], m[3])
    return la, lb, scale

for wa, wb in ((96.0, 96.0), (96.0, 52.0), (52.0, 96.0)):
    la, lb, sc = probe(wa, wb)
    verdict = "RIGID (no scale)" if abs(sc - 1.0) < 1e-9 else f"SCALED x{sc:.4f}  <-- bodies resize crossing this"
    print(f"world edge {la:7.2f} | hub edge {lb:7.2f} | derived scale {sc:.6f}  {verdict}")
