// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' show Path, lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Applies a seek bar theme to descendant [SeekBar] widgets.
///
/// A seek bar theme describes the colors and shape choices of the seek bar
/// components.
///
/// Descendant widgets obtain the current theme's [SeekBarThemeData] object using
/// [SeekBarTheme.of]. When a widget uses [SeekBarTheme.of], it is automatically
/// rebuilt if the theme later changes.
///
/// The seek bar is as big as the largest of
/// the [SeekBarComponentShape.getPreferredSize] of the thumb shape,
/// the [SeekBarComponentShape.getPreferredSize] of the overlay shape,
/// and the [SeekBarTickMarkShape.getPreferredSize] of the tick mark shape
///
/// See also:
///
///  * [SeekBarThemeData], which describes the actual configuration of a seek bar
///    theme.
///  * [SeekBarComponentShape], which can be used to create custom shapes for
///    the seek bar thumb, overlay, and value indicator.
///  * [SeekBarTrackShape], which can be used to create custom shapes for the
///    seek bar track.
///  * [SeekBarTickMarkShape], which can be used to create custom shapes for the
///    seek bar tick marks.
class SeekBarTheme extends InheritedWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const SeekBarTheme({
    Key key,
    @required this.data,
    @required Widget child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key, child: child);

  /// Specifies the color and shape values for descendant seek bar widgets.
  final SeekBarThemeData data;

  /// Returns the data from the closest [SeekBarTheme] instance that encloses
  /// the given context.
  ///
  /// Defaults to the ambient [ThemeData.seekBarTheme] if there is no
  /// [SeekBarTheme] in the given build context.
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// class Launch extends StatefulWidget {
  ///   @override
  ///   State createState() => LaunchState();
  /// }
  ///
  /// class LaunchState extends State<Launch> {
  ///   double _rocketThrust;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return SeekBarTheme(
  ///       data: SeekBarTheme.of(context).copyWith(activeTrackColor: const Color(0xff804040)),
  ///       child: SeekBar(
  ///         onChanged: (double value) { setState(() { _rocketThrust = value; }); },
  ///         value: _rocketThrust,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [SeekBarThemeData], which describes the actual configuration of a seek bar
  ///    theme.
  static SeekBarThemeData of(BuildContext context) {
    final SeekBarTheme inheritedTheme =
        context.inheritFromWidgetOfExactType(SeekBarTheme);
    if (inheritedTheme != null) return inheritedTheme.data;
    final ThemeData themeData = Theme.of(context);
    return SeekBarThemeData.fromPrimaryColors(
      primaryColor: themeData.primaryColor,
      primaryColorDark: themeData.primaryColorDark,
      primaryColorLight: themeData.primaryColorLight,
      valueIndicatorTextStyle: themeData.primaryTextTheme.body1,
    );
  }

  @override
  bool updateShouldNotify(SeekBarTheme oldWidget) => data != oldWidget.data;
}

/// Describes the conditions under which the value indicator on a [SeekBar]
/// will be shown. Used with [SeekBarThemeData.showValueIndicator].
///
/// See also:
///
///  * [SeekBar], a Material Design seekBar widget.
///  * [SeekBarThemeData], which describes the actual configuration of a seekBar
///    theme.
enum ShowSeekBarValueIndicator {
  /// The value indicator will only be shown for discrete seekBars (seekBars
  /// where [SeekBar.divisions] is non-null).
  onlyForDiscrete,

  /// The value indicator will only be shown for continuous seekBars (seekBars
  /// where [SeekBar.divisions] is null).
  onlyForContinuous,

  /// The value indicator will be shown for all types of seekBars.
  always,

  /// The value indicator will never be shown.
  never,
}

