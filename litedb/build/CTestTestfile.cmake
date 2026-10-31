# CMake generated Testfile for 
# Source directory: C:/Users/User/Desktop/litedb
# Build directory: C:/Users/User/Desktop/litedb/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(safe_engine "C:/Users/User/Desktop/litedb/build/safe_engine_test.exe")
set_tests_properties(safe_engine PROPERTIES  _CMAKE_TEST_BUILD_DEPENDS "C:/Users/User/Desktop/litedb/build/safe_engine_test.exe" _BACKTRACE_TRIPLES "C:/Users/User/Desktop/litedb/CMakeLists.txt;81;add_test;C:/Users/User/Desktop/litedb/CMakeLists.txt;0;")
add_test(e2e "C:/Users/User/Desktop/litedb/tests/e2e.sh" "C:/Users/User/Desktop/litedb/build/litedbd.exe" "C:/Users/User/Desktop/litedb/build/litedb-cli.exe")
set_tests_properties(e2e PROPERTIES  _CMAKE_TEST_BUILD_DEPENDS "C:/Users/User/Desktop/litedb/build/litedb-cli.exe;C:/Users/User/Desktop/litedb/build/litedbd.exe" _BACKTRACE_TRIPLES "C:/Users/User/Desktop/litedb/CMakeLists.txt;82;add_test;C:/Users/User/Desktop/litedb/CMakeLists.txt;0;")
