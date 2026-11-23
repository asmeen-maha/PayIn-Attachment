/// Tolerant converters for loosely typed API JSON.
String? asString(dynamic value) => value?.toString();

double asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
