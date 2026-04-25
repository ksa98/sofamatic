# sofamatic 0.1.0 — first CRAN submission

## Test environments

* Local: macOS, R (release)
* GitHub Actions:
  * macOS-latest, R-release
  * windows-latest, R-release
  * ubuntu-latest, R-devel
  * ubuntu-latest, R-release
  * ubuntu-latest, R-oldrel-1

## R CMD check results

0 errors | 0 warnings | 3 notes

The three NOTEs are all expected:

1. **New submission.** This is the package's first CRAN release.
2. **Non-FOSS package license (file LICENSE).** The package is licensed
   under BSD-4-Clause, which CRAN flags as non-FSF-FOSS due to the
   advertising clause (clause 3). The license itself is permitted.
3. **HTML validation problems** (local check only). The macOS `tidy`
   used by `R CMD check` doesn't recognize the HTML5 `<main>` tag
   emitted by current R-help; this NOTE does not reproduce on CRAN's
   check machines.

## Other notes

* The package depends only on `stats` (base R).
* `example_sofa_data()` generates fully synthetic, parametric data for
  examples and tests; no real patient data is shipped.
* The DOI `<doi:10.1007/BF01709751>` in the Description references
  Vincent et al. (1996), the canonical SOFA publication.

## Reverse dependencies

This is a new package; there are no reverse dependencies.
