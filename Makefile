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

# Test mode flags
#   make test          → human-readable (default)
#   make test CI=1     → CI-friendly (GitHub reporter / plain console)
CI ?= 0

ifeq ($(CI),1)
FLUTTER_TFLAGS = --reporter=github
KOTLIN_TFLAGS = --console=plain
NATIVE_TFLAGS = $(if $(filter Windows_NT,$(OS)),--gtest_color=no,)
else
FLUTTER_TFLAGS =
KOTLIN_TFLAGS =
NATIVE_TFLAGS =
endif

.PHONY: help format fix analyze test \
        test-android test-ios test-macos test-windows test-linux \
        gen aio

# Internal targets
.PHONY: _test-dart _test-kotlin _test-native

help:
	@echo "native_natural_sort — automation entrypoints"
	$(BLANK_LINE)
	@echo "  help            Show this help"
	@echo "  format          Format Dart sources under lib/ and test/"
	@echo "  fix             Apply Dart fixes then format"
	@echo "  analyze         Run Dart static analysis"
	@echo "  gen             Regenerate Pigeon platform-channel code"
	@echo "  test            Dart + Kotlin + native unit tests"
	@echo "                  (make test CI=1 for CI-friendly output)"
	@echo "  aio             gen → format → fix → analyze → gen → test"
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
	@$(DART) run pigeon --input pigeons/collation_android.dart
	@$(DART) run pigeon --input pigeons/collation_ios.dart
	@$(DART) run pigeon --input pigeons/collation_macos.dart
	@$(DART) run pigeon --input pigeons/collation_windows.dart

aio: gen format fix analyze gen test

_test-dart:
	@echo "=== Dart tests ==="
	@$(FLUTTER) test $(FLUTTER_TFLAGS)

_test-kotlin:
	@echo "=== Kotlin unit tests (JVM, no device) ==="
	@cd $(ANDROID_DIR) && $(GRADLEW) $(ANDROID_TEST_TASK) $(KOTLIN_TFLAGS)

_test-native:
ifeq ($(OS),Windows_NT)
	@echo "=== Windows C++ tests ==="
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build windows --debug
	@cd $(EXAMPLE_DIR)/build/windows/x64/debug/plugins/$(PROJECT_NAME) \
		&& $(PROJECT_NAME)_test.exe $(NATIVE_TFLAGS)
else
	@UNAME_S=$$(uname -s); \
	if [ "$$UNAME_S" = "Linux" ]; then \
		echo "=== Linux C++ tests ==="; \
		cd $(EXAMPLE_DIR) && $(FLUTTER) build linux --debug && \
		cd build/linux/x64/debug/plugins/$(PROJECT_NAME) \
			&& ctest --output-on-failure $(NATIVE_TFLAGS); \
	else \
		echo "=== no platform-native tests for $$UNAME_S, skipping ==="; \
	fi
endif

test:
	@$(SUBMAKE) _test-dart
	@$(BLANK_LINE)
	@$(SUBMAKE) _test-kotlin
	@$(BLANK_LINE)
	@$(SUBMAKE) _test-native

# Kotlin unit tests + Android integration tests + Flutter integration tests.
test-android:
	@$(SUBMAKE) _test-kotlin
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

# Windows C++ Google Test (standalone).
test-windows:
	@$(SUBMAKE) _test-native

# Linux C++ Google Test (standalone).
test-linux:
	@$(SUBMAKE) _test-native