/// Holds the color, shape, and typography values for a material design seekBar
/// theme.
///
/// Use this class to configure a [SeekBarTheme] widget, or to set the
/// [ThemeData] colors for a [Theme] widget.
///
/// To obtain the current ambient seekBar theme, use [SeekBarTheme.of].
///
/// The parts of a seekBar are:
///
///  * The "thumb", which is a shape that slides horizontally when the user
///    drags it.
///  * The "track", which is the line that the seekBar thumb slides along.
///  * The "tick marks", which are regularly spaced marks that are drawn when
///    using discrete divisions.
///  * The "value indicator", which appears when the user is dragging the thumb
///    to indicate the value being selected.
///  * The "overlay", which appears around the thumb, and is shown when the
///    thumb is pressed, focused, or hovered. It is painted underneath the
///    thumb, so it must extend beyond the bounds of the thumb itself to
///    actually be visible.
///  * The "active" side of the seekBar is the side between the thumb and the
///    minimum value.
///  * The "inactive" side of the seekBar is the side between the thumb and the
///    maximum value.
///  * The [SeekBar] is disabled when it is not accepting user input. See
///    [SeekBar] for details on when this happens.
///
/// The thumb, track, tick marks, value indicator, and overlay can be customized
/// by creating subclasses of [SeekBarTrackShape],
/// [SeekBarComponentShape], and/or [SeekBarTickMarkShape]. See
/// [RoundSeekBarThumbShape], [RectangularSeekBarTrackShape],
/// [RoundSeekBarTickMarkShape], [PaddleSeekBarValueIndicatorShape], and
/// [RoundSeekBarOverlayShape] for examples.
///
/// The track painting can be skipped by specifying 0 for [trackHeight].
/// The thumb painting can be skipped by specifying
/// [SeekBarComponentShape.noThumb] for [SeekBarThemeData.thumbShape].
/// The overlay painting can be skipped by specifying
/// [SeekBarComponentShape.noOverlay] for [SeekBarThemeData.overlayShape].
/// The tick mark painting can be skipped by specifying
/// [SeekBarTickMarkShape.noTickMark] for [SeekBarThemeData.tickMarkShape].
/// The value indicator painting can be skipped by specifying the
/// appropriate [ShowSeekBarValueIndicator] for [SeekBarThemeData.showValueIndicator].
///
/// See also:
///
///  * [SeekBarTheme] widget, which can override the seekBar theme of its
///    children.
///  * [Theme] widget, which performs a similar function to [SeekBarTheme],
///    but for overall themes.
///  * [ThemeData], which has a default [SeekBarThemeData].
///  * [SeekBarTrackShape], to define custom seekBar track shapes.
///  * [SeekBarComponentShape], to define custom seekBar component shapes.
///  * [SeekBarTickMarkShape], to define custom seekBar tick mark shapes.
class SeekBarThemeData extends Diagnosticable {
  /// Create a [SeekBarThemeData] given a set of exact values. All the values
  /// must be specified.
  ///
  /// This will rarely be used directly. It is used by [lerp] to
  /// create intermediate themes based on two themes.
  ///
  /// The simplest way to create a SeekBarThemeData is to use
  /// [copyWith] on the one you get from [SeekBarTheme.of], or create an
  /// entirely new one with [SeekBarThemeData.fromPrimaryColors].
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// class Blissful extends StatefulWidget {
  ///   @override
  ///   State createState() => BlissfulState();
  /// }
  ///
  /// class BlissfulState extends State<Blissful> {
  ///   double _bliss;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return SeekBarTheme(
  ///       data: SeekBarTheme.of(context).copyWith(activeTrackColor: const Color(0xff404080)),
  ///       child: SeekBar(
  ///         onChanged: (double value) { setState(() { _bliss = value; }); },
  ///         value: _bliss,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  const SeekBarThemeData({
    @required this.trackHeight,
    @required this.activeTrackColor,
    @required this.bufferTrackColor,
    @required this.inactiveTrackColor,
    @required this.disabledActiveTrackColor,
    @required this.disabledBufferTrackColor,
    @required this.disabledInactiveTrackColor,
    @required this.activeTickMarkColor,
    @required this.inactiveTickMarkColor,
    @required this.disabledActiveTickMarkColor,
    @required this.disabledInactiveTickMarkColor,
    @required this.thumbColor,
    @required this.disabledThumbColor,
    @required this.overlayColor,
    @required this.valueIndicatorColor,
    @required this.trackActiveShape,
    @required this.trackBufferShape,
    @required this.trackInactiveShape,
    @required this.tickMarkShape,
    @required this.thumbShape,
    @required this.overlayShape,
    @required this.valueIndicatorShape,
    @required this.showValueIndicator,
    @required this.valueIndicatorTextStyle,
  })  : assert(trackHeight != null),
        assert(activeTrackColor != null),
        assert(bufferTrackColor != null),
        assert(inactiveTrackColor != null),
        assert(disabledActiveTrackColor != null),
        assert(disabledInactiveTrackColor != null),
        assert(activeTickMarkColor != null),
        assert(inactiveTickMarkColor != null),
        assert(disabledActiveTickMarkColor != null),
        assert(disabledInactiveTickMarkColor != null),
        assert(thumbColor != null),
        assert(disabledThumbColor != null),
        assert(overlayColor != null),
        assert(valueIndicatorColor != null),
        assert(trackActiveShape != null),
        assert(trackBufferShape != null),
        assert(trackInactiveShape != null),
        assert(tickMarkShape != null),
        assert(thumbShape != null),
        assert(overlayShape != null),
        assert(valueIndicatorShape != null),
        assert(valueIndicatorTextStyle != null),
        assert(showValueIndicator != null);

  /// Generates a SeekBarThemeData from three main colors.
  ///
  /// Usually these are the primary, dark and light colors from
  /// a [ThemeData].
  ///
  /// The opacities of these colors will be overridden with the Material Design
  /// defaults when assigning them to the seekBar theme component colors.
  ///
  /// This is used to generate the default seekBar theme for a [ThemeData].
  factory SeekBarThemeData.fromPrimaryColors({
    @required Color primaryColor,
    @required Color primaryColorDark,
    @required Color primaryColorLight,
    @required TextStyle valueIndicatorTextStyle,
  }) {
    assert(primaryColor != null);
    assert(primaryColorDark != null);
    assert(primaryColorLight != null);
    assert(valueIndicatorTextStyle != null);

    // These are Material Design defaults, and are used to derive
    // component Colors (with opacity) from base colors.
    const int activeTrackAlpha = 0xff;
    const int bufferTrackAlpha = 0x80; // 50% opacity
    const int inactiveTrackAlpha = 0x3d; // 24% opacity
    const int disabledActiveTrackAlpha = 0x52; // 32% opacity
    const int disabledBufferTrackAlpha = 0x38; // 22% opacity
    const int disabledInactiveTrackAlpha = 0x1f; // 12% opacity
    const int activeTickMarkAlpha = 0x8a; // 54% opacity
    const int inactiveTickMarkAlpha = 0x8a; // 54% opacity
    const int disabledActiveTickMarkAlpha = 0x1f; // 12% opacity
    const int disabledInactiveTickMarkAlpha = 0x1f; // 12% opacity
    const int thumbAlpha = 0xff;
    const int disabledThumbAlpha = 0x52; // 32% opacity
    const int valueIndicatorAlpha = 0xff;

    // TODO(gspencer): We don't really follow the spec here for overlays.
    // The spec says to use 16% opacity for drawing over light material,
    // and 32% for colored material, but we don't really have a way to
    // know what the underlying color is, so there's no easy way to
    // implement this. Choosing the "light" version for now.
    const int overlayLightAlpha = 0x29; // 16% opacity

    return SeekBarThemeData(
      trackHeight: 2.0,
      activeTrackColor: primaryColor.withAlpha(activeTrackAlpha),
      bufferTrackColor: primaryColor.withAlpha(bufferTrackAlpha),
      inactiveTrackColor: primaryColor.withAlpha(inactiveTrackAlpha),
      disabledActiveTrackColor:
          primaryColorDark.withAlpha(disabledActiveTrackAlpha),
      disabledBufferTrackColor:
          primaryColorDark.withAlpha(disabledBufferTrackAlpha),
      disabledInactiveTrackColor:
          primaryColorDark.withAlpha(disabledInactiveTrackAlpha),
      activeTickMarkColor: primaryColorLight.withAlpha(activeTickMarkAlpha),
      inactiveTickMarkColor: primaryColor.withAlpha(inactiveTickMarkAlpha),
      disabledActiveTickMarkColor:
          primaryColorLight.withAlpha(disabledActiveTickMarkAlpha),
      disabledInactiveTickMarkColor:
          primaryColorDark.withAlpha(disabledInactiveTickMarkAlpha),
      thumbColor: primaryColor.withAlpha(thumbAlpha),
      disabledThumbColor: primaryColorDark.withAlpha(disabledThumbAlpha),
      overlayColor: primaryColor.withAlpha(overlayLightAlpha),
      valueIndicatorColor: primaryColor.withAlpha(valueIndicatorAlpha),
      trackActiveShape: const RectangularSeekBarTrackActiveShape(),
      trackBufferShape: const RectangularSeekBarTrackBufferShape(),
      trackInactiveShape: const RectangularSeekBarTrackInactiveShape(),
      tickMarkShape: const RoundSeekBarTickMarkShape(),
      thumbShape: const RoundSeekBarThumbShape(),
      overlayShape: const RoundSeekBarOverlayShape(),
      valueIndicatorShape: const PaddleSeekBarValueIndicatorShape(),
      valueIndicatorTextStyle: valueIndicatorTextStyle,
      showValueIndicator: ShowSeekBarValueIndicator.onlyForDiscrete,
    );
  }

  /// The height of the [SeekBar] track.
  final double trackHeight;

  /// The color of the [SeekBar] track between the [SeekBar.min] position and the
  /// current thumb position.
  final Color activeTrackColor;

  /// The color of the [SeekBar] track between all [SeekBar.buffer] ranges.
  final Color bufferTrackColor;

  /// The color of the [SeekBar] track between the current thumb position and the
  /// [SeekBar.max] position.
  final Color inactiveTrackColor;

  /// The color of the [SeekBar] track between the [SeekBar.min] position and the
  /// current thumb position when the [SeekBar] is disabled.
  final Color disabledActiveTrackColor;

  /// The color of the [SeekBar] track between all [SeekBar.buffer] ranges when
  /// the [SeekBar] is disabled.
  final Color disabledBufferTrackColor;

  /// The color of the [SeekBar] track between the current thumb position and the
  /// [SeekBar.max] position when the [SeekBar] is disabled.
  final Color disabledInactiveTrackColor;

  /// The color of the track's tick marks that are drawn between the [SeekBar.min]
  /// position and the current thumb position.
  final Color activeTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [SeekBar.max] position.
  final Color inactiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the [SeekBar.min]
  /// position and the current thumb position when the [SeekBar] is disabled.
  final Color disabledActiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [SeekBar.max] position when the [SeekBar] is
  /// disabled.
  final Color disabledInactiveTickMarkColor;

  /// The color given to the [thumbShape] to draw itself with.
  final Color thumbColor;

  /// The color given to the [thumbShape] to draw itself with when the
  /// [SeekBar] is disabled.
  final Color disabledThumbColor;

  /// The color of the overlay drawn around the seekBar thumb when it is pressed.
  ///
  /// This is typically a semi-transparent color.
  final Color overlayColor;

  /// The color given to the [valueIndicatorShape] to draw itself with.
  final Color valueIndicatorColor;

  /// The shape that will be used to draw the [SeekBar]'s active track.
  ///
  /// The [SeekBarTrackShape.getPreferredRect] method is used to map
  /// seekBar-relative gesture coordinates to the correct thumb position on the
  /// track. It is also used to horizontally position tick marks, when he seekBar
  /// is discrete.
  ///
  /// The default value is [RectangularSeekBarTrackInactiveShape].
  final SeekBarTrackShape trackActiveShape;

  final SeekBarTrackShape trackBufferShape;

  /// The shape that will be used to draw the [SeekBar]'s inactive track.
  ///
  /// The [SeekBarTrackShape.getPreferredRect] method is used to map
  /// seekBar-relative gesture coordinates to the correct thumb position on the
  /// track. It is also used to horizontally position tick marks, when he seekBar
  /// is discrete.
  ///
  /// The default value is [RectangularSeekBarTrackInactiveShape].
  final SeekBarTrackShape trackInactiveShape;

  /// The shape that will be used to draw the [SeekBar]'s tick marks.
  ///
  /// The [SeekBarTickMarkShape.getPreferredSize] is used to help determine the
  /// location of each tick mark on the track. The seekBar's minimum size will
  /// be at least this big.
  ///
  /// The default value is [RoundSeekBarTickMarkShape].
  final SeekBarTickMarkShape tickMarkShape;

  /// The shape that will be used to draw the [SeekBar]'s overlay.
  ///
  /// Both the [overlayColor] and a non default [overlayShape] may be specified.
  /// In this case, the [overlayColor] is only used if the [overlayShape]
  /// explicitly does so.
  ///
  /// The default value is [RoundSeekBarOverlayShape].
  final SeekBarComponentShape overlayShape;

  /// The shape that will be used to draw the [SeekBar]'s thumb.
  final SeekBarComponentShape thumbShape;

  /// The shape that will be used to draw the [SeekBar]'s value
  /// indicator.
  final SeekBarComponentShape valueIndicatorShape;

  /// Whether the value indicator should be shown for different types of
  /// seekBars.
  ///
  /// By default, [showValueIndicator] is set to
  /// [ShowSeekBarValueIndicator.onlyForDiscrete]. The value indicator is only shown
  /// when the thumb is being touched.
  final ShowSeekBarValueIndicator showValueIndicator;

  /// The text style for the text on the value indicator.
  ///
  /// By default this is the [ThemeData.accentTextTheme.body2] text theme.
  final TextStyle valueIndicatorTextStyle;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  SeekBarThemeData copyWith({
    double trackHeight,
    Color activeTrackColor,
    Color bufferTrackColor,
    Color inactiveTrackColor,
    Color disabledActiveTrackColor,
    Color disabledBufferTrackColor,
    Color disableBufferTrackColor,
    Color disabledInactiveTrackColor,
    Color activeTickMarkColor,
    Color inactiveTickMarkColor,
    Color disabledActiveTickMarkColor,
    Color disabledInactiveTickMarkColor,
    Color thumbColor,
    Color disabledThumbColor,
    Color overlayColor,
    Color valueIndicatorColor,
    SeekBarTrackShape trackActiveShape,
    SeekBarTrackShape trackBufferShape,
    SeekBarTrackShape trackInactiveShape,
    SeekBarTickMarkShape tickMarkShape,
    SeekBarComponentShape thumbShape,
    SeekBarComponentShape overlayShape,
    SeekBarComponentShape valueIndicatorShape,
    ShowSeekBarValueIndicator showValueIndicator,
    TextStyle valueIndicatorTextStyle,
  }) {
    return SeekBarThemeData(
      trackHeight: trackHeight ?? this.trackHeight,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      bufferTrackColor: bufferTrackColor ?? this.bufferTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      disabledActiveTrackColor:
          disabledActiveTrackColor ?? this.disabledActiveTrackColor,
      disabledBufferTrackColor:
          disabledBufferTrackColor ?? this.disabledBufferTrackColor,
      disabledInactiveTrackColor:
          disabledInactiveTrackColor ?? this.disabledInactiveTrackColor,
      activeTickMarkColor: activeTickMarkColor ?? this.activeTickMarkColor,
      inactiveTickMarkColor:
          inactiveTickMarkColor ?? this.inactiveTickMarkColor,
      disabledActiveTickMarkColor:
          disabledActiveTickMarkColor ?? this.disabledActiveTickMarkColor,
      disabledInactiveTickMarkColor:
          disabledInactiveTickMarkColor ?? this.disabledInactiveTickMarkColor,
      thumbColor: thumbColor ?? this.thumbColor,
      disabledThumbColor: disabledThumbColor ?? this.disabledThumbColor,
      overlayColor: overlayColor ?? this.overlayColor,
      valueIndicatorColor: valueIndicatorColor ?? this.valueIndicatorColor,
      trackActiveShape: trackActiveShape ?? this.trackActiveShape,
      trackBufferShape: trackBufferShape ?? this.trackBufferShape,
      trackInactiveShape: trackInactiveShape ?? this.trackInactiveShape,
      tickMarkShape: tickMarkShape ?? this.tickMarkShape,
      thumbShape: thumbShape ?? this.thumbShape,
      overlayShape: overlayShape ?? this.overlayShape,
      valueIndicatorShape: valueIndicatorShape ?? this.valueIndicatorShape,
      showValueIndicator: showValueIndicator ?? this.showValueIndicator,
      valueIndicatorTextStyle:
          valueIndicatorTextStyle ?? this.valueIndicatorTextStyle,
    );
  }

  /// Linearly interpolate between two seekBar themes.
  ///
  /// The arguments must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static SeekBarThemeData lerp(
      SeekBarThemeData a, SeekBarThemeData b, double t) {
    assert(a != null);
    assert(b != null);
    assert(t != null);
    return SeekBarThemeData(
      trackHeight: lerpDouble(a.trackHeight, b.trackHeight, t),
      activeTrackColor: Color.lerp(a.activeTrackColor, b.activeTrackColor, t),
      bufferTrackColor: Color.lerp(a.bufferTrackColor, b.bufferTrackColor, t),
      inactiveTrackColor:
          Color.lerp(a.inactiveTrackColor, b.inactiveTrackColor, t),
      disabledActiveTrackColor:
          Color.lerp(a.disabledActiveTrackColor, b.disabledActiveTrackColor, t),
      disabledBufferTrackColor:
          Color.lerp(a.disabledBufferTrackColor, b.disabledBufferTrackColor, t),
      disabledInactiveTrackColor: Color.lerp(
          a.disabledInactiveTrackColor, b.disabledInactiveTrackColor, t),
      activeTickMarkColor:
          Color.lerp(a.activeTickMarkColor, b.activeTickMarkColor, t),
      inactiveTickMarkColor:
          Color.lerp(a.inactiveTickMarkColor, b.inactiveTickMarkColor, t),
      disabledActiveTickMarkColor: Color.lerp(
          a.disabledActiveTickMarkColor, b.disabledActiveTickMarkColor, t),
      disabledInactiveTickMarkColor: Color.lerp(
          a.disabledInactiveTickMarkColor, b.disabledInactiveTickMarkColor, t),
      thumbColor: Color.lerp(a.thumbColor, b.thumbColor, t),
      disabledThumbColor:
          Color.lerp(a.disabledThumbColor, b.disabledThumbColor, t),
      overlayColor: Color.lerp(a.overlayColor, b.overlayColor, t),
      valueIndicatorColor:
          Color.lerp(a.valueIndicatorColor, b.valueIndicatorColor, t),
      trackActiveShape: t < 0.5 ? a.trackActiveShape : b.trackActiveShape,
      trackBufferShape: t < 0.5 ? a.trackBufferShape : b.trackBufferShape,
      trackInactiveShape: t < 0.5 ? a.trackInactiveShape : b.trackInactiveShape,
      tickMarkShape: t < 0.5 ? a.tickMarkShape : b.tickMarkShape,
      thumbShape: t < 0.5 ? a.thumbShape : b.thumbShape,
      overlayShape: t < 0.5 ? a.overlayShape : b.overlayShape,
      valueIndicatorShape:
          t < 0.5 ? a.valueIndicatorShape : b.valueIndicatorShape,
      showValueIndicator: t < 0.5 ? a.showValueIndicator : b.showValueIndicator,
      valueIndicatorTextStyle: TextStyle.lerp(
          a.valueIndicatorTextStyle, b.valueIndicatorTextStyle, t),
    );
  }

  @override
  int get hashCode {
    return hashValues(
      trackHeight,
      hashList(<Color>[
        activeTrackColor,
        bufferTrackColor,
        inactiveTrackColor,
        disabledActiveTrackColor,
        disabledInactiveTrackColor,
        activeTickMarkColor,
        inactiveTickMarkColor,
        disabledActiveTickMarkColor,
        disabledInactiveTickMarkColor,
        thumbColor,
        disabledThumbColor,
        overlayColor,
        valueIndicatorColor,
      ]),
      trackActiveShape,
      trackBufferShape,
      trackInactiveShape,
      tickMarkShape,
      thumbShape,
      overlayShape,
      valueIndicatorShape,
      showValueIndicator,
      valueIndicatorTextStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final SeekBarThemeData otherData = other;
    return otherData.trackHeight == trackHeight &&
        otherData.activeTrackColor == activeTrackColor &&
        otherData.inactiveTrackColor == inactiveTrackColor &&
        otherData.disabledActiveTrackColor == disabledActiveTrackColor &&
        otherData.disabledInactiveTrackColor == disabledInactiveTrackColor &&
        otherData.activeTickMarkColor == activeTickMarkColor &&
        otherData.inactiveTickMarkColor == inactiveTickMarkColor &&
        otherData.disabledActiveTickMarkColor == disabledActiveTickMarkColor &&
        otherData.disabledInactiveTickMarkColor ==
            disabledInactiveTickMarkColor &&
        otherData.thumbColor == thumbColor &&
        otherData.disabledThumbColor == disabledThumbColor &&
        otherData.overlayColor == overlayColor &&
        otherData.valueIndicatorColor == valueIndicatorColor &&
        otherData.trackActiveShape == trackActiveShape &&
        otherData.tickMarkShape == tickMarkShape &&
        otherData.thumbShape == thumbShape &&
        otherData.overlayShape == overlayShape &&
        otherData.valueIndicatorShape == valueIndicatorShape &&
        otherData.showValueIndicator == showValueIndicator &&
        otherData.valueIndicatorTextStyle == valueIndicatorTextStyle;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final ThemeData defaultTheme = ThemeData.fallback();
    final SeekBarThemeData defaultData = SeekBarThemeData.fromPrimaryColors(
      primaryColor: defaultTheme.primaryColor,
      primaryColorDark: defaultTheme.primaryColorDark,
      primaryColorLight: defaultTheme.primaryColorLight,
      valueIndicatorTextStyle: defaultTheme.accentTextTheme.body2,
    );
    properties.add(DiagnosticsProperty<Color>(
        'activeTrackColor', activeTrackColor,
        defaultValue: defaultData.activeTrackColor));
    properties.add(DiagnosticsProperty<Color>(
        'bufferTrackColor', bufferTrackColor,
        defaultValue: defaultData.bufferTrackColor));
    properties.add(DiagnosticsProperty<Color>(
        'inactiveTrackColor', inactiveTrackColor,
        defaultValue: defaultData.inactiveTrackColor));
    properties.add(DiagnosticsProperty<Color>(
        'disabledActiveTrackColor', disabledActiveTrackColor,
        defaultValue: defaultData.disabledActiveTrackColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>(
        'disabledInactiveTrackColor', disabledInactiveTrackColor,
        defaultValue: defaultData.disabledInactiveTrackColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>(
        'activeTickMarkColor', activeTickMarkColor,
        defaultValue: defaultData.activeTickMarkColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>(
        'inactiveTickMarkColor', inactiveTickMarkColor,
        defaultValue: defaultData.inactiveTickMarkColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>(
        'disabledActiveTickMarkColor', disabledActiveTickMarkColor,
        defaultValue: defaultData.disabledActiveTickMarkColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>(
        'disabledInactiveTickMarkColor', disabledInactiveTickMarkColor,
        defaultValue: defaultData.disabledInactiveTickMarkColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>('thumbColor', thumbColor,
        defaultValue: defaultData.thumbColor));
    properties.add(DiagnosticsProperty<Color>(
        'disabledThumbColor', disabledThumbColor,
        defaultValue: defaultData.disabledThumbColor,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>('overlayColor', overlayColor,
        defaultValue: defaultData.overlayColor, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Color>(
        'valueIndicatorColor', valueIndicatorColor,
        defaultValue: defaultData.valueIndicatorColor));
    properties.add(DiagnosticsProperty<SeekBarTrackShape>(
        'trackActiveShape', trackActiveShape,
        defaultValue: defaultData.trackActiveShape,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<SeekBarTrackShape>(
        'trackBufferShape', trackBufferShape,
        defaultValue: defaultData.trackBufferShape,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<SeekBarTrackShape>(
        'trackInactiveShape', trackInactiveShape,
        defaultValue: defaultData.trackInactiveShape,
        level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<SeekBarTickMarkShape>(
        'tickMarkShape', tickMarkShape,
        defaultValue: defaultData.tickMarkShape, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<SeekBarComponentShape>(
        'thumbShape', thumbShape,
        defaultValue: defaultData.thumbShape, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<SeekBarComponentShape>(
        'overlayShape', overlayShape,
        defaultValue: defaultData.overlayShape, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<SeekBarComponentShape>(
        'valueIndicatorShape', valueIndicatorShape,
        defaultValue: defaultData.valueIndicatorShape,
        level: DiagnosticLevel.debug));
    properties.add(EnumProperty<ShowSeekBarValueIndicator>(
        'showValueIndicator', showValueIndicator,
        defaultValue: defaultData.showValueIndicator));
    properties.add(DiagnosticsProperty<TextStyle>(
        'valueIndicatorTextStyle', valueIndicatorTextStyle,
        defaultValue: defaultData.valueIndicatorTextStyle));
  }
}

// TEMPLATES FOR ALL SHAPES

/// {@template flutter.material.seekBar.shape.context}
/// [context] is the same context for the render box of the [SeekBar].
/// {@endtemplate}
///
/// {@template flutter.material.seekBar.shape.center}
/// [center] is the offset of the center where this shape should be painted.
/// This offset is relative to the origin of the [context] canvas.
/// {@endtemplate}
///
/// {@template flutter.material.seekBar.shape.seekBarTheme}
/// [seekBarTheme] is the theme assigned to the [SeekBar] that this shape
/// belongs to.
/// {@endtemplate}
///
/// {@template flutter.material.seekBar.shape.isEnabled}
/// [isEnabled] has the same value as [SeekBar.isInteractive]. If true, the
/// seekBar will respond to input.
/// {@endtemplate}
///
/// {@template flutter.material.seekBar.shape.enableAnimation}
/// [enableAnimation] is an animation triggered when the [SeekBar] is enabled,
/// and it reverses when the seekBar is disabled. Enabled is the
/// [SeekBar.isInteractive] state. Use this to paint intermediate frames for
/// this shape when the seekBar changes enabled state.
/// {@endtemplate}
///
/// {@template flutter.material.seekBar.shape.isDiscrete}
/// [isDiscrete] is true if [SeekBar.divisions] is non-null. If true, the
/// seekBar will render tick marks on top of the track.
/// {@endtemplate}
///
/// {@template flutter.material.seekBar.shape.parentBox}
/// [parentBox] is the [RenderBox] of the [SeekBar]. Its attributes, such as
/// size, can be used to assist in painting this shape.
/// {@endtemplate}

/// Base class for seekBar track shapes.
///
/// The seekBar's thumb moves along the track. A discrete seekBar's tick marks
/// are drawn after the track, but before the thumb, and are aligned with the
/// track.
///
/// The [getPreferredRect] helps position the seekBar thumb and tick marks
/// relative to the track.
///
/// See also:
///
///  * [RectangularSeekBarTrackShape], which is the default track shape.
///  * [SeekBarTickMarkShape], which is the default tick mark shape.
///  * [SeekBarComponentShape], which is the base class for custom a component
///    shape.
abstract class SeekBarTrackShape {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SeekBarTrackShape();

  /// Returns the preferred bounds of the shape.
  ///
  /// It is used to provide horizontal boundaries for the thumb's position, and
  /// to help position the seekBar thumb and tick marks relative to the track.
  ///
  /// [parentBox] can be used to help determine the preferredRect relative to
  /// attributes of the render box of the seekBar itself, such as size.
  ///
  /// [offset] is relative to the caller's bounding box. It can be used to
  /// convert gesture coordinates from global to seekBar-relative coordinates.
  ///
  /// {@macro flutter.material.seekBar.shape.seekBarTheme}
  ///
  /// {@macro flutter.material.seekBar.shape.isEnabled}
  ///
  /// {@macro flutter.material.seekBar.shape.isDiscrete}
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SeekBarThemeData seekBarTheme,
    bool isEnabled,
    bool isDiscrete,
  });

  /// Paints the track shape based on the state passed to it.
  ///
  /// {@macro flutter.material.seekBar.shape.context}
  ///
  /// [offset] is the offset of the origin of the [parentBox] to the origin of
  /// its [context] canvas. This shape must be painted relative to this
  /// offset. See [PaintingContextCallback].
  ///
  /// {@macro flutter.material.seekBar.shape.parentBox}
  ///
  /// {@macro flutter.material.seekBar.shape.seekBarTheme}
  ///
  /// {@macro flutter.material.seekBar.shape.enableAnimation}
  ///
  /// [thumbCenter] is the offset of the center of the thumb relative to the
  /// origin of the [PaintingContext.canvas]. It can be used as the point that
  /// divides the track into 2 segments.
  ///
  /// {@macro flutter.material.seekBar.shape.isEnabled}
  ///
  /// {@macro flutter.material.seekBar.shape.isDiscrete}
  ///
  /// [textDirection] can be used to determine how the track segments are
  /// painted depending on whether they are active or not. The track segment
  /// between the start of the seekBar and the thumb is the active track segment.
  /// The track segment between the thumb and the end of the seekBar is the
  /// inactive track segment. In LTR text direction, the start of the seekBar is
  /// on the left, and in RTL text direction, the start of the seekBar is on the
  /// right.
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    Offset thumbCenter,
    Offset bufferCenter,
    bool isEnabled,
    bool isDiscrete,
    TextDirection textDirection,
  });
}

/// Base class for seekBar tick mark shapes.
///
/// Create a subclass of this if you would like a custom seekBar tick mark shape.
/// This is a simplified version of [SeekBarComponentShape] with a
/// [SeekBarThemeData] passed when getting the preferred size.
///
/// The tick mark painting can be skipped by specifying [noTickMark] for
/// [SeekBarThemeData.tickMarkShape].
///
/// See also:
///
///  * [RoundSeekBarTickMarkShape] for a simple example of a tick mark shape.
///  * [SeekBarTrackShape] for the base class for custom a track shape.
///  * [SeekBarComponentShape] for the base class for custom a component shape.
abstract class SeekBarTickMarkShape {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SeekBarTickMarkShape();

  /// Returns the preferred size of the shape.
  ///
  /// It is used to help position the tick marks within the seekBar.
  ///
  /// {@macro flutter.material.seekBar.shape.seekBarTheme}
  ///
  /// {@macro flutter.material.seekBar.shape.isEnabled}
  Size getPreferredSize({
    SeekBarThemeData seekBarTheme,
    bool isEnabled,
  });

  /// Paints the seekBar track.
  ///
  /// {@macro flutter.material.seekBar.shape.context}
  ///
  /// {@macro flutter.material.seekBar.shape.center}
  ///
  /// {@macro flutter.material.seekBar.shape.parentBox}
  ///
  /// {@macro flutter.material.seekBar.shape.seekBarTheme}
  ///
  /// {@macro flutter.material.seekBar.shape.enableAnimation}
  ///
  /// {@macro flutter.material.seekBar.shape.isEnabled}
  ///
  /// [textDirection] can be used to determine how the tick marks are painting
  /// depending on whether they are on an active track segment or not. The track
  /// segment between the start of the seekBar and the thumb is the active track
  /// segment. The track segment between the thumb and the end of the seekBar is
  /// the inactive track segment. In LTR text direction, the start of the seekBar
  /// is on the left, and in RTL text direction, the start of the seekBar is on
  /// the right.
  void paint(
    PaintingContext context,
    Offset center, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    Offset thumbCenter,
    bool isEnabled,
    TextDirection textDirection,
  });

  /// Special instance of [SeekBarTickMarkShape] to skip the tick mark painting.
  ///
  /// See also:
  ///
  /// * [SeekBarThemeData.tickMarkShape], which is the shape that the [SeekBar]
  /// uses when painting tick marks.
  static final SeekBarTickMarkShape noTickMark = _EmptySeekBarTickMarkShape();
}

/// A special version of [SeekBarTickMarkShape] that has a zero size and paints
/// nothing.
///
/// This class is used to create a special instance of a [SeekBarTickMarkShape]
/// that will not paint any tick mark shape. A static reference is stored in
/// [SeekBarTickMarkShape.noTickMark]. When this value  is specified for
/// [SeekBarThemeData.tickMarkShape], the tick mark painting is skipped.
class _EmptySeekBarTickMarkShape extends SeekBarTickMarkShape {
  @override
  Size getPreferredSize({
    SeekBarThemeData seekBarTheme,
    bool isEnabled,
  }) {
    return Size.zero;
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    Offset thumbCenter,
    bool isEnabled,
    TextDirection textDirection,
  }) {
    // no-op.
  }
}

/// Base class for seekBar thumb, thumb overlay, and value indicator shapes.
///
/// Create a subclass of this if you would like a custom shape.
///
/// All shapes are painted to the same canvas and ordering is important.
/// The overlay is painted first, then the value indicator, then the thumb.
///
/// The thumb painting can be skipped by specifying [noThumb] for
/// [SeekBarThemeData.thumbShape].
///
/// The overlay painting can be skipped by specifying [noOverlay] for
/// [SeekBarThemeData.overlayShape].
///
/// See also:
///
///  * [RoundSeekBarThumbShape], which is the the default thumb shape.
///  * [RoundSeekBarOverlayShape], which is the the default overlay shape.
///  * [PaddleSeekBarValueIndicatorShape], which is the the default value
///    indicator shape.
abstract class SeekBarComponentShape {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SeekBarComponentShape();

  /// Returns the preferred size of the shape, based on the given conditions.
  Size getPreferredSize(bool isEnabled, bool isDiscrete);

  /// Paints the shape, taking into account the state passed to it.
  ///
  /// {@macro flutter.material.seekBar.shape.context}
  ///
  /// {@macro flutter.material.seekBar.shape.center}
  ///
  /// [activationAnimation] is an animation triggered when the user beings
  /// to interact with the seekBar. It reverses when the user stops interacting
  /// with the seekBar.
  ///
  /// {@macro flutter.material.seekBar.shape.enableAnimation}
  ///
  /// {@macro flutter.material.seekBar.shape.isDiscrete}
  ///
  /// If [labelPainter] is non-null, then [labelPainter.paint] should be
  /// called with the location that the label should appear. If the labelPainter
  /// passed is null, then no label was supplied to the [SeekBar].
  ///
  /// {@macro flutter.material.seekBar.shape.parentBox}
  ///
  /// {@macro flutter.material.seekBar.shape.seekBarTheme}
  ///
  /// [textDirection] can be used to determine how any extra text or graphics,
  /// besides the text painted by the [labelPainter] should be positioned. The
  /// [labelPainter] already has the [textDirection] set.
  ///
  /// [value] is the current parametric value (from 0.0 to 1.0) of the seekBar.
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    TextDirection textDirection,
    double value,
  });

  /// Special instance of [SeekBarComponentShape] to skip the thumb drawing.
  ///
  /// See also:
  ///
  /// * [SeekBarThemeData.thumbShape], which is the shape that the [SeekBar]
  /// uses when painting the thumb.
  static final SeekBarComponentShape noThumb = _EmptySeekBarComponentShape();

  /// Special instance of [SeekBarComponentShape] to skip the overlay drawing.
  ///
  /// See also:
  ///
  /// * [SeekBarThemeData.overlayShape], which is the shape that the [SeekBar]
  /// uses when painting the overlay.
  static final SeekBarComponentShape noOverlay = _EmptySeekBarComponentShape();
}

/// A special version of [SeekBarComponentShape] that has a zero size and paints
/// nothing.
///
/// This class is used to create a special instance of a [SeekBarComponentShape]
/// that will not paint any component shape. A static reference is stored in
/// [SeekBarTickMarkShape.noThumb] and [SeekBarTickMarkShape.noOverlay]. When this value
/// is specified for [SeekBarThemeData.thumbShape], the thumb painting is
/// skipped.  When this value is specified for [SeekBarThemeData.overlaySHape],
/// the overlay painting is skipped.
class _EmptySeekBarComponentShape extends SeekBarComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    TextDirection textDirection,
    double value,
  }) {
    // no-op.
  }
}

// The following shapes are the material defaults.

/// This is the default shape of a [SeekBar]'s track.
///
/// It paints a solid colored rectangle, vertically centered in the
/// [parentBox]. The track rectangle extends to the bounds of the [parentBox],
/// but is padded by the [RoundSeekBarOverlayShape] radius. The height is defined
/// by the [SeekBarThemeData.trackHeight]. The color is determined by the
/// [SeekBar]'s enabled state and the track piece's active state which are
/// defined by:
///   [SeekBarThemeData.activeTrackColor],
///   [SeekBarThemeData.inactiveTrackColor],
///   [SeekBarThemeData.disabledActiveTrackColor],
///   [SeekBarThemeData.disabledInactiveTrackColor].
///
/// See also:
///
///  * [SeekBar] for the component that this is meant to display this shape.
///  * [SeekBarThemeData] where an instance of this class is set to inform the
///    seekBar of the visual details of the its track.
///  * [SeekBarTrackShape] Base component for creating other custom track
///    shapes.
abstract class RectangularSeekBarTrackShape extends SeekBarTrackShape {
  /// Create a seekBar track that draws 2 rectangles.
  const RectangularSeekBarTrackShape({this.disabledThumbGapWidth = 2.0});

  /// Horizontal spacing, or gap, between the disabled thumb and the track.
  ///
  /// This is only used when the seekBar is disabled. There is no gap around
  /// the thumb and any part of the track when the seekBar is enabled. The
  /// Material spec defaults this gap width 2, which is half of the disabled
  /// thumb radius.
  final double disabledThumbGapWidth;

  @override
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SeekBarThemeData seekBarTheme,
    bool isEnabled,
    bool isDiscrete,
  }) {
    final double overlayWidth =
        seekBarTheme.overlayShape.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = seekBarTheme.trackHeight;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    // TODO(clocksmith): Although this works for a material, perhaps the default
    // rectangular track should be padded not just by the overlay, but by the
    // max of the thumb and the overlay, in case there is no overlay.
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class RectangularSeekBarTrackActiveShape extends RectangularSeekBarTrackShape {
  /// Create a seekBar track that draws 2 rectangles.
  const RectangularSeekBarTrackActiveShape({double disabledThumbGapWidth = 2.0})
      : super(disabledThumbGapWidth: disabledThumbGapWidth);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    TextDirection textDirection,
    Offset thumbCenter,
    Offset bufferCenter,
    bool isDiscrete,
    bool isEnabled,
  }) {
    // If the seekBar track height is 0, then it makes no difference whether the
    // track is painted or not, therefore the painting can be a no-op.
    if (seekBarTheme.trackHeight == 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: seekBarTheme.disabledActiveTrackColor,
        end: seekBarTheme.activeTrackColor);

    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation);

    // Used to create a gap around the thumb if the seekBar is disabled.
    // If the seekBar is enabled, the track can be drawn beneath the thumb
    // without a gap. But when the seekBar is disabled, the track is shortened
    // and this gap helps determine how much shorter it should be.
    // TODO(clocksmith): The new Material spec has a gray circle in place of this gap.
    double horizontalAdjustment = 0.0;
    if (!isEnabled) {
      final double disabledThumbRadius =
          seekBarTheme.thumbShape.getPreferredSize(false, isDiscrete).width /
              2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      seekBarTheme: seekBarTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    Rect activeSegment;
    switch (textDirection) {
      case TextDirection.ltr:
        activeSegment = Rect.fromLTRB(trackRect.left, trackRect.top,
            thumbCenter.dx - horizontalAdjustment, trackRect.bottom);
        break;
      case TextDirection.rtl:
        activeSegment = Rect.fromLTRB(thumbCenter.dx + horizontalAdjustment,
            trackRect.top, trackRect.right, trackRect.bottom);
        break;
    }
    context.canvas.drawRect(activeSegment, activePaint);
  }
}

class RectangularSeekBarTrackInactiveShape
    extends RectangularSeekBarTrackShape {
  /// Create a seekBar track that draws 2 rectangles.
  const RectangularSeekBarTrackInactiveShape(
      {double disabledThumbGapWidth = 2.0})
      : super(disabledThumbGapWidth: disabledThumbGapWidth);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    TextDirection textDirection,
    Offset thumbCenter,
    Offset bufferCenter,
    bool isDiscrete,
    bool isEnabled,
  }) {
    // If the seekBar track height is 0, then it makes no difference whether the
    // track is painted or not, therefore the painting can be a no-op.
    if (seekBarTheme.trackHeight == 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: seekBarTheme.disabledInactiveTrackColor,
        end: seekBarTheme.inactiveTrackColor);

    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation);

    // Used to create a gap around the thumb if the seekBar is disabled.
    // If the seekBar is enabled, the track can be drawn beneath the thumb
    // without a gap. But when the seekBar is disabled, the track is shortened
    // and this gap helps determine how much shorter it should be.
    // TODO(clocksmith): The new Material spec has a gray circle in place of this gap.
    double horizontalAdjustment = 0.0;
    if (!isEnabled) {
      final double disabledThumbRadius =
          seekBarTheme.thumbShape.getPreferredSize(false, isDiscrete).width /
              2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      seekBarTheme: seekBarTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    Rect inactiveSegment;
    switch (textDirection) {
      case TextDirection.ltr:
        inactiveSegment = Rect.fromLTRB(thumbCenter.dx + horizontalAdjustment,
            trackRect.top, trackRect.right, trackRect.bottom);
        break;
      case TextDirection.rtl:
        inactiveSegment = Rect.fromLTRB(trackRect.left, trackRect.top,
            thumbCenter.dx - horizontalAdjustment, trackRect.bottom);
        break;
    }
    context.canvas.drawRect(inactiveSegment, inactivePaint);
  }
}

