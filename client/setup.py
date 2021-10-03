from setuptools import setup
import os
import shutil

if not os.path.exists("bin"):
    os.makedirs("bin")
shutil.copyfile("bpow_client.py", "bin/bpow-client")

setup(
    name="bpow-client",
    scripts=["bin/bpow-client"],
    packages=["bpowlib"],
    install_requires=["aiohttp", "amqtt", "requests"],
)
