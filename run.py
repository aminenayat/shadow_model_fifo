from pathlib import Path
from vunit import VUnit

# تنظیم مسیرهای پروژه
BASE_PATH = Path(__file__).parent          # مسیر دایرکتوری اصلی پروژه
SRC_PATH = BASE_PATH / "./fifo_verilog/src"               # مسیر فایل‌های منبع (DUT)
TEST_PATH = BASE_PATH / "./fifo_verilog/test"             # مسیر فایل‌های تست (از جمله fifo_tb.sv)
DATA_PATH = BASE_PATH / "Data"             # مسیر فایل‌های داده (input_hex.txt و c_fifo_memory.txt)

VU = VUnit.from_argv()
VU.add_verilog_builtins()

# اضافه کردن کتابخانه طراحی FIFO
fifo_lib = VU.add_library("fifo_lib")
fifo_lib.add_source_files(SRC_PATH / "*.sv")

# اضافه کردن کتابخانه تست بنچ
tb_fifo_lib = VU.add_library("tb_fifo_lib")
tb = tb_fifo_lib.add_source_files(TEST_PATH / "fifo_tb.sv")

# بررسی وجود فایل‌های ورودی و فایل طلایی
if not (DATA_PATH / "input_hex.txt").exists():
    raise FileNotFoundError("فایل input_hex.txt در پوشه Data یافت نشد.")
if not (DATA_PATH / "c_fifo_memory.txt").exists():
    raise FileNotFoundError("فایل c_fifo_memory.txt در پوشه Data یافت نشد.")

print("فایل‌های input_hex.txt و c_fifo_memory.txt در پوشه Data موجود هستند.")

# تنظیم مسیر فایل‌های خروجی و طلایی برای مقایسه
# توجه داشته باشید که فایل خروجی شبیه‌سازی (verilog_fifo_memory.txt) در زمان شبیه‌سازی در پوشه کاری تولید می‌شود.
golden_file = str(DATA_PATH / "c_fifo_memory.txt")
output_file = "verilog_fifo_memory.txt"
tb.set_file_compare(output_file, golden_file)

VU.main()

