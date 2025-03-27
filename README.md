
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

## Usage

If you have a github repository with workflows that you would like to
pin actions for, then you can open that repository locally in R and use
`pinsha::pin(write = TRUE)`. See blow for examples.

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

#### Memoization

Note that the `pin_action()` function and the `gh()` functions are
memoized, so you aren’t charged for duplicate calls to the same
repository:

``` r
gh::gh_rate_limit()$remaining
#> [1] 4964
# memoized pin_action: no new API calls
pin_action("r-lib/actions/check-r-package@v2")
#> [1] "r-lib/actions/check-r-package@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"
gh::gh_rate_limit()$remaining
#> [1] 4964
# memoized gh calls: no new API calls for different action in same repo
pin_action("r-lib/actions/setup-r@v2")
#> [1] "r-lib/actions/setup-r@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"
gh::gh_rate_limit()$remaining
#> [1] 4964
# pin action with new repo: two API calls
pin_action("codecov/codecov-action@v5")
#> [1] "codecov/codecov-action@0565863a31f2c772f9f0395002a31e3f06189574 #v5.4.0"
gh::gh_rate_limit()$remaining
#> [1] 4962
```

### Scan your files for actions used

You can find all of the third-party actions used with
`pin_find_actions()`

``` r
# Actions in standard workflows
workflows <- system.file("workflows", package = "pinsha")
pin_find_actions(workflows)
#> $`/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/Rtmpb1uSUi/temp_libpath7ef4659f09cd/pinsha/workflows/R-CMD-check.yaml`
#> [1] "r-lib/actions/setup-pandoc@v2"        
#> [2] "r-lib/actions/setup-r@v2"             
#> [3] "r-lib/actions/setup-r-dependencies@v2"
#> [4] "r-lib/actions/check-r-package@v2"     
#> 
#> $`/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/Rtmpb1uSUi/temp_libpath7ef4659f09cd/pinsha/workflows/pkgdown.yaml`
#> [1] "r-lib/actions/setup-pandoc@v2"              
#> [2] "r-lib/actions/setup-r@v2"                   
#> [3] "r-lib/actions/setup-r-dependencies@v2"      
#> [4] "JamesIves/github-pages-deploy-action@v4.5.0"
#> 
#> $`/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/Rtmpb1uSUi/temp_libpath7ef4659f09cd/pinsha/workflows/test-coverage.yaml`
#> [1] "r-lib/actions/setup-r@v2"             
#> [2] "r-lib/actions/setup-r-dependencies@v2"
#> [3] "codecov/codecov-action@v5"
```

### Update actions

To update all of the actions in your workflows, you can use the `pin()`
command from the root of your repository.

``` r
# setup
tmp <- withr::local_tempdir()
usethis::create_package(tmp, open = TRUE)
#> ✔ Setting active project to
#>   "/private/var/folders/9p/m996p3_55hjf1hc62552cqfr0000gr/T/RtmpvD7kAq/file7f734d1e02c2".
#> ✔ Creating 'R/'.
#> ✔ Writing 'DESCRIPTION'.
#> Package: file7f734d1e02c2
#> Title: What the Package Does (One Line, Title Case)
#> Version: 0.0.0.9000
#> Authors@R (parsed):
#>     * First Last <first.last@example.com> [aut, cre]
#> Description: What the package does (one paragraph).
#> License: `use_mit_license()`, `use_gpl3_license()` or friends to pick a
#>     license
#> Encoding: UTF-8
#> Roxygen: list(markdown = TRUE)
#> RoxygenNote: 7.3.2
#> ✔ Writing 'NAMESPACE'.
usethis::use_git()
#> ✔ Initialising Git repo.
#> ✔ Adding ".Rproj.user", ".Rhistory", ".Rdata", ".httr-oauth", ".DS_Store", and
#>   ".quarto" to '.gitignore'.
usethis::use_github_action("pkgdown")
#> ✔ Creating '.github/'.
#> ✔ Adding "^\\.github$" to '.Rbuildignore'.
#> ✔ Adding "*.html" to '.github/.gitignore'.
#> ✔ Creating '.github/workflows/'.
#> ✔ Saving "r-lib/actions/examples/pkgdown.yaml@v2" to
#>   '.github/workflows/pkgdown.yaml'.
#> ☐ Learn more at <https://github.com/r-lib/actions/blob/v2/examples/README.md>.
usethis::use_github_action("lint")
#> ✔ Saving "r-lib/actions/examples/lint.yaml@v2" to
#>   '.github/workflows/lint.yaml'.
#> ☐ Learn more at <https://github.com/r-lib/actions/blob/v2/examples/README.md>.

# all the actions are unpinned
pin_find_actions(".github/workflows")
#> $`.github/workflows/lint.yaml`
#> [1] "r-lib/actions/setup-r@v2"             
#> [2] "r-lib/actions/setup-r-dependencies@v2"
#> 
#> $`.github/workflows/pkgdown.yaml`
#> [1] "r-lib/actions/setup-pandoc@v2"              
#> [2] "r-lib/actions/setup-r@v2"                   
#> [3] "r-lib/actions/setup-r-dependencies@v2"      
#> [4] "JamesIves/github-pages-deploy-action@v4.5.0"

# pin() transforms all of the actions to use hashes
pin(write = TRUE)
#> ℹ Found 2 workflows: 'lint.yaml' and 'pkgdown.yaml'
#> ℹ Modifying actions in ".github/workflows/lint.yaml"
#> ✔ Modifying actions in ".github/workflows/lint.yaml" ... done
#> 
#> ℹ Modifying actions in ".github/workflows/pkgdown.yaml"
#> ✔ Modifying actions in ".github/workflows/pkgdown.yaml" ... done
#> 

# now they are all pinned
pin_find_actions(".github/workflows")
#> $`.github/workflows/lint.yaml`
#> [1] "r-lib/actions/setup-r@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"             
#> [2] "r-lib/actions/setup-r-dependencies@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"
#> 
#> $`.github/workflows/pkgdown.yaml`
#> [1] "r-lib/actions/setup-pandoc@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"         
#> [2] "r-lib/actions/setup-r@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3"              
#> [3] "r-lib/actions/setup-r-dependencies@bd49c52ffe281809afa6f0fecbf37483c5dd0b93 #v2.11.3" 
#> [4] "JamesIves/github-pages-deploy-action@65b5dfd4f5bcd3a7403bbc2959c144256167464e #v4.5.0"
```
