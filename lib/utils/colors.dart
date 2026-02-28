import 'dart:ui';

// ─── Editorial Atelier Design System ─────────────────────────────────────────
// Bone / Warm Sand / Charcoal / Deep Eucalyptus

// Core canvas
const Color bbBackground = Color(0xFFF5F0EB);   // Bone / Warm Linen
const Color bbSurface = Color(0xFFFFFFFF);       // Warm White
const Color bbCard = Color(0xFFEDE8E2);          // Parchment
const Color bbBorder = Color(0xFFD8D0C6);        // Sand Border

// Accent — Deep Eucalyptus (grounded, architectural, readable)
const Color bbAccent = Color(0xFF4D6B5C);        // Deep Eucalyptus
const Color bbAccentAlt = Color(0xFFB07858);     // Warm Clay (secondary)

// Text hierarchy — boosted contrast for readability
const Color bbText = Color(0xFF2C2C2C);          // Charcoal (never pure black)
const Color bbTextSecondary = Color(0xFF6B6158); // Warm Umber (readable)
const Color bbTextMuted = Color(0xFF958D83);     // Warm Stone (visible)

// Semantic
const Color bbRed = Color(0xFFB07858);           // Warm Clay (alerts)
const Color bbSuccess = Color(0xFF4D6B5C);       // Deep Eucalyptus (confirmations)

// ─── Legacy aliases (backwards compatibility) ────────────────────────────────
Color background = bbBackground;
Color blackShade2 = const Color(0xFFF0EBE5);
Color green = bbAccent;
Color lightGreen = const Color(0xFF6B8B7A);
Color darkGreen = bbAccent;
Color darkGrey = bbCard;

// ─── Deprecated tokens (mapped to new system) ───────────────────────────────
const Color bbBlack = bbBackground;
const Color bbGrey = bbTextMuted;
const Color bbLightGrey = bbTextSecondary;
const Color bbWhite = bbText;
