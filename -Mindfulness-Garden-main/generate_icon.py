from PIL import Image, ImageDraw, ImageFilter
import math

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# ── Rounded rect background (green gradient simulation via layers) ──
radius = 220

def rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.ellipse([x0, y0, x0 + radius*2, y0 + radius*2], fill=fill)
    draw.ellipse([x1 - radius*2, y0, x1, y0 + radius*2], fill=fill)
    draw.ellipse([x0, y1 - radius*2, x0 + radius*2, y1], fill=fill)
    draw.ellipse([x1 - radius*2, y1 - radius*2, x1, y1], fill=fill)

# Gradient background: dark green top → light green bottom
for y in range(SIZE):
    t = y / SIZE
    r = int(20 + t * 30)
    g = int(90 + t * 80)
    b = int(40 + t * 30)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

# Apply rounded mask
mask = Image.new("L", (SIZE, SIZE), 0)
mask_draw = ImageDraw.Draw(mask)
rounded_rect(mask_draw, [0, 0, SIZE, SIZE], radius, 255)
img.putalpha(mask)

draw = ImageDraw.Draw(img)

# ── Soft glow circle in center ──
glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
for i in range(8, 0, -1):
    alpha = int(18 * i)
    r2 = 260 + i * 18
    gd.ellipse([SIZE//2 - r2, SIZE//2 - r2, SIZE//2 + r2, SIZE//2 + r2],
               fill=(180, 255, 160, alpha))
glow = glow.filter(ImageFilter.GaussianBlur(30))
img = Image.alpha_composite(img, glow)
draw = ImageDraw.Draw(img)

cx, cy = SIZE // 2, SIZE // 2

# ── Draw lotus flower ──
def draw_petal(draw, cx, cy, angle_deg, length, width, color, alpha=220):
    angle = math.radians(angle_deg)
    # petal tip
    tx = cx + math.cos(angle) * length
    ty = cy + math.sin(angle) * length
    # control points for bezier-like petal using polygon
    perp = math.radians(angle_deg + 90)
    p1x = cx + math.cos(perp) * width
    p1y = cy + math.sin(perp) * width
    p2x = cx - math.cos(perp) * width
    p2y = cy - math.sin(perp) * width
    # mid bulge
    mx = cx + math.cos(angle) * length * 0.55 + math.cos(perp) * width * 0.9
    my = cy + math.sin(angle) * length * 0.55 + math.sin(perp) * width * 0.9
    mx2 = cx + math.cos(angle) * length * 0.55 - math.cos(perp) * width * 0.9
    my2 = cy + math.sin(angle) * length * 0.55 - math.sin(perp) * width * 0.9
    pts = [(p1x, p1y), (mx, my), (tx, ty), (mx2, my2), (p2x, p2y)]
    draw.polygon(pts, fill=color + (alpha,))

# Outer petals (pink/white)
for i in range(8):
    angle = -90 + i * 45
    draw_petal(draw, cx, cy, angle, 310, 68, (255, 200, 220), 200)

# Inner petals (lighter)
for i in range(8):
    angle = -90 + i * 45 + 22.5
    draw_petal(draw, cx, cy, angle, 230, 52, (255, 230, 240), 210)

# Innermost petals
for i in range(6):
    angle = -90 + i * 60
    draw_petal(draw, cx, cy, angle, 155, 38, (255, 245, 250), 230)

# ── Center circle ──
draw.ellipse([cx-72, cy-72, cx+72, cy+72], fill=(255, 220, 80, 255))
draw.ellipse([cx-52, cy-52, cx+52, cy+52], fill=(255, 200, 40, 255))
draw.ellipse([cx-34, cy-34, cx+34, cy+34], fill=(255, 240, 120, 255))

# ── Leaves at bottom ──
def draw_leaf(draw, cx, cy, angle_deg, length, width, color):
    angle = math.radians(angle_deg)
    perp = math.radians(angle_deg + 90)
    tx = cx + math.cos(angle) * length
    ty = cy + math.sin(angle) * length
    p1x = cx + math.cos(perp) * width
    p1y = cy + math.sin(perp) * width
    p2x = cx - math.cos(perp) * width
    p2y = cy - math.sin(perp) * width
    mx = cx + math.cos(angle) * length * 0.5 + math.cos(perp) * width * 1.1
    my = cy + math.sin(angle) * length * 0.5 + math.sin(perp) * width * 1.1
    mx2 = cx + math.cos(angle) * length * 0.5 - math.cos(perp) * width * 1.1
    my2 = cy + math.sin(angle) * length * 0.5 - math.sin(perp) * width * 1.1
    pts = [(p1x, p1y), (mx, my), (tx, ty), (mx2, my2), (p2x, p2y)]
    draw.polygon(pts, fill=color)

draw_leaf(draw, cx, cy + 80, -60, 280, 55, (60, 180, 80, 220))
draw_leaf(draw, cx, cy + 80, -120, 280, 55, (50, 160, 70, 220))
draw_leaf(draw, cx, cy + 100, -90, 200, 40, (80, 200, 90, 200))

# ── Subtle sparkles ──
sparkle_positions = [
    (cx - 280, cy - 260), (cx + 290, cy - 240),
    (cx - 310, cy + 100), (cx + 300, cy + 120),
    (cx - 150, cy - 340), (cx + 160, cy - 330),
]
for sx, sy in sparkle_positions:
    for r, a in [(18, 180), (10, 220), (5, 255)]:
        draw.ellipse([sx-r, sy-r, sx+r, sy+r], fill=(255, 255, 200, a))

# Save
img.save("assets/images/app_icon.png", "PNG")
print(f"Icon saved: {img.size}")
