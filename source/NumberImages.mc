using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;

// Maps a single character to its number-image drawable, or null if there is no image for it.
function getNumberDrawable(ch) {
    if (ch == '0') { return Rez.Drawables.Zero; }
    else if (ch == '1') { return Rez.Drawables.One; }
    else if (ch == '2') { return Rez.Drawables.Two; }
    else if (ch == '3') { return Rez.Drawables.Three; }
    else if (ch == '4') { return Rez.Drawables.Four; }
    else if (ch == '5') { return Rez.Drawables.Five; }
    else if (ch == '6') { return Rez.Drawables.Six; }
    else if (ch == '7') { return Rez.Drawables.Seven; }
    else if (ch == '8') { return Rez.Drawables.Eight; }
    else if (ch == '9') { return Rez.Drawables.Nine; }
    else if (ch == ',') { return Rez.Drawables.Comma; }
    else if (ch == '.') { return Rez.Drawables.Period; }
    else if (ch == '$') { return Rez.Drawables.Dollar; }
    else if (ch == 'x') { return Rez.Drawables.x; }
    else if (ch == 'k' || ch == 'K') { return Rez.Drawables.Thousand; }
    else if (ch == 'm' || ch == 'M') { return Rez.Drawables.Million; }
    else if (ch == 'b' || ch == 'B') { return Rez.Drawables.Billion; }
    else if (ch == 't' || ch == 'T') { return Rez.Drawables.Trillion; }
    else if (ch == 'q' || ch == 'Q') { return Rez.Drawables.Quadrillion; }
    return null;
}

// Formats value with a magnitude suffix (1000 => "1k", 1500000 => "1.5M", etc.) so large numbers
// stay short enough to render as a row of number images. Keeps at most one decimal place and
// drops it entirely for whole numbers (1000000 => "1M", not "1.0M").
function abbreviateNumber(value) {
    var v = value.toLong();

    if (v >= 1000000000000000l) { return scaledAmount(v, 1000000000000000l) + "Q"; }
    else if (v >= 1000000000000l) { return scaledAmount(v, 1000000000000l) + "T"; }
    else if (v >= 1000000000l) { return scaledAmount(v, 1000000000l) + "B"; }
    else if (v >= 1000000l) { return scaledAmount(v, 1000000l) + "M"; }
    else if (v >= 1000l) { return scaledAmount(v, 1000l) + "k"; }
    return v.toString();
}

// value/divisor rounded down to one decimal place, e.g. scaledAmount(1500, 1000) => "1.5".
function scaledAmount(value, divisor) {
    var tenths = (value * 10) / divisor;
    var whole = tenths / 10;
    var tenth = tenths % 10;
    return (tenth == 0) ? whole.toString() : whole.toString() + "." + tenth.toString();
}

// Formats an integer with thousands-separating commas (1100 => "1,100").
function commaSeparate(value) {
    var digits = value.toLong().toString();
    var len = digits.length();
    var result = "";

    for (var i = 0; i < len; i++) {
        if (i > 0 && (len - i) % 3 == 0) {
            result += ",";
        }
        result += digits.substring(i, i + 1);
    }

    return result;
}

// Gaps below are tuned for 75px-tall glyphs; scale them proportionally for other sizes so
// larger/smaller renderings keep the same relative spacing.
const NUMBER_IMAGE_BASE_SIZE = 75;

// Gap to use before a regular (non comma/period) glyph, based on the last digit drawn.
function digitGap(lastDigit, size) {
    var base = (lastDigit == '1') ? 15 : 20;
    return (size * base) / NUMBER_IMAGE_BASE_SIZE;
}

// Gap to use before a comma or period, based on the last digit drawn.
function punctGap(lastDigit, size) {
    var base = (lastDigit == '1') ? 10 : 15;
    return (size * base) / NUMBER_IMAGE_BASE_SIZE;
}

// Extra-wide gap for appending a separate icon (e.g. a coin image) after number text, so it
// doesn't read as just another glued-on digit.
function iconGap(lastDigit, size) {
    return digitGap(lastDigit, size) * 2;
}

// The last digit (0-9) appearing in text, or null if it has none.
function lastDigitIn(text) {
    var chars = text.toCharArray();
    var lastDigit = null;

    for (var i = 0; i < chars.size(); i++) {
        var ch = chars[i];
        if (ch >= '0' && ch <= '9') {
            lastDigit = ch;
        }
    }

    return lastDigit;
}

// The relative x offset (left edge) of the last glyph in text, were it drawn starting at x = 0.
// Useful as an anchor for appending more glyphs/icons after the text using the same spacing rules.
function numberTextEndOffset(text, size) {
    var chars = text.toCharArray();
    var curX = 0;
    var lastDigit = null;

    for (var i = 0; i < chars.size(); i++) {
        var ch = chars[i];

        if (i > 0) {
            curX += (ch == ',' || ch == '.') ? punctGap(lastDigit, size) : digitGap(lastDigit, size);
        }

        if (ch >= '0' && ch <= '9') {
            lastDigit = ch;
        }
    }

    return curX;
}

// Total width text would occupy if drawn at the given size, with no trailing glyph appended.
function numberTextWidth(text, size) {
    return numberTextEndOffset(text, size) + size;
}

// Draws text as a row of size x size number images instead of a font, so the background stays
// transparent. Spacing from the previous character depends on the last digit drawn: regular gaps
// scale from 15px after a "1" and 20px otherwise (at a 75px base size); gaps into/out of a comma
// or period scale from 10px after a "1" and 15px otherwise (the glyph following a comma/period
// uses the same regular gap as if the comma/period weren't there).
// Returns the absolute x (left edge) of the last glyph drawn, so callers can append more
// glyphs/icons after the text using the same spacing rules (e.g. digitGap/iconGap).
function drawNumberText(dc, x, y, text, size) {
    var chars = text.toCharArray();
    var curX = x;
    var lastDigit = null;

    for (var i = 0; i < chars.size(); i++) {
        var ch = chars[i];

        if (i > 0) {
            curX += (ch == ',' || ch == '.') ? punctGap(lastDigit, size) : digitGap(lastDigit, size);
        }

        var drawable = getNumberDrawable(ch);
        if (drawable != null) {
            dc.drawScaledBitmap(curX, y, size, size, WatchUi.loadResource(drawable));
        }

        if (ch >= '0' && ch <= '9') {
            lastDigit = ch;
        }
    }

    return curX;
}

// Same as drawNumberText, but horizontally centered on centerX.
function drawNumberTextCentered(dc, centerX, y, text, size) {
    var startX = centerX - (numberTextWidth(text, size) / 2);
    return drawNumberText(dc, startX, y, text, size);
}