/// This is the default shape of a [SeekBar]'s track.
///
/// It paints a solid colored rectangle, vertically centered in the
/// [parentBox]. The track rectangle extends to the bounds of the [parentBox],
/// but is padded by the [RoundSeekBarOverlayShape] radius. The height is defined
/// by the [SeekBarThemeData.trackHeight]. The color is determined by the
/// [SeekBar]'s enabled state and the track piece's active state which are
/// defined by:
///   [SeekBarThemeData.activeTrackColor],
///   [SeekBarThemeData.inactiveTrackColor],
///   [SeekBarThemeData.disabledActiveTrackColor],
///   [SeekBarThemeData.disabledInactiveTrackColor].
///
/// See also:
///
///  * [SeekBar] for the component that this is meant to display this shape.
///  * [SeekBarThemeData] where an instance of this class is set to inform the
///    seekBar of the visual details of the its track.
///  * [SeekBarTrackShape] Base component for creating other custom track
///    shapes.
class RectangularSeekBarTrackBufferShape extends RectangularSeekBarTrackShape {
  /// Create a seekBar buffer that draws 1 rectangles.
  const RectangularSeekBarTrackBufferShape({double disabledThumbGapWidth = 2.0})
      : super(disabledThumbGapWidth: disabledThumbGapWidth);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    TextDirection textDirection,
    Offset thumbCenter,
    Offset bufferCenter,
    bool isDiscrete,
    bool isEnabled,
  }) {
    // If the seekBar track height is 0, then it makes no difference whether the
    // buffer is painted or not, therefore the painting can be a no-op.
    if (seekBarTheme.trackHeight == 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.

    final ColorTween bufferTrackColorTween = ColorTween(
        begin: seekBarTheme.disabledBufferTrackColor,
        end: seekBarTheme.bufferTrackColor);

    final Paint bufferPaint = Paint()
      ..color = bufferTrackColorTween.evaluate(enableAnimation);

    // Used to create a gap around the thumb if the seekBar is disabled.
    // If the seekBar is enabled, the track can be drawn beneath the thumb
    // without a gap. But when the seekBar is disabled, the track is shortened
    // and this gap helps determine how much shorter it should be.
    // TODO(clocksmith): The new Material spec has a gray circle in place of this gap.
    double horizontalAdjustment = 0.0;
    if (!isEnabled) {
      final double disabledThumbRadius =
          seekBarTheme.thumbShape.getPreferredSize(false, isDiscrete).width /
              2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      seekBarTheme: seekBarTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    /// TODO(axellebot): Add adjustment when the buffer segment is near the thumb
    Rect bufferSegment;
    switch (textDirection) {
      case TextDirection.ltr:
        bufferSegment = Rect.fromLTRB(
            bufferCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);
        break;
      case TextDirection.rtl:
        bufferSegment = Rect.fromLTRB(
            trackRect.left, trackRect.top, bufferCenter.dx, trackRect.bottom);
        break;
    }
    context.canvas.drawRect(bufferSegment, bufferPaint);
  }
}

/// This is the default shape of each [SeekBar] tick mark.
///
/// Tick marks are only displayed if the seekBar is discrete, which can be done
/// by setting the [SeekBar.divisions] as non-null.
///
/// It paints a solid circle, centered in the on the track.
/// The color is determined by the [SeekBar]'s enabled state and track's active
/// states. These colors are defined in:
///   [SeekBarThemeData.activeTrackColor],
///   [SeekBarThemeData.inactiveTrackColor],
///   [SeekBarThemeData.disabledActiveTrackColor],
///   [SeekBarThemeData.disabledInactiveTrackColor].
///
/// See also:
///
///  * [SeekBar], which includes tick marks defined by this shape.
///  * [SeekBarTheme], which can be used to configure the tick mark shape of all
///    seekBars in a widget subtree.
class RoundSeekBarTickMarkShape extends SeekBarTickMarkShape {
  /// Create a seekBar tick mark that draws a circle.
  const RoundSeekBarTickMarkShape({this.tickMarkRadius});

  /// The preferred radius of the round tick mark.
  ///
  /// If it is not provided, then half of the track height is used.
  final double tickMarkRadius;

  @override
  Size getPreferredSize({
    bool isEnabled,
    SeekBarThemeData seekBarTheme,
  }) {
    // The tick marks are tiny circles. If no radius is provided, then they are
    // defaulted to be the same height as the track.
    return Size.fromRadius(tickMarkRadius ?? seekBarTheme.trackHeight / 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    Animation<double> enableAnimation,
    TextDirection textDirection,
    Offset thumbCenter,
    bool isEnabled,
  }) {
    // The paint color of the tick mark depends on its position relative
    // to the thumb and the text direction.
    Color begin;
    Color end;
    switch (textDirection) {
      case TextDirection.ltr:
        final bool isTickMarkRightOfThumb = center.dx > thumbCenter.dx;
        begin = isTickMarkRightOfThumb
            ? seekBarTheme.disabledInactiveTickMarkColor
            : seekBarTheme.disabledActiveTickMarkColor;
        end = isTickMarkRightOfThumb
            ? seekBarTheme.inactiveTickMarkColor
            : seekBarTheme.activeTickMarkColor;
        break;
      case TextDirection.rtl:
        final bool isTickMarkLeftOfThumb = center.dx < thumbCenter.dx;
        begin = isTickMarkLeftOfThumb
            ? seekBarTheme.disabledInactiveTickMarkColor
            : seekBarTheme.disabledActiveTickMarkColor;
        end = isTickMarkLeftOfThumb
            ? seekBarTheme.inactiveTickMarkColor
            : seekBarTheme.activeTickMarkColor;
        break;
    }
    final Paint paint = Paint()
      ..color = ColorTween(begin: begin, end: end).evaluate(enableAnimation);

    // The tick marks are tiny circles that are the same height as the track.
    final double tickMarkRadius = getPreferredSize(
          isEnabled: isEnabled,
          seekBarTheme: seekBarTheme,
        ).width /
        2;
    context.canvas.drawCircle(center, tickMarkRadius, paint);
  }
}

/// This is the default shape of a [SeekBar]'s thumb.
///
/// See also:
///
///  * [SeekBar], which includes a thumb defined by this shape.
///  * [SeekBarTheme], which can be used to configure the thumb shape of all
///    seekBars in a widget subtree.
class RoundSeekBarThumbShape extends SeekBarComponentShape {
  /// Create a seekBar thumb that draws a circle.
  // TODO(clocksmith): This needs to be changed to 10 according to spec.
  const RoundSeekBarThumbShape({
    this.enabledThumbRadius = 6.0,
    this.disabledThumbRadius,
  });

  /// The preferred radius of the round thumb shape when the seekBar is enabled.
  ///
  /// If it is not provided, then the material default is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the seekBar is disabled.
  ///
  /// If no disabledRadius is provided, then it is is derived from the enabled
  /// thumb radius and has the same ratio of enabled size to disabled size as
  /// the Material spec. The default resolves to 4, which is 2 / 3 of the
  /// default enabled thumb.
  final double disabledThumbRadius;

  // TODO(clocksmith): This needs to be updated once the thumb size is updated to the Material spec.
  double get _disabledThumbRadius =>
      disabledThumbRadius ?? enabledThumbRadius * 2 / 3;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: seekBarTheme.disabledThumbColor,
      end: seekBarTheme.thumbColor,
    );
    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()..color = colorTween.evaluate(enableAnimation),
    );
  }
}

