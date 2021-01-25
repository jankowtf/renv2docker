# Template: build.R -------------------------------------------------------

test_that("Template: build.R", {
    actual <- use_template_build(
        dir = if (rlang::is_interactive()) {
            test_path("test_fixtures")
        } else {
            "test_fixtures"
        },
        open = FALSE
    )
    expected <- if (rlang::is_interactive()) {
        structure("tests/testthat/test_fixtures/build.R",
            class = c("fs_path", "character"))
    } else {
        structure("test_fixtures/build.R",
            class = c("fs_path", "character"))
    }
    expect_identical(actual, expected)
})

# Template: Dockerfile ----------------------------------------------------

test_that("Template: Dockerfile", {
    actual <- use_template_dockerfile(
        dir = if (rlang::is_interactive()) {
            test_path("test_fixtures")
        } else {
            "test_fixtures"
        },
        open = FALSE
    )
    expected <- if (rlang::is_interactive()) {
        structure("tests/testthat/test_fixtures/Dockerfile",
            class = c("fs_path", "character"))
    } else {
        structure("test_fixtures/Dockerfile",
            class = c("fs_path", "character"))
    }
    expect_identical(actual, expected)
})

test_that("Template: Dockerfile: dep manager", {
    actual <- use_template_dockerfile_dep_manager(
        dir = if (rlang::is_interactive()) {
            test_path("test_fixtures")
        } else {
            "test_fixtures"
        },
        open = FALSE
    )
    expected <- if (rlang::is_interactive()) {
        structure("tests/testthat/test_fixtures/renv/Dockerfile",
            class = c("fs_path", "character"))
    } else {
        structure("test_fixtures/renv/Dockerfile",
            class = c("fs_path", "character"))
    }
    expect_identical(actual, expected)
})
