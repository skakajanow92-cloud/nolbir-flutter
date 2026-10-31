cmake_minimum_required(VERSION 3.18)
project(litedb LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Sanitizer (hata ayiklama): cmake -DLITEDB_SANITIZE=thread|address|undefined
set(LITEDB_SANITIZE "" CACHE STRING "thread | address | undefined (bos = kapali)")
if(LITEDB_SANITIZE)
  add_compile_options(-fsanitize=${LITEDB_SANITIZE} -fno-omit-frame-pointer -g)
  add_link_options(-fsanitize=${LITEDB_SANITIZE})
endif()

# SQLite: eger third_party/sqlite/sqlite3.c (amalgamation) varsa onu derle,
# yoksa sistemdeki SQLite'i kullan.
if(EXISTS ${CMAKE_SOURCE_DIR}/third_party/sqlite/sqlite3.c)
  add_library(sqlite3_local STATIC third_party/sqlite/sqlite3.c)
  target_include_directories(sqlite3_local PUBLIC third_party/sqlite)
  target_compile_definitions(sqlite3_local PRIVATE SQLITE_THREADSAFE=1)
  set(SQLITE_TARGET sqlite3_local)
else()
  find_package(SQLite3 REQUIRED)
  set(SQLITE_TARGET SQLite::SQLite3)
endif()

# ---------------------------------------------------------------- cekirdek
add_library(litedb
  src/core/Database.cpp
  src/core/Statement.cpp
  src/doc/DocumentStore.cpp
  src/graph/GraphStore.cpp
  src/ts/TimeSeriesStore.cpp
  src/cache/CacheStore.cpp)
target_include_directories(litedb PUBLIC src)
find_package(Threads REQUIRED)
target_link_libraries(litedb PUBLIC ${SQLITE_TARGET} Threads::Threads)
target_compile_options(litedb PRIVATE -Wall -Wextra)

# ---------------------------------------------------------------- web arayuzu
# ui/index.html derleme zamaninda bir C++ dizgesine gomulur (tek ikili dosya).
file(READ ${CMAKE_SOURCE_DIR}/ui/index.html LITEDB_UI_HTML)
file(CONFIGURE OUTPUT ${CMAKE_BINARY_DIR}/generated/ui_html.hpp
  CONTENT "#pragma once\nstatic const char* const kUiHtml = R\"LITEDB_UI(@LITEDB_UI_HTML@)LITEDB_UI\";\n"
  @ONLY)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${CMAKE_SOURCE_DIR}/ui/index.html)

# ---------------------------------------------------------------- sunucu
add_library(litedb_server
  src/server/HttpServer.cpp
  src/server/Api.cpp)
target_include_directories(litedb_server PUBLIC src ${CMAKE_BINARY_DIR}/generated)
target_link_libraries(litedb_server PUBLIC litedb)
target_compile_options(litedb_server PRIVATE -Wall -Wextra)

add_executable(litedbd src/server/main_server.cpp)
target_link_libraries(litedbd PRIVATE litedb_server)
target_compile_options(litedbd PRIVATE -Wall -Wextra)

# ---------------------------------------------------------------- CLI (bagimlilik yok)
add_executable(litedb-cli src/cli/main_cli.cpp)
target_include_directories(litedb-cli PRIVATE src)
target_compile_options(litedb-cli PRIVATE -Wall -Wextra)

# ---------------------------------------------------------------- ornekler
foreach(demo doc graph ts cache engine)
  add_executable(${demo}_demo examples/${demo}_demo.cpp)
  target_link_libraries(${demo}_demo PRIVATE litedb)
endforeach()

# ---------------------------------------------------------------- testler
add_executable(safe_engine_test tests/safe_engine_test.cpp)
target_link_libraries(safe_engine_test PRIVATE litedb_server)
add_executable(bench_writes tests/bench_writes.cpp)
target_link_libraries(bench_writes PRIVATE litedb_server)

enable_testing()
add_test(NAME safe_engine COMMAND safe_engine_test)
add_test(NAME e2e COMMAND ${CMAKE_SOURCE_DIR}/tests/e2e.sh $<TARGET_FILE:litedbd> $<TARGET_FILE:litedb-cli>)