/// This is the default shape of a [SeekBar]'s thumb overlay.
///
/// The shape of the overlay is a circle with the same center as the thumb, but
/// with a larger radius. It animates to full size when the thumb is pressed,
/// and animates back down to size 0 when it is released. It is painted behind
/// the thumb, and is expected to extend beyond the bounds of the thumb so that
/// it is visible.
///
/// The overlay color is defined by [SeekBarThemeData.overlayColor].
///
/// See also:
///
///  * [SeekBar], which includes an overlay defined by this shape.
///  * [SeekBarTheme], which can be used to configure the overlay shape of all
///    seekBars in a widget subtree.
class RoundSeekBarOverlayShape extends SeekBarComponentShape {
  /// Create a seekBar thumb overlay that draws a circle.
  // TODO(clocksmith): This needs to be changed to 24 according to spec.
  const RoundSeekBarOverlayShape({this.overlayRadius = 16.0});

  /// The preferred radius of the round thumb shape when enabled.
  ///
  /// If it is not provided, then half of the track height is used.
  final double overlayRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(overlayRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: 0.0,
      end: overlayRadius,
    );

    // TODO(gspencer): We don't really follow the spec here for overlays.
    // The spec says to use 16% opacity for drawing over light material,
    // and 32% for colored material, but we don't really have a way to
    // know what the underlying color is, so there's no easy way to
    // implement this. Choosing the "light" version for now.
    canvas.drawCircle(
      center,
      radiusTween.evaluate(activationAnimation),
      Paint()..color = seekBarTheme.overlayColor,
    );
  }
}

