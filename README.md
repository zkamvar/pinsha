
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pinsha

<!-- badges: start -->

<!-- badges: end -->

The goal of pinsha is to provide an easy way to pin the actions in your
github workflows.

## Installation

You can install the development version of pinsha like so:

``` r
pak::pak("zkamvar/pinsha")
```

## Example

This will take a github action string and replace the floating tag with
an SHA so that you can harden the security of your github actions.

``` r
library("pinsha")
pin_action("r-lib/actions/check-r-package@v2")
#> [1] "r-lib/actions/check-r-package@14a7e741c1cb130261263aa1593718ba42cf443b #v2.11.2"
pin_action("JamesIves/github-pages-deploy-action@v4.7.3")
#> [1] "JamesIves/github-pages-deploy-action@6c2d9db40f9296374acc17b90404b6e8864128c8 #v4.7.3"
```

To update all of the actions in your workflows, you can use the `pin()`
command from the root of your repository.

``` r
pinsha::pin()
```
