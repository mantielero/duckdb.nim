# Package

version       = "0.0.1"
author        = "Jose Maria Garcia"
description   = "A DuckDB wrapper written in Nim."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task test, "Testing DuckDB":
  exec """testament pattern "tests/**/*.nim""""