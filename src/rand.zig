const std = @import("std");

/// Generates a random enum value, excluding specified values
///
/// Parameters:
/// - rng: A random number generator
/// - comptime EnumType: The enum type to generate
/// - exclusions: enum set of enum values to exclude
///
/// Returns: A random enum value not in the exclusions list
pub fn randomEnumExcluding(random: std.Random, comptime E: type, exclusions: std.EnumSet(E)) E {
    const fields: []const std.builtin.Type.EnumField = @typeInfo(E).@"enum".fields;
    if (fields.len == 0) @compileError("There are no fields in the enum");
    var candidates_buf: [fields.len]E = undefined;
    var candidates_len: usize = 0;

    inline for (fields) |field| {
        const value = @field(E, field.name);
        if (!exclusions.contains(value)) {
            candidates_buf[candidates_len] = value;
            candidates_len += 1;
        }
    }

    return candidates_buf[random.intRangeLessThan(usize, 0, candidates_len)];
}
