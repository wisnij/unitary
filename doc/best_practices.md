# Unitary - Development Best Practices

This document outlines coding standards, architecture patterns, and development workflows for Unitary.

---


## Code Organization

### Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── domain/
│   │   ├── models/
│   │   │   ├── dimension.dart
│   │   │   ├── unit.dart
│   │   │   ├── quantity.dart
│   │   │   ├── prefix.dart
│   │   │   └── worksheet.dart
│   │   ├── parser/
│   │   │   ├── lexer.dart
│   │   │   ├── parser.dart
│   │   │   ├── ast.dart
│   │   │   └── evaluator.dart
│   │   └── services/
│   │       ├── currency_service.dart
│   │       └── unit_service.dart
│   └── data/
│       ├── repositories/
│       │   ├── unit_repository.dart
│       │   ├── worksheet_repository.dart
│       │   └── preferences_repository.dart
│       ├── data_sources/
│       │   ├── local_database.dart
│       │   └── currency_api.dart
│       └── models/
│           └── database_models.dart
├── features/
│   ├── freeform/
│   │   ├── presentation/
│   │   │   ├── freeform_screen.dart
│   │   │   └── widgets/
│   │   └── state/
│   │       └── freeform_provider.dart
│   ├── worksheet/
│   │   ├── presentation/
│   │   │   ├── worksheet_screen.dart
│   │   │   └── widgets/
│   │   └── state/
│   │       └── worksheet_provider.dart
│   └── settings/
│       ├── presentation/
│       │   └── settings_screen.dart
│       └── state/
│           └── settings_provider.dart
├── shared/
│   ├── widgets/
│   │   ├── unit_picker.dart
│   │   └── quantity_display.dart
│   ├── themes/
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   └── utils/
│       ├── constants.dart
│       └── extensions.dart
└── assets/
    ├── units/
    │   └── units_database.json
    └── currency/
        └── default_rates.json
```

### File Naming Conventions

- Use snake_case for file names: `unit_repository.dart`, `freeform_screen.dart`
- One class per file (with exceptions for small related classes)
- Test files mirror source files: `unit_repository_test.dart`

### Code Style

- Follow official Dart style guide
- Use `dartfmt` or IDE auto-formatting
- Line length limit: 80-100 characters
- Use `const` constructors where possible
- Prefer `final` over `var` where applicable

---


## Architecture Patterns

### Layered Architecture

The app follows a layered architecture with clear separation of concerns:

1. **Presentation Layer**: UI widgets and screens
2. **State Management Layer**: Providers/Riverpod state
3. **Domain Layer**: Business logic, models, parsers
4. **Data Layer**: Repositories, data sources, persistence

**Key Principle**: Dependencies flow inward. Presentation depends on State, State depends on Domain, Domain depends on Data. No reverse dependencies.

### State Management

**Provider/Riverpod Patterns:**

- Use `Provider` for simple read-only dependencies
- Use `StateNotifierProvider` for mutable state
- Use `FutureProvider` for async data loading
- Use `StreamProvider` for reactive data streams

**Example:**

```dart
final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  return UnitRepository();
});