/// This is the default shape of a [SeekBar]'s value indicator.
///
/// See also:
///
///  * [SeekBar], which includes a value indicator defined by this shape.
///  * [SeekBarTheme], which can be used to configure the seekBar value indicator
///    of all seekBars in a widget subtree.
class PaddleSeekBarValueIndicatorShape extends SeekBarComponentShape {
  /// Create a seekBar value indicator in the shape of an upside-down pear.
  const PaddleSeekBarValueIndicatorShape();

  // These constants define the shape of the default value indicator.
  // The value indicator changes shape based on the size of
  // the label: The top lobe spreads horizontally, and the
  // top arc on the neck moves down to keep it merging smoothly
  // with the top lobe as it expands.

  // Radius of the top lobe of the value indicator.
  static const double _topLobeRadius = 16.0;

  // Designed size of the label text. This is the size that the value indicator
  // was designed to contain. We scale it from here to fit other sizes.
  static const double _labelTextDesignSize = 14.0;

  // Radius of the bottom lobe of the value indicator.
  static const double _bottomLobeRadius = 6.0;

  // The starting angle for the bottom lobe. Picked to get the desired
  // thickness for the neck.
  static const double _bottomLobeStartAngle = -1.1 * math.pi / 4.0;

  // The ending angle for the bottom lobe. Picked to get the desired
  // thickness for the neck.
  static const double _bottomLobeEndAngle = 1.1 * 5 * math.pi / 4.0;

