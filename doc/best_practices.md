Unitary - Development Best Practices
====================================

This document outlines coding standards, architecture patterns, and development workflows for Unitary.

---


Code Organization
-----------------

### Project Structure

See [Code Organization in architecture.md](architecture.md#code-organization)
for the current source tree.  The essentials:

- `lib/core/domain/` — pure Dart (no Flutter): models, parser, unit system
- `lib/features/<feature>/` — one directory per feature, subdivided into
  `data/`, `models/`, `presentation/`, `services/`, and `state/` as needed
- `lib/shared/` — app shell, responsive layout, and cross-feature widgets
  and utilities
- `test/` mirrors `lib/` directory-for-directory; `tool/` executables each
  pair with a testable `*_lib.dart`

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


Architecture Patterns
---------------------

### Layered Architecture

The app follows a layered architecture with clear separation of concerns:

1. **Presentation Layer**: UI widgets and screens
2. **State Management Layer**: Providers/Riverpod state
3. **Domain Layer**: Business logic, models, parsers
4. **Data Layer**: Repositories, data sources, persistence

**Key Principle**: Dependencies flow inward. Presentation depends on State, State depends on Domain, Domain depends on Data. No reverse dependencies.

### State Management

**Riverpod Patterns:**

- Use `Provider` for simple read-only dependencies (singletons, derived
  values)
- Use `NotifierProvider` for mutable state (Riverpod 3 `Notifier` classes)
- Use `FutureProvider` for async data loading
- Screen-level state notifiers are non-`autoDispose` so page state survives
  navigation
- Repository providers that require a constructed instance are declared as
  must-override (`throw UnimplementedError()`) and wired in `main.dart`; in
  tests they are supplied by the shared harness (see Testing Strategy)

**Example:**

~~~~ dart
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('Must be overridden with a constructed instance');
});

final settingsProvider = NotifierProvider<SettingsNotifier, UserSettings>(
  SettingsNotifier.new,
);
~~~~

### Repository Pattern

All persistence goes through small repository classes over
SharedPreferences (`SettingsRepository`, `WorksheetRepository`,
`FreeformHistoryRepository`, `CurrencyRateRepository`):

- Repositories abstract the storage mechanism from notifiers and UI
- Single source of truth for each persisted domain object
- Handle serialization and tolerate missing/malformed stored data by
  falling back to defaults

(`UnitRepository`, despite the name, is not a persistence repository — it is
the in-memory registry of units, prefixes, and functions in the core domain
layer.)

---


Testing Strategy
----------------

### Unit Tests

**Coverage Target**: >80% for core domain logic

**What to Test**:

- All parser and evaluator logic
- Dimension arithmetic
- Unit conversions
- Quantity operations
- Error cases and edge conditions

**Test Structure**:

~~~~ dart
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
~~~~

### Widget Tests

**What to Test**:

- Critical UI components
- User interaction flows
- State updates reflected in UI

**Example**:

~~~~ dart
testWidgets('freeform input should display result', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  await tester.enterText(find.byType(TextField), '5 m + 3 m');
  await tester.pump();

  expect(find.text('8 m'), findsOneWidget);
});
~~~~

**Widget-test harness**: use the shared helpers in `test/helpers/` —
`pumpApp(tester, child)` pumps a widget inside `ProviderScope` +
`MaterialApp` with default in-memory instances of all must-override
repository providers (`TestRepositories`), merging any caller-supplied
overrides deterministically.  Never hand-roll the override list in a new
test file.

### Integration Tests

The `integration_test/` suite runs against a real Android emulator (locally
via `tool/run_integration_tests.sh`, and unconditionally in CI):

- `boot_test.dart` — the real `main()` entry point, including pre-first-frame
  currency-rate rehydration
- `restart_test.dart` — persistence across a simulated restart, against the
  real `SharedPreferences` plugin
- `currency_refresh_test.dart` — manual refresh flow against a mocked HTTP
  client (never the real rates API)

### Test Organization

