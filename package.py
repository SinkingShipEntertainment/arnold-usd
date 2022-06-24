name = "arnold_usd"

authors = [
    "Autodesk (Solid Angle) Arnold-Usd"
]

# NOTE: version = <arnoldusd_version>.sse.<sse_version>
version = "7.0.0.1.sse.1.0.0"

description = \
    """
    Arnold USD
    """

with scope("config") as c:
    # Determine location to release: internal (int) vs external (ext)

    # NOTE: Modify this variable to reflect the current package situation
    release_as = "ext"

    # The `c` variable here is actually rezconfig.py
    # `release_packages_path` is a variable defined inside rezconfig.py

    import os
    if release_as == "int":
        c.release_packages_path = os.environ["SSE_REZ_REPO_RELEASE_INT"]
    elif release_as == "ext":
        c.release_packages_path = os.environ["SSE_REZ_REPO_RELEASE_EXT"]

    #c.build_thread_count = "physical_cores"

requires = [
    "arnold_sdk-7.0.0.1",
]

private_build_requires = [
    "Jinja2",
]

variants = [
    ["platform-linux", "arch-x86_64", "os-centos-7", "boost-1.70", "usd-21.08", "ptex"],
    ["platform-linux", "arch-x86_64", "os-centos-7", "boost-1.70", "usd-21.08", "!ptex"],
]

# Pass cmake arguments:
# rez-build -i -- -DBoost_NO_BOOST_CMAKE=On -DBoost_NO_SYSTEM_PATHS=True
# rez-release -- -DBoost_NO_BOOST_CMAKE=On -DBoost_NO_SYSTEM_PATHS=True

uuid = "repository.arnold-usd"

def pre_build_commands():
    command("source /opt/rh/devtoolset-6/enable")

def commands():

    # NOTE: REZ package versions can have ".sse." to separate the external
    # version from the internal modification version.
    split_versions = str(version).split(".sse.")
    external_version = split_versions[0]
    internal_version = None
    if len(split_versions) == 2:
        internal_version = split_versions[1]

    env.ARNOLD_USD_VERSION = external_version
    env.ARNOLD_USD_PACKAGE_VERSION = external_version
    if internal_version:
        env.ARNOLD_USD_PACKAGE_VERSION = internal_version

    env.ARNOLD_USD_ROOT.append("{root}")
    env.ARNOLD_USD_LOCATION.append("{root}")

    env.ARNOLD_PLUGIN_PATH.append("{root}/procedural")
    env.PYTHONPATH.append("{root}/lib/python")
    env.PXR_PLUGINPATH_NAME.append("{root}/plugin")
    env.PXR_PLUGINPATH_NAME.append("{root}/lib/usd")
    env.LD_LIBRARY_PATH.append("{root}/lib")
    env.PATH.append("{root}/bin")