  // The padding on either side of the label.
  static const double _labelPadding = 8.0;
  static const double _distanceBetweenTopBottomCenters = 40.0;
  static const Offset _topLobeCenter =
      Offset(0.0, -_distanceBetweenTopBottomCenters);
  static const double _topNeckRadius = 14.0;

  // The length of the hypotenuse of the triangle formed by the center
  // of the left top lobe arc and the center of the top left neck arc.
  // Used to calculate the position of the center of the arc.
  static const double _neckTriangleHypotenuse = _topLobeRadius + _topNeckRadius;

  // Some convenience values to help readability.
  static const double _twoSeventyDegrees = 3.0 * math.pi / 2.0;
  static const double _ninetyDegrees = math.pi / 2.0;
  static const double _thirtyDegrees = math.pi / 6.0;
  static const Size _preferredSize = Size.fromHeight(
      _distanceBetweenTopBottomCenters + _topLobeRadius + _bottomLobeRadius);

  // Set to true if you want a rectangle to be drawn around the label bubble.
  // This helps with building tests that check that the label draws in the right
  // place (because it prints the rect in the failed test output). It should not
  // be checked in while set to "true".
  static const bool _debuggingLabelLocation = false;

  static Path _bottomLobePath; // Initialized by _generateBottomLobe
  static Offset _bottomLobeEnd; // Initialized by _generateBottomLobe

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => _preferredSize;

