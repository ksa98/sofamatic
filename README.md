# rSOFA: An R Package for Calculating SOFA Scores 🩺⚕️

## Description

The `rSOFA` package provides a comprehensive set of tools for calculating the Sequential Organ Failure Assessment (SOFA) scores from clinical datasets. This package is designed to support both cross-sectional and longitudinal analyses, accommodating datasets with repeated measurements over time. The SOFA score, a critical measure for assessing organ dysfunction in critically ill patients, can be instrumental in clinical studies and healthcare analytics.

## Features

- **Cross-sectional analysis**: calculate SOFA scores for a single point in time, suitable for datasets without repeated measures or for analyzing a specific time point in longitudinal data.
- **Longitudinal analysis**: compute SOFA scores across multiple time points, allowing for the assessment of organ function over time in patients with repeated measurements.
- **Flexible data input**: compatible with a wide range of data formats, including long format data commonly used in longitudinal studies.

## Installation

To install the latest version of `rSOFA` from CRAN, run the following command in R:

```R
install.packages("rSOFA")
```

## Usage

### Cross-sectional Analysis

To calculate SOFA scores for a dataset in a cross-sectional analysis:

```R
library(rSOFA)
data <- read.csv("path/to/your/data.csv")
sofa_scores <- calculate_sofa(data, mode = "cross-sectional")
```

### Longitudinal Analysis

For longitudinal analysis with repeated measures:

```R
library(rSOFA)
data <- read.csv("path/to/your/longitudinal/data.csv")
sofa_scores <- calculate_sofa(data, mode = "longitudinal")
```

## Data Requirements

Your dataset should include the necessary clinical parameters for SOFA score calculation, such as:

- Partial pressure of oxygen (PaO2)/Fraction of inspired oxygen (FiO2)
- Platelet count
- Glasgow Coma Scale
- Bilirubin levels
- Mean arterial pressure or administration of vasopressors
- Serum creatinine or urine output

Please refer to the documentation for a detailed list of required parameters and acceptable data formats.

## Contributing

We welcome contributions to the `rSOFA` package, including feature requests, bug reports, and code contributions. Please refer to the CONTRIBUTING.md file for guidelines on how to contribute.

## License

`rSOFA` is licensed under the MIT License. See the LICENSE file for more details.

## Acknowledgments

This package was developed by researchers and clinicians with expertise in critical care medicine, biostatistics, and data science. We thank the critical care community for their invaluable insights and feedback.

---

For more information, please visit the `rSOFA` package documentation or contact the package maintainers.