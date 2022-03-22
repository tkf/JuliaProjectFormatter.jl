# JuliaProjectFormatter

JuliaProjectFormatter.jl formats Project.toml files in the way Pkg.jl formats Project.toml
files.

To discover Project.toml files under the current directory recursively and format them, run:

```julia
using JuliaProjectFormatter
format_projects()
```
