import 'stroke_property.dart';

/// App-local pen settings. Strokes continue to use the existing StrokeProperty.
class PenPreset {
  final String name;
  final StrokeProperty property;

  const PenPreset(this.name, this.property);

  static const defaults = [
    PenPreset(
      'Ballpoint',
      StrokeProperty(
        colorValue: 0xFF1E1E1E,
        strokeWidth: 3,
        thinning: 0,
        smoothing: 0.5,
        streamline: 0.35,
      ),
    ),
    PenPreset(
      'Gel Pen',
      StrokeProperty(
        colorValue: 0xFF1E1E1E,
        strokeWidth: 4.5,
        thinning: 0.2,
        smoothing: 0.7,
        streamline: 0.55,
      ),
    ),
    PenPreset(
      'Fountain Pen',
      StrokeProperty(
        colorValue: 0xFF1E1E1E,
        strokeWidth: 5,
        thinning: 0.8,
        smoothing: 0.55,
        streamline: 0.4,
      ),
    ),
  ];

  void validate() {
    bool within(double value, double min, double max) =>
        value.isFinite && value >= min && value <= max;
    if (name.trim() != name ||
        name.isEmpty ||
        name.length > 40 ||
        property.isHighlighter ||
        property.colorValue < 0 ||
        property.colorValue > 0xFFFFFFFF ||
        !within(property.strokeWidth, 0.5, 24) ||
        !within(property.opacity, 0, 1) ||
        !within(property.thinning, -1, 1) ||
        !within(property.smoothing, 0, 1) ||
        !within(property.streamline, 0, 1)) {
      throw const FormatException('Invalid pen preset name or parameters.');
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'property': property.toJson(),
  };

  factory PenPreset.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>;
    if (property['color'] is! int) {
      throw const FormatException('Invalid pen preset color.');
    }
    // Require every setting rather than silently replacing missing values.
    for (final field in [
      'color',
      'strokeWidth',
      'opacity',
      'thinning',
      'smoothing',
      'streamline',
    ]) {
      if (property[field] is! num) {
        throw const FormatException('Incomplete pen preset.');
      }
    }
    final preset = PenPreset(
      json['name'] as String,
      StrokeProperty.fromJson(property),
    );
    preset.validate();
    return preset;
  }
}
