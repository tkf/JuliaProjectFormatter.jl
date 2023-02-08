baremodule JuliaProjectFormatter

export format_projects

function format_projects end

module Internal

using ..JuliaProjectFormatter: JuliaProjectFormatter

using TOML

const _project_key_order = ["name", "uuid", "keywords", "license", "desc", "deps", "compat", "weakdeps", "extensions"]
project_key_order(key::String) =
    something(findfirst(x -> x == key, _project_key_order), length(_project_key_order) + 1)

print_project(io, dict) =
    TOML.print(io, dict, sorted = true, by = key -> (project_key_order(key), key))

discover_project_toml(path) = discover_project_toml!(String[], path)

function discover_project_toml!(projects, path)
    isfile(path) && return push!(projects, path)
    for name in readdir(path)
        name == ".git" && continue
        subpath = joinpath(path, name)
        if isdir(subpath)
            discover_project_toml!(projects, subpath)
        elseif name in ("Project.toml", "JuliaProject.toml")
            push!(projects, subpath)
        end
    end
    return projects
end

function JuliaProjectFormatter.format_projects(path = pwd())
    for project in discover_project_toml(path)
        @debug "Formatting `$project`"
        dict = TOML.parsefile(project)
        open(project; write = true) do io
            print_project(io, dict)
        end
    end
end

end  # module Internal

end  # baremodule JuliaProjectFormatter
