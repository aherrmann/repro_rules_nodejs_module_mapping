load(
    "@build_bazel_rules_nodejs//:providers.bzl",
    "DeclarationInfo",
    "LinkablePackageInfo",
)
load("@npm_bazel_typescript//:index.bzl", "ts_project")

def _paths_join(*paths):
    return [p for p in paths if p]

def _my_ts_library_impl(ctx):
    project = ctx.attr.ts_project
    path = _paths_join(
        ctx.bin_dir.path,
        ctx.label.workspace_root,
        ctx.label.package,
    )
    return [
        project[DefaultInfo],
        project[DeclarationInfo],
        LinkablePackageInfo(
            package_name = ctx.attr.module_name,
            path = path,
        ),
    ]

_my_ts_library = rule(
    _my_ts_library_impl,
    attrs = {
        "ts_project": attr.label(),
        "module_name": attr.string(),
        "module_root": attr.string(),
        "deps": attr.label_list(),
    },
)

def my_ts_library(
        name,
        module_name = "",
        module_root = "",
        tsconfig = "tsconfig.json",
        srcs = [],
        deps = [],
        **kwargs):
    ts_project(
        name = name + "-project",
        tsconfig = tsconfig,
        srcs = srcs,
        deps = deps,
        **kwargs
    )
    _my_ts_library(
        name = name,
        ts_project = name + "-project",
        module_name = module_name,
        module_root = module_root,
        deps = deps,
        **kwargs
    )
