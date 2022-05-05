from os import path
from glob import glob
from setuptools import setup, find_packages

package_name = "lh_tracker"

setup(
    name=package_name,
    version="0.0.0",
    packages=find_packages(),
    data_files=[
        (path.join("share", package_name), ["package.xml"]),
        (path.join("share", package_name, "launch"), glob("launch/*")),
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="Philéas LAMBERT",
    maintainer_email="phileas.lambert@ecam.com",
    description="Valve lighthouse 2.0 localisation tracker node",
    license="ECAM Makers :: CDFR 2022",
    entry_points={
        "console_scripts": [
            "lh_tracker_serial = lh_tracker_serial.lh_tracker_serial_node:main",
            "lh_tracker_geometry = lh_tracker_geometry.lh_tracker_geometry_node:main",
        ],
    },
)
