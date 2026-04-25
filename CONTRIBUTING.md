# Contributing to sofamatic

Thanks for your interest in improving sofamatic. Bug reports, feature requests,
and pull requests are all welcome.

## Reporting a bug

Please open an issue using the **Bug report** template and include a
self-contained [reprex](https://reprex.tidyverse.org/) plus the output of
`sessionInfo()`.

## Suggesting a feature

Open an issue using the **Feature request** template, describing the
clinical / analytic motivation as well as the proposed API.

## Submitting a pull request

1. Fork the repository and create a feature branch from `main`.
2. Make your changes. Keep functions vectorised and dependency-light
   (base R only, where reasonable).
3. **Document** every exported function with [roxygen2](https://roxygen2.r-lib.org/)
   and regenerate the man pages and `NAMESPACE`:

   ```r
   devtools::document()
   ```

4. **Test.** Add unit tests in `tests/testthat/` that cover boundary cases
   and any new behaviour. Run:

   ```r
   devtools::test()
   ```

5. **Check.** The package must pass with no errors and no warnings:

   ```r
   devtools::check()
   ```

6. **Update `NEWS.md`** for any user-facing change.
7. Submit the pull request against `main`. CI will run `R-CMD-check` on
   macOS, Windows, and Linux (release + devel + oldrel-1).

## Coding style

* Follow the [tidyverse style guide](https://style.tidyverse.org/) — two-space
  indents, snake_case function names.
* Keep arguments order-stable; prefer adding new arguments at the end with
  sensible defaults.
* Avoid heavy dependencies; the goal is for `sofamatic` to install cleanly on
  any R install.
