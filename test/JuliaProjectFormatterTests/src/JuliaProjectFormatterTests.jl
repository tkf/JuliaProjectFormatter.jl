module JuliaProjectFormatterTests

using JuliaProjectFormatter
using Test

function withfiles(f, tree)
    mktempdir() do dir
        for (path, content) in tree
            fullpath = joinpath(dir, path)
            mkpath(dirname(fullpath))
            open(fullpath; write = true) do io
                write(io, content)
            end
        end
        f(dir)
    end
end

function test_ignore_git()
    bad = """
    c = 3
    b = 2
    a = 1
    """

    good = """
    a = 1
    b = 2
    c = 3
    """

    tree = [
        # path => content
        ".git/Project.toml" => bad,
        "Project.toml" => bad,
        "sub/Project.toml" => bad,
    ]
    withfiles(tree) do dir
        format_projects(dir)
        @test Text(read(joinpath(dir, ".git/Project.toml"), String)) == Text(bad)
        @test Text(read(joinpath(dir, "Project.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/Project.toml"), String)) == Text(good)
    end
end

function test_juliaproject()
    bad = """
    c = 3
    b = 2
    a = 1
    """

    good = """
    a = 1
    b = 2
    c = 3
    """

    tree = [
        # path => content
        "JuliaProject.toml" => bad,
        "sub/Project.toml" => bad,
    ]
    withfiles(tree) do dir
        format_projects(dir)
        @test Text(read(joinpath(dir, "JuliaProject.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/Project.toml"), String)) == Text(good)
    end
end

function test_subsubsub()
    bad = """
    c = 3
    b = 2
    a = 1
    """

    good = """
    a = 1
    b = 2
    c = 3
    """

    tree = [
        # path => content
        "Project.toml" => bad,
        "sub/Project.toml" => bad,
        "sub/sub/Project.toml" => bad,
        "sub/sub/sub/Project.toml" => bad,
    ]
    withfiles(tree) do dir
        format_projects(dir)
        @test Text(read(joinpath(dir, "Project.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/Project.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/sub/Project.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/sub/sub/Project.toml"), String)) == Text(good)
    end
end

function test_other_files()
    bad = """
    c = 3
    b = 2
    a = 1
    """

    good = """
    a = 1
    b = 2
    c = 3
    """

    tree = [
        # path => content
        "Project.toml" => bad,
        "sub/Project.toml" => bad,
        "other_file.txt" => "other file with invalid TOML",
        "sub/other_file.txt" => "other file with invalid TOML",
    ]
    withfiles(tree) do dir
        format_projects(dir)
        @test Text(read(joinpath(dir, "Project.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/Project.toml"), String)) == Text(good)
    end
end

function test_real_project()
    bad = """
    uuid = "139e0cf6-64b2-48ae-acd2-4285c0bb47c3"
    authors = ["Takafumi Arakaki <aka.tkf@gmail.com> and contributors"]
    version = "0.1.0-DEV"
    name = "JuliaProjectFormatter"

    [deps]
    TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
    [compat]
    julia = "1.6"
    """

    good = """
    name = "JuliaProjectFormatter"
    uuid = "139e0cf6-64b2-48ae-acd2-4285c0bb47c3"
    authors = ["Takafumi Arakaki <aka.tkf@gmail.com> and contributors"]
    version = "0.1.0-DEV"

    [deps]
    TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

    [compat]
    julia = "1.6"
    """

    tree = [
        # path => content
        "Project.toml" => bad,
        "sub/Project.toml" => bad,
        "other_file.txt" => "other file with invalid TOML",
        "sub/other_file.txt" => "other file with invalid TOML",
    ]
    withfiles(tree) do dir
        format_projects(dir)
        @test Text(read(joinpath(dir, "Project.toml"), String)) == Text(good)
        @test Text(read(joinpath(dir, "sub/Project.toml"), String)) == Text(good)
    end
end

end  # module JuliaProjectFormatterTests