final freeformInputProvider = StateNotifierProvider<FreeformInputNotifier, FreeformState>((ref) {
  return FreeformInputNotifier(ref.read(unitRepositoryProvider));
});
```

### Repository Pattern

All data access goes through repositories:

- Repositories abstract data sources
- Single source of truth for each domain object
- Handle caching and data transformation

**Example:**

```dart
class UnitRepository {
  Future<Unit?> getUnit(String id);
  Future<List<Unit>> getUnitsInDimension(Dimension dimension);
  Future<void> saveCustomUnit(Unit unit);
}
```

---


## Testing Strategy

### Unit Tests

**Coverage Target**: >80% for core domain logic

**What to Test**:

- All parser and evaluator logic
- Dimension arithmetic
- Unit conversions
- Quantity operations
- Error cases and edge conditions

**Test Structure**:

```dart
group('Lexer', () {
  test('should tokenize simple number', () {
    // Arrange
    final lexer = Lexer('5');

    // Act
    final tokens = lexer.scanTokens();

    // Assert
    expect(tokens.length, 2); // number + EOF
    expect(tokens[0].type, TokenType.number);
    expect(tokens[0].literal, 5.0);
  });
});
```

### Widget Tests

**What to Test**:

- Critical UI components
- User interaction flows
- State updates reflected in UI

**Example**:

```dart
testWidgets('freeform input should display result', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  await tester.enterText(find.byType(TextField), '5 m + 3 m');
  await tester.pump();

  expect(find.text('8 m'), findsOneWidget);
});
```

### Integration Tests

**Key Flows to Test**:

- Complete conversion workflow
- Worksheet multi-field updates
- Currency rate updates
- Settings persistence

### Test Organization

- Mirror source structure in `test/` directory
- Use `setUp` and `tearDown` for test fixtures
- Group related tests
- Use descriptive test names

---


## Error Handling

### Exception Types

Define custom exception classes for different error categories:

```dart
class LexException extends Exception { }
class ParseException extends Exception { }
class DimensionException extends Exception { }
class EvalException extends Exception { }
```

### Error Reporting

**Internal Errors** (for debugging):

- Include line/column numbers
- Stack traces
- Full context

**User-Facing Errors**:

- Simple, clear messages
- No technical jargon
- Actionable suggestions

**Example**:

```dart
// Internal
throw LexException("Unexpected character: '$c'", line: 5, column: 12);

// User-facing
"Invalid input: unexpected character. Please check your expression."
```

### Error Recovery

- Parser should recover from errors when possible
- UI should handle errors gracefully without crashing
- Provide clear feedback to user

---


## Performance Guidelines

### Parser Optimization

- Use string builders for token assembly
- Avoid unnecessary string allocations
- Cache frequently used units/constants
- Profile hot paths

### UI Performance

- Keep build methods pure and fast
- Use `const` constructors
- Avoid rebuilding entire widget tree
- Debounce expensive operations

### Memory Management

- Dispose of controllers and subscriptions
- Avoid memory leaks in providers
- Profile memory usage periodically

---


## Version Control

### Git Workflow

**Branch Strategy**:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/feature-name`: Individual features
- `bugfix/issue-number`: Bug fixes

**Commit Messages**:

- Use conventional commits format
- Examples:
  - `feat: add trigonometric functions to parser`
  - `fix: correct dimension calculation for compound units`
  - `docs: update README with installation instructions`
  - `refactor: simplify lexer token generation`
  - `test: add unit tests for quantity arithmetic`

### Pull Request Guidelines

- One feature/fix per PR
- Include tests for new functionality
- Update documentation as needed
- Self-review before requesting review
- Keep PRs focused and reasonably sized

---


## Documentation

### Code Comments

**When to Comment**:

- Complex algorithms
- Non-obvious design decisions
- Workarounds for limitations
- Public APIs

**When NOT to Comment**:

- Obvious code ("increment counter")
- What code does (code should be self-documenting)

**Example**:

```dart
// Good
// Use binary search since units are sorted by ID
final index = _binarySearch(units, targetId);

// Bad
// Increment i by 1
i++;
```

### API Documentation

- Use `///` for public APIs
- Include examples where helpful
- Document parameters, return values, exceptions

**Example**:

```dart
/// Converts a quantity to the specified target unit.
///
/// The quantity and target unit must be conformable (same dimension).
/// Throws [DimensionException] if units are not conformable.
///
/// Example:
/// ```dart
/// final meters = Quantity(5, lengthDimension);
/// final feet = meters.convertTo(feetUnit); // ~16.4 feet
/// ```
Quantity convertTo(Unit targetUnit);
```

---


## Dependency Management

### Adding Dependencies

- Prefer official/well-maintained packages
- Check package popularity and maintenance status
- Evaluate bundle size impact
- Lock versions in `pubspec.yaml`

### Minimizing Dependencies

- Use standard library when possible
- Don't add dependencies for trivial functionality
- Consider implementing simple features ourselves

---


## Continuous Improvement

### Code Reviews

- Review all code before merging
- Provide constructive feedback
- Focus on correctness, clarity, performance
- Praise good solutions

### Refactoring

- Refactor continuously, not in big batches
- Improve test coverage before refactoring
- Keep refactoring PRs separate from feature PRs

### Learning

- Document lessons learned
- Share knowledge through comments/docs
- Stay updated on Flutter/Dart best practices

---

*These practices should evolve as the project matures and we discover what works best.*
