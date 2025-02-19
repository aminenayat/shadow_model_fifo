from pathlib import Path
from vunit import VUnit

SRC_PATH = Path(__file__).parent / "src"
TEST_PATH = Path(__file__).parent / "test"

VU = VUnit.from_argv()
VU.add_verilog_builtins()

VU.add_library("cordic_lib").add_source_files(SRC_PATH / "*.v")
VU.add_library("tb_cordic").add_source_files(TEST_PATH / "*.sv")

VU.main()