  // Adds an arc to the path that has the attributes passed in. This is
  // a convenience to make adding arcs have less boilerplate.
  static void _addArc(Path path, Offset center, double radius,
      double startAngle, double endAngle) {
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    path.arcTo(arcRect, startAngle, endAngle - startAngle, false);
  }

  // Generates the bottom lobe path, which is the same for all instances of
  // the value indicator, so we reuse it for each one.
  static void _generateBottomLobe() {
    const double bottomNeckRadius = 4.5;
    const double bottomNeckStartAngle = _bottomLobeEndAngle - math.pi;
    const double bottomNeckEndAngle = 0.0;

    final Path path = Path();
    final Offset bottomKnobStart = Offset(
      _bottomLobeRadius * math.cos(_bottomLobeStartAngle),
      _bottomLobeRadius * math.sin(_bottomLobeStartAngle),
    );
    final Offset bottomNeckRightCenter = bottomKnobStart +
        Offset(
          bottomNeckRadius * math.cos(bottomNeckStartAngle),
          -bottomNeckRadius * math.sin(bottomNeckStartAngle),
        );
    final Offset bottomNeckLeftCenter = Offset(
      -bottomNeckRightCenter.dx,
      bottomNeckRightCenter.dy,
    );
    final Offset bottomNeckStartRight = Offset(
      bottomNeckRightCenter.dx - bottomNeckRadius,
      bottomNeckRightCenter.dy,
    );
    path.moveTo(bottomNeckStartRight.dx, bottomNeckStartRight.dy);
    _addArc(
      path,
      bottomNeckRightCenter,
      bottomNeckRadius,
      math.pi - bottomNeckEndAngle,
      math.pi - bottomNeckStartAngle,
    );
    _addArc(
      path,
      Offset.zero,
      _bottomLobeRadius,
      _bottomLobeStartAngle,
      _bottomLobeEndAngle,
    );
    _addArc(
      path,
      bottomNeckLeftCenter,
      bottomNeckRadius,
      bottomNeckStartAngle,
      bottomNeckEndAngle,
    );

    _bottomLobeEnd = Offset(
      -bottomNeckStartRight.dx,
      bottomNeckStartRight.dy,
    );
    _bottomLobePath = path;
  }

