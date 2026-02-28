import 'dart:ui';

// ─── Editorial Atelier Design System ─────────────────────────────────────────
// Bone / Warm Sand / Charcoal / Sage — inspired by Kinfolk & editorial studios

// Core canvas
const Color bbBackground = Color(0xFFF5F0EB);   // Bone / Warm Linen
const Color bbSurface = Color(0xFFFFFFFF);       // Warm White
const Color bbCard = Color(0xFFEDE8E2);          // Parchment
const Color bbBorder = Color(0xFFD8D0C6);        // Sand Border

// Accent
const Color bbAccent = Color(0xFF8A9A7B);        // Dusty Sage
const Color bbAccentAlt = Color(0xFFC4836A);     // Dusty Terracotta

// Text hierarchy
const Color bbText = Color(0xFF2C2C2C);          // Charcoal (never pure black)
const Color bbTextSecondary = Color(0xFF8C8278);  // Warm Grey
const Color bbTextMuted = Color(0xFFB0A89E);      // Sand Grey

// Semantic
const Color bbRed = Color(0xFFC4836A);           // Warm Terracotta (alerts)
const Color bbSuccess = Color(0xFF8A9A7B);       // Sage (confirmations)

// ─── Legacy aliases (backwards compatibility) ────────────────────────────────
Color background = bbBackground;
Color blackShade2 = const Color(0xFFF0EBE5);
Color green = bbAccent;
Color lightGreen = const Color(0xFFA8B89A);
Color darkGreen = bbAccent;
Color darkGrey = bbCard;

// ─── Deprecated tokens (mapped to new system) ───────────────────────────────
const Color bbBlack = bbBackground;
const Color bbGrey = bbTextMuted;
const Color bbLightGrey = bbTextSecondary;
const Color bbWhite = bbText;
