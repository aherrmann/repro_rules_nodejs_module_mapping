load(
    "@build_bazel_rules_nodejs//:providers.bzl",
    "LinkablePackageInfo",
)
load("@npm//typescript:index.bzl", "tsc")

def _paths_join(*paths):
    return "/".join([p for p in paths if p])

def _my_ts_library_impl(ctx):
    tsc = ctx.attr.tsc
    return [
        tsc[DefaultInfo],
        LinkablePackageInfo(
            package_name = ctx.attr.module_name,
            path = _paths_join(
                ctx.bin_dir.path,
                ctx.label.workspace_root,
                ctx.label.package,
            ),
        ),
    ]

_my_ts_library = rule(
    _my_ts_library_impl,
    attrs = {
        "tsc": attr.label(),
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
    outs = [
        s.replace(".ts", ext)
        for ext in [".js", ".d.ts"]
        for s in srcs
    ]
    tsc(
        name = name + "-tsc",
        data = [tsconfig] + srcs + deps,
        outs = outs,
        args = [
            "--outDir",
            "$(RULEDIR)",
            "--project",
            "$(location %s)" % tsconfig,
            "--declaration",
        ],
        **kwargs
    )
    _my_ts_library(
        name = name,
        tsc = name + "-tsc",
        module_name = module_name,
        module_root = module_root,
        deps = deps,
        **kwargs
    )
