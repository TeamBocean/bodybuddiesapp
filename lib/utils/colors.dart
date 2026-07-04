import 'dart:ui';

// BodyBuddies Figma design system
// Source: https://www.figma.com/design/OcwswyLIyFvouN8hwEAsCb/BodyBuddies

// Core canvas
const Color bbBackground = Color(0xFF0D0E11);
const Color bbSurface = Color(0xFF161920);
const Color bbCard = Color(0xFF1F222A);
const Color bbBorder = Color(0xFF262B36);

// Brand and interaction colors
const Color bbAccent = Color(0xFFCCFF00);
const Color bbAccentAlt = Color(0xFFD9C3B0);
const Color bbOnAccent = Color(0xFF0D0E11);

// Text hierarchy
const Color bbText = Color(0xFFF4F5F7);
const Color bbTextSecondary = Color(0xFF98A2B3);
const Color bbTextMuted = Color(0xFF98A2B3);

// Semantic
const Color bbRed = Color(0xFFEF4444);
const Color bbWarning = Color(0xFF8B3424);
const Color bbSuccess = Color(0xFF10B981);

// Legacy aliases (backwards compatibility)
Color background = bbBackground;
Color blackShade2 = bbSurface;
Color green = bbAccent;
Color lightGreen = bbAccentAlt;
Color darkGreen = bbAccent;
Color darkGrey = bbCard;

// Deprecated tokens (mapped to the Figma system)
const Color bbBlack = bbBackground;
const Color bbGrey = bbTextMuted;
const Color bbLightGrey = bbTextSecondary;
const Color bbWhite = bbText;
