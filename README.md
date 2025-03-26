
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pinsha

<!-- badges: start -->

<!-- badges: end -->

GitHub [recommends to pin third-party actions to a full-length commit
SHA](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)
to prevent supply-chain attacks. Paring this strategy with [automated
actions updates from
depandabot](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/keeping-your-actions-up-to-date-with-dependabot),
also helps protect you from security exploits in out-dated actions.

The goal of {pinsha} is to provide an easy way to pin the actions in
your github workflows.

## Installation

You can install the development version of pinsha like so:

``` r
pak::pak("zkamvar/pinsha")
```

## Examples

### Find SHA for any given action

This will take a github action string and replace the floating tag with
an SHA so that you can harden the security of your github actions.

``` r
library("pinsha")
pin_action("r-lib/actions/check-r-package@v2")
#> [1] "r-lib/actions/check-r-package@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"
pin_action("JamesIves/github-pages-deploy-action@v4.7.3")
#> [1] "JamesIves/github-pages-deploy-action@6c2d9db40f9296374acc17b90404b6e8864128c8 #v4.7.3"
pin_action("docker/login-action")
#> [1] "docker/login-action@74a5d142397b4f367a81961eba4e8cd7edddf772 #v3.4.0"
```

### Scan your files for actions used

You can find all of the third-party actions used with
`pin_find_actions()`

``` r
# Actions in standard workflows
workflows <- system.file("workflows", package = "pinsha")
pin_find_actions(workflows)
#> $`/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpXLywfp/temp_libpath16ea4e30ecc/pinsha/workflows/R-CMD-check.yaml`
#> [1] "r-lib/actions/setup-pandoc@v2"        
#> [2] "r-lib/actions/setup-r@v2"             
#> [3] "r-lib/actions/setup-r-dependencies@v2"
#> [4] "r-lib/actions/check-r-package@v2"     
#> 
#> $`/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpXLywfp/temp_libpath16ea4e30ecc/pinsha/workflows/pkdown.yaml`
#> [1] "r-lib/actions/setup-pandoc@v2"              
#> [2] "r-lib/actions/setup-r@v2"                   
#> [3] "r-lib/actions/setup-r-dependencies@v2"      
#> [4] "JamesIves/github-pages-deploy-action@v4.5.0"
#> 
#> $`/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpXLywfp/temp_libpath16ea4e30ecc/pinsha/workflows/test-coverage.yaml`
#> [1] "r-lib/actions/setup-r@v2"             
#> [2] "r-lib/actions/setup-r-dependencies@v2"
#> [3] "codecov/codecov-action@v5"
```

### Update actions

To update all of the actions in your workflows, you can use the `pin()`
command from the root of your repository. Here, I am demonstrating on a
temporary copy of the directory:

``` r
# pin() transforms all of the actions to use hashes
tmp <- tempfile()
fs::dir_copy(workflows, tmp)
pin(tmp, write = TRUE)
pin_find_actions(tmp)
#> $`/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpnO6iD5/file16f196a15ecc2/R-CMD-check.yaml`
#> [1] "r-lib/actions/setup-pandoc@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"        
#> [2] "r-lib/actions/setup-r@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"             
#> [3] "r-lib/actions/setup-r-dependencies@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"
#> [4] "r-lib/actions/check-r-package@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"     
#> 
#> $`/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpnO6iD5/file16f196a15ecc2/pkdown.yaml`
#> [1] "r-lib/actions/setup-pandoc@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"         
#> [2] "r-lib/actions/setup-r@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"              
#> [3] "r-lib/actions/setup-r-dependencies@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3" 
#> [4] "JamesIves/github-pages-deploy-action@65b5dfd4f5bcd3a7403bbc2959c144256167464e #v4.5.0"
#> 
#> $`/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpnO6iD5/file16f196a15ecc2/test-coverage.yaml`
#> [1] "r-lib/actions/setup-r@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"             
#> [2] "r-lib/actions/setup-r-dependencies@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"
#> [3] "codecov/codecov-action@0565863a31f2c772f9f0395002a31e3f06189574 #v5.4.0"
```
