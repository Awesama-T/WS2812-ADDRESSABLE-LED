import pytest
import subprocess
import os

# Generate the list of tests to run
# Strip '.v' from end up testbench source files in tb/
VERILOG_TEST_BENCHES = [tb_src[:-2] for tb_src in os.listdir('tb')]


@pytest.mark.parametrize('testbench', VERILOG_TEST_BENCHES)
def test_run_testbench(testbench):
    ret = subprocess.run(
        ['vvp', testbench],
        stdout=subprocess.PIPE
    )

    # Make sure that the process returned successfully
    assert ret.returncode == 0

    # Parse the stdout to check for errors
    stdout_string = ret.stdout.decode('utf-8')
    if 'FAIL' in stdout_string:
        pytest.fail('Found keyword \'FAIL\' in STDOUT')
        print(stdout_string)