  Offset _addBottomLobe(Path path) {
    if (_bottomLobePath == null || _bottomLobeEnd == null) {
      // Generate this lazily so as to not slow down app startup.
      _generateBottomLobe();
    }
    path.extendWithPath(_bottomLobePath, Offset.zero);
    return _bottomLobeEnd;
  }

  // Determines the "best" offset to keep the bubble on the screen. The calling
  // code will bound that with the available movement in the paddle shape.
  double _getIdealOffset(
    RenderBox parentBox,
    double halfWidthNeeded,
    double scale,
    Offset center,
  ) {
    const double edgeMargin = 4.0;
    final Rect topLobeRect = Rect.fromLTWH(
      -_topLobeRadius - halfWidthNeeded,
      -_topLobeRadius - _distanceBetweenTopBottomCenters,
      2.0 * (_topLobeRadius + halfWidthNeeded),
      2.0 * _topLobeRadius,
    );
    // We can just multiply by scale instead of a transform, since we're scaling
    // around (0, 0).
    final Offset topLeft = (topLobeRect.topLeft * scale) + center;
    final Offset bottomRight = (topLobeRect.bottomRight * scale) + center;
    double shift = 0.0;
    if (topLeft.dx < edgeMargin) {
      shift = edgeMargin - topLeft.dx;
    }
    if (bottomRight.dx > parentBox.size.width - edgeMargin) {
      shift = parentBox.size.width - bottomRight.dx - edgeMargin;
    }
    shift = scale == 0.0 ? 0.0 : shift / scale;
    return shift;
  }

  void _drawValueIndicator(
    RenderBox parentBox,
    Canvas canvas,
    Offset center,
    Paint paint,
    double scale,
    TextPainter labelPainter,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // The entire value indicator should scale with the size of the label,
    // to keep it large enough to encompass the label text.
    final double textScaleFactor = labelPainter.height / _labelTextDesignSize;
    final double overallScale = scale * textScaleFactor;
    canvas.scale(overallScale, overallScale);
    final double inverseTextScale =
        textScaleFactor != 0 ? 1.0 / textScaleFactor : 0.0;
    final double labelHalfWidth = labelPainter.width / 2.0;

    // This is the needed extra width for the label.  It is only positive when
    // the label exceeds the minimum size contained by the round top lobe.
    final double halfWidthNeeded = math.max(
      0.0,
      inverseTextScale * labelHalfWidth - (_topLobeRadius - _labelPadding),
    );

    double shift =
        _getIdealOffset(parentBox, halfWidthNeeded, overallScale, center);
    double leftWidthNeeded;
    double rightWidthNeeded;
    if (shift < 0.0) {
      // shifting to the left
      shift = math.max(shift, -halfWidthNeeded);
    } else {
      // shifting to the right
      shift = math.min(shift, halfWidthNeeded);
    }
    rightWidthNeeded = halfWidthNeeded + shift;
    leftWidthNeeded = halfWidthNeeded - shift;

    final Path path = Path();
    final Offset bottomLobeEnd = _addBottomLobe(path);

    // The base of the triangle between the top lobe center and the centers of
    // the two top neck arcs.
    final double neckTriangleBase = _topNeckRadius - bottomLobeEnd.dx;
    // The parameter that describes how far along the transition from round to
    // stretched we are.
    final double leftAmount =
        math.max(0.0, math.min(1.0, leftWidthNeeded / neckTriangleBase));
    final double rightAmount =
        math.max(0.0, math.min(1.0, rightWidthNeeded / neckTriangleBase));
    // The angle between the top neck arc's center and the top lobe's center
    // and vertical.
    final double leftTheta = (1.0 - leftAmount) * _thirtyDegrees;
    final double rightTheta = (1.0 - rightAmount) * _thirtyDegrees;
    // The center of the top left neck arc.
    final Offset neckLeftCenter = Offset(
      -neckTriangleBase,
      _topLobeCenter.dy + math.cos(leftTheta) * _neckTriangleHypotenuse,
    );
    final Offset neckRightCenter = Offset(
      neckTriangleBase,
      _topLobeCenter.dy + math.cos(rightTheta) * _neckTriangleHypotenuse,
    );
    final double leftNeckArcAngle = _ninetyDegrees - leftTheta;
    final double rightNeckArcAngle = math.pi + _ninetyDegrees - rightTheta;
    // The distance between the end of the bottom neck arc and the beginning of
    // the top neck arc. We use this to shrink/expand it based on the scale
    // factor of the value indicator.
    final double neckStretchBaseline =
        bottomLobeEnd.dy - math.max(neckLeftCenter.dy, neckRightCenter.dy);
    final double t = math.pow(inverseTextScale, 3.0);
    final double stretch =
        (neckStretchBaseline * t).clamp(0.0, 10.0 * neckStretchBaseline);
    final Offset neckStretch = Offset(0.0, neckStretchBaseline - stretch);

    assert(!_debuggingLabelLocation ||
        () {
          final Offset leftCenter =
              _topLobeCenter - Offset(leftWidthNeeded, 0.0) + neckStretch;
          final Offset rightCenter =
              _topLobeCenter + Offset(rightWidthNeeded, 0.0) + neckStretch;
          final Rect valueRect = Rect.fromLTRB(
            leftCenter.dx - _topLobeRadius,
            leftCenter.dy - _topLobeRadius,
            rightCenter.dx + _topLobeRadius,
            rightCenter.dy + _topLobeRadius,
          );
          final Paint outlinePaint = Paint()
            ..color = const Color(0xffff0000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRect(valueRect, outlinePaint);
          return true;
        }());

    _addArc(
      path,
      neckLeftCenter + neckStretch,
      _topNeckRadius,
      0.0,
      -leftNeckArcAngle,
    );
    _addArc(
      path,
      _topLobeCenter - Offset(leftWidthNeeded, 0.0) + neckStretch,
      _topLobeRadius,
      _ninetyDegrees + leftTheta,
      _twoSeventyDegrees,
    );
    _addArc(
      path,
      _topLobeCenter + Offset(rightWidthNeeded, 0.0) + neckStretch,
      _topLobeRadius,
      _twoSeventyDegrees,
      _twoSeventyDegrees + math.pi - rightTheta,
    );
    _addArc(
      path,
      neckRightCenter + neckStretch,
      _topNeckRadius,
      rightNeckArcAngle,
      math.pi,
    );
    canvas.drawPath(path, paint);

    // Draw the label.
    canvas.save();
    canvas.translate(shift, -_distanceBetweenTopBottomCenters + neckStretch.dy);
    canvas.scale(inverseTextScale, inverseTextScale);
    labelPainter.paint(canvas,
        Offset.zero - Offset(labelHalfWidth, labelPainter.height / 2.0));
    canvas.restore();
    canvas.restore();
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SeekBarThemeData seekBarTheme,
    TextDirection textDirection,
    double value,
  }) {
    final ColorTween enableColor = ColorTween(
      begin: seekBarTheme.disabledThumbColor,
      end: seekBarTheme.valueIndicatorColor,
    );
    _drawValueIndicator(
      parentBox,
      context.canvas,
      center,
      Paint()..color = enableColor.evaluate(enableAnimation),
      activationAnimation.value,
      labelPainter,
    );
  }
}
