Contributing to Unitary
=======================

Thanks for your interest in contributing!  Unitary is a personal project, but
bug reports, feature requests, and pull requests are all welcome.


Reporting Bugs and Requesting Features
--------------------------------------

Use [GitHub issues](https://github.com/wisnij/unitary/issues).  For bugs,
include:

- What you entered and what you expected to happen
- What actually happened (exact error message or wrong result)
- Platform (Android/web) and app version (shown in Settings → About)

For conversion-accuracy issues, the exact input expression is essential —
many unit names are case-sensitive or ambiguous.


Development Setup
-----------------

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(latest stable) and Git.

~~~~ bash
git clone https://github.com/wisnij/unitary.git
cd unitary
flutter pub get
flutter run
~~~~

Install the [pre-commit](https://pre-commit.com/) hooks, which keep generated
files (unit database, app icons) in sync and run formatting and lint checks:

~~~~ bash
pre-commit install
~~~~


Making Changes
--------------

1. Create a branch off `main`.
2. Write tests for the new behavior — including edge cases and failure modes
   — ideally before the implementation code.
3. Make your change.  Follow the existing code conventions; see
   [Development Best Practices](doc/best_practices.md) for structure,
   patterns, and style, and [Core Architecture](doc/architecture.md) for how
   the pieces fit together.
4. Update any related documentation (README, `doc/` files) affected by the
   change.
5. Verify everything passes before opening a PR:

   ~~~~ bash
   flutter test --reporter failures-only
   flutter analyze
   ~~~~

### Guidelines

- **One feature or fix per pull request** — keep PRs focused and reasonably
  sized
- **Tests are required** for new functionality; widget tests should use the
  shared harness in `test/helpers/` rather than hand-rolling provider
  overrides
- **Commit messages** use the
  [conventional commits](https://www.conventionalcommits.org/) format:
  `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, etc.
- **No new dependencies** without discussion first — the dependency list is
  deliberately lean
- **Don't edit generated files** (`lib/core/domain/data/predefined_units.dart`)
  by hand; change the sources under `assets/units/` and let the pre-commit
  hooks regenerate them

CI runs lint, the full test suite, and the Android integration tests on
every PR; all of it must pass before merging.


License
-------

Unitary is licensed under the
[GNU Affero General Public License v3](https://www.gnu.org/licenses/agpl-3.0)
(or later).  By contributing, you agree that your contributions will be
licensed under the same terms.