- Mirror source structure in `test/` directory
- Use `setUp` and `tearDown` for test fixtures
- Group related tests
- Use descriptive test names
- Run the full suite with `flutter test --reporter failures-only`, and
  `flutter analyze` as a final check

---


Error Handling
--------------

### Exception Types

All domain errors are subclasses of the shared `UnitaryException` base class
(`lib/core/domain/errors.dart`): `LexException`, `ParseException`,
`EvalException`, `DimensionException`, and `BoundsException`.  UI code
catches `on UnitaryException` and displays the message; unexpected errors
are allowed to propagate.

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

~~~~ dart
// Internal
throw LexException("Unexpected character: '$c'", line: 5, column: 12);

// User-facing
"Invalid input: unexpected character. Please check your expression."
~~~~

### Error Recovery

- The lexer/parser/evaluator fail fast on the first error with a precise
  message; there is no partial-result recovery
- UI handles errors gracefully without crashing (freeform shows the message
  in the result display; worksheets show per-cell errors)
- Provide clear feedback to user

---


Performance Guidelines
----------------------

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

Measure before optimizing: [performance.md](performance.md) documents the
checked-in benchmark tools (`tool/benchmark.dart`, `tool/memory_report.dart`),
on-device profiling procedures, current baselines, and the action thresholds
that decide whether an optimization is worth doing.

---


Version Control
---------------

### Git Workflow

**Branch Strategy**:

- `main`: Production-ready code
- Work happens on short-lived branches off `main` (named
  `<user>/<yyyymmdd>-<topic>`, e.g. `wisnij/20260802-integration-tests`),
  merged back when green

**Commit Messages**:

- Use conventional commits format
- Examples:
  - `feat: add trigonometric functions to parser`
  - `fix: correct dimension calculation for derived units`
  - `docs: update README with installation instructions`
  - `refactor: simplify lexer token generation`
  - `test: add unit tests for quantity arithmetic`

### Pull Request Guidelines

- One feature/fix per PR
- Include tests for new functionality
- Update documentation as needed
- Self-review before requesting review
- Keep PRs focused and reasonably sized

### Release Process

Use the release script to create new releases:

~~~~ bash
# Preview what a release would do (no changes made)
dart run tool/release.dart patch --dry-run

# Create a patch release (0.2.0 -> 0.2.1)
dart run tool/release.dart patch

# Create a minor release (0.2.0 -> 0.3.0)
dart run tool/release.dart minor

# Create a major release (0.2.0 -> 1.0.0)
dart run tool/release.dart major
~~~~

The script will:

1. Verify the working tree is clean
2. Read the current version from `pubspec.yaml`
3. Collect commits since the last tag
4. Generate a changelog entry grouped by category
5. Update `CHANGELOG.md` and `pubspec.yaml`
6. Prompt for confirmation
7. Commit and create an annotated tag

After the script completes, push with `git push && git push --tags`.

**Version numbering:**

- **Major** (X.0.0): Breaking changes or major milestones
- **Minor** (0.X.0): New features, phase completions
- **Patch** (0.0.X): Bug fixes, minor improvements

**Conventional commit prefixes and changelog mapping:**

| Prefix       | Changelog Section |
|--------------|-------------------|
| `feat:`      | Added             |
| `fix:`       | Fixed             |
| `refactor:`  | Changed           |
| `perf:`      | Changed           |
| `docs:`      | Documentation     |
| `test:`      | *(omitted)*       |
| `chore:`     | *(omitted)*       |
| `build:`     | *(omitted)*       |
| `ci:`        | *(omitted)*       |
| `style:`     | *(omitted)*       |

---


Documentation
-------------

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

~~~~ dart
// Good
// Use binary search since units are sorted by ID
final index = _binarySearch(units, targetId);

// Bad
// Increment i by 1
i++;
~~~~

### API Documentation

- Use `///` for public APIs
- Include examples where helpful
- Document parameters, return values, exceptions

**Example**:

~~~~ dart
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
~~~~

---


Dependency Management
---------------------

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


Continuous Improvement
----------------------

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
