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
        strokeWidth: 2.8,
        thinning: 0,
        smoothing: 0.35,
        streamline: 0.20,
      ),
    ),
    PenPreset(
      'Gel Pen',
      StrokeProperty(
        colorValue: 0xFF1E1E1E,
        strokeWidth: 3.8,
        thinning: 0.15,
        smoothing: 0.50,
        streamline: 0.35,
      ),
    ),
    PenPreset(
      'Fountain Pen',
      StrokeProperty(
        colorValue: 0xFF1E1E1E,
        strokeWidth: 4.8,
        thinning: 0.60,
        smoothing: 0.45,
        streamline: 0.30,
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
