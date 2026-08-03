.DEFAULT_GOAL := help
SUBMAKE := $(MAKE) --no-print-directory

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
FLUTTER := flutter.bat
DART := dart.bat
BLANK_LINE := @echo.
GRADLEW := gradlew.bat
else
SHELL := /bin/bash
FLUTTER := flutter
DART := dart
BLANK_LINE := @echo
GRADLEW := ./gradlew
endif

PROJECT_NAME := native_natural_sort
EXAMPLE_DIR := example

ANDROID_DIR := $(EXAMPLE_DIR)/android
ANDROID_TEST_TASK := :$(PROJECT_NAME):testDebugUnitTest
ANDROID_INTEGRATION_TASK := :$(PROJECT_NAME):connectedAndroidTest

.PHONY: help format fix analyze test \
        test-android test-ios test-macos test-windows test-linux \
        gen

help:
	@echo "native_natural_sort — automation entrypoints"
	$(BLANK_LINE)
	@echo "  help            Show this help"
	@echo "  format          Format Dart sources under lib/ and test/"
	@echo "  fix             Apply Dart fixes then format"
	@echo "  analyze         Run Dart static analysis"
	@echo "  gen             Regenerate Pigeon platform-channel code"
	@echo "  test            Dart tests + Kotlin unit tests (no device needed)"
	$(BLANK_LINE)
	@echo "Platform-specific tests (require SDK / device):"
	@echo "  test-android    Kotlin + Android integration tests"
	@echo "  test-ios        iOS XCTest via example app"
	@echo "  test-macos      macOS XCTest via example app"
	@echo "  test-windows    C++ Google Test (build example first)"
	@echo "  test-linux      C++ Google Test (build example first)"

format:
	@$(DART) format lib test

fix:
	@$(DART) fix --apply
	@$(SUBMAKE) format

analyze:
	@$(DART) analyze lib test

gen:
	@$(DART) run pigeon --input pigeons/collation.dart

# Default test suite: Dart + Kotlin unit tests (runs on any dev machine
# with the Android SDK installed; no Android device/emulator needed).
test:
	@echo "=== Dart tests ==="
	@$(FLUTTER) test
	@$(BLANK_LINE)
	@echo "=== Kotlin unit tests (JVM, no device) ==="
	@cd $(ANDROID_DIR) && $(GRADLEW) $(ANDROID_TEST_TASK) --console=plain

# Kotlin unit tests + Android integration tests + Flutter integration tests.
test-android:
	@echo "=== Kotlin unit tests ==="
	@cd $(ANDROID_DIR) && $(GRADLEW) $(ANDROID_TEST_TASK) --console=plain
	@$(BLANK_LINE)
	@echo "=== Android integration tests ==="
	@cd $(ANDROID_DIR) && $(GRADLEW) $(ANDROID_INTEGRATION_TASK) --console=plain
	@$(BLANK_LINE)
	@echo "=== Flutter integration tests (Android) ==="
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test integration_test -d android

# iOS XCTest via the example app (requires Xcode + simulator).
test-ios:
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test integration_test -d ios

# macOS XCTest via the example app.
test-macos:
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test integration_test -d macos

# Windows C++ Google Test — build the example first so CMake configures
# the test target, then run the test binary directly.
test-windows:
	@echo "=== Windows C++ tests ==="
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build windows --debug
	@cd $(EXAMPLE_DIR)/build/windows/x64/debug/plugins/$(PROJECT_NAME) \
		&& $(PROJECT_NAME)_test.exe

# Linux C++ Google Test — build the example first, then run ctest.
test-linux:
	@echo "=== Linux C++ tests ==="
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build linux --debug
	@cd $(EXAMPLE_DIR)/build/linux/x64/debug/plugins/$(PROJECT_NAME) \
		&& ctest --output-on-failure
