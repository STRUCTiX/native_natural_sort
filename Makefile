.DEFAULT_GOAL := help
SUBMAKE := $(MAKE) --no-print-directory

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
FVM_FLUTTER_SDK := $(wildcard $(CURDIR)\.fvm\flutter_sdk)
LOCAL_FLUTTER := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)\bin\flutter.bat,flutter.bat)
LOCAL_DART := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)\bin\dart.bat,dart.bat)
FLUTTER := $(LOCAL_FLUTTER)
DART := $(LOCAL_DART)
FLUTTER_BIN_DIR := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)\bin,)
BLANK_LINE := @echo.
GRADLEW := gradlew.bat
PATH_SEP := ;
else
SHELL := /bin/bash
FVM_FLUTTER_SDK := $(wildcard $(CURDIR)/.fvm/flutter_sdk)
LOCAL_FLUTTER := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)/bin/flutter,flutter)
LOCAL_DART := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)/bin/dart,dart)
FLUTTER := $(LOCAL_FLUTTER)
DART := $(LOCAL_DART)
FLUTTER_BIN_DIR := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)/bin,)
BLANK_LINE := @echo
GRADLEW := ./gradlew
PATH_SEP := :
endif

PROJECT_NAME := native_natural_sort
EXAMPLE_DIR := example

ANDROID_DIR := $(EXAMPLE_DIR)/android
ANDROID_TEST_TASK := :$(PROJECT_NAME):testDebugUnitTest

# Test mode flags
#   make test                    → human-readable (default)
#   make test CI=1               → CI-friendly (GitHub reporter)
#   make test CI=1 MACHINE_OUT=<file> → machine-readable JSON for test reporting
CI ?= 0

# Device ID for integration tests (optional, e.g. DEVICE=macos).
DEVICE ?=

ifeq ($(CI),1)
KOTLIN_TFLAGS = --console=plain
NATIVE_TFLAGS = $(if $(filter Windows_NT,$(OS)),--gtest_color=no,)
else
KOTLIN_TFLAGS =
NATIVE_TFLAGS =
endif

# Machine-readable output for CI test reporting.
# When set, dart/web/integration tests produce JSON via --machine instead
# of --reporter=github and write the stream to this file.
MACHINE_OUT ?=

# When set, native tests produce JUnit XML in this directory.
# Linux:  ctest --output-junit $(CURDIR)/$(dir)/native_test_linux.xml
# Windows: the test .exe receives --gtest_output=xml:$(CURDIR)/$(dir)/native_test_windows.xml
NATIVE_XML_DIR ?=

.PHONY: help format fix analyze test test-web \
        test-integration test-integration-no-device test-all \
        test-kotlin test-linux test-windows \
        gen aio aio-all

# Internal targets
.PHONY: _test-dart

help:
	@echo "native_natural_sort — automation entrypoints"
	$(BLANK_LINE)
	@echo "  help            Show this help"
	@echo "  format          Format Dart sources under lib/ and test/"
	@echo "  fix             Apply Dart fixes then format"
	@echo "  analyze         Run Dart static analysis"
	@echo "  gen             Regenerate Pigeon platform-channel code"
	@echo "  sync-version    Sync version from pubspec.yaml to ios/macos podspecs"
	@echo "  test            Dart unit tests (Flutter only)"
	@echo "  test-web        Dart unit tests on web (Flutter, --platform chrome)"
	@echo "                  (make test CI=1 for CI-friendly output)"
	@echo "  aio             gen → format → fix → analyze → gen → test"
	$(BLANK_LINE)
	@echo "Per-platform tests:"
	@echo "  test-kotlin     Kotlin unit tests (JVM, no device)"
	@echo "  test-linux      Linux C++ native tests"
	@echo "  test-windows    Windows C++ native tests"
	@echo "  test-all        Dart + Kotlin + native unit tests (no integration)"
	@echo "  aio-all         gen → format → fix → analyze → gen → test-all"
	$(BLANK_LINE)
	@echo "Integration tests (require device, pass DEVICE=<id> to select):"
	@echo "  test-integration / test-integration-no-device Flutter integration tests"

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

sync-version:
	@VERSION=$$($(DART) run tool/sync_version.dart); \
	echo "Synced podspec versions to $$VERSION"

aio: gen format fix analyze gen test

aio-all: gen format fix analyze gen test-all

_test-dart:
	@echo "=== Dart tests ==="
ifneq ($(MACHINE_OUT),)
	@$(FLUTTER) test --machine > $(MACHINE_OUT)
else ifeq ($(CI),1)
	@$(FLUTTER) test --reporter github
else
	@$(FLUTTER) test
endif

test-kotlin:
	@echo "=== Kotlin unit tests (JVM, no device) ==="
	@cd $(ANDROID_DIR) && PATH="$(FLUTTER_BIN_DIR)$(PATH_SEP)$$PATH" $(GRADLEW) $(ANDROID_TEST_TASK) $(KOTLIN_TFLAGS)

test-linux:
	@echo "=== Linux C++ tests ==="
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build linux --debug && \
		ARCH=$$(uname -m); \
		case "$$ARCH" in \
			x86_64) BUILD_ARCH=x64 ;; \
			aarch64) BUILD_ARCH=arm64 ;; \
			*) echo "ERROR: unsupported architecture $$ARCH"; exit 1 ;; \
		esac; \
		cd build/linux/$$BUILD_ARCH/debug/plugins/$(PROJECT_NAME) \
			&& ctest --output-on-failure $(NATIVE_TFLAGS) \
				$(if $(NATIVE_XML_DIR),--output-junit $(CURDIR)/$(NATIVE_XML_DIR)/native_test_linux.xml,)

test-windows:
	@echo "=== Windows C++ tests ==="
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build windows --debug
	@cd $(EXAMPLE_DIR)/build/windows/x64/plugins/$(PROJECT_NAME)/Debug \
		&& $(PROJECT_NAME)_test.exe $(NATIVE_TFLAGS) \
			$(if $(NATIVE_XML_DIR),--gtest_output=xml:$(CURDIR)/$(NATIVE_XML_DIR)/native_test_windows.xml,)

test:
	@$(SUBMAKE) _test-dart

test-web:
	@echo "=== Dart web tests ==="
ifneq ($(MACHINE_OUT),)
	@$(FLUTTER) test --platform chrome test/web --machine > $(MACHINE_OUT)
else ifeq ($(CI),1)
	@$(FLUTTER) test --platform chrome test/web --reporter github
else
	@$(FLUTTER) test --platform chrome test/web
endif

test-all:
	@$(SUBMAKE) _test-dart
	@$(BLANK_LINE)
	@$(SUBMAKE) test-web
	@$(BLANK_LINE)
	@$(SUBMAKE) test-kotlin
	@$(BLANK_LINE)
ifeq ($(OS),Windows_NT)
	@$(SUBMAKE) test-windows
else
	@UNAME_S=$$(uname -s); \
	if [ "$$UNAME_S" = "Linux" ]; then \
		$(SUBMAKE) test-linux; \
	else \
		echo "=== no platform-native tests for $$UNAME_S, skipping ==="; \
	fi
endif

test-integration:
ifeq ($(CI),1)
ifeq ($(DEVICE),)
	@echo "ERROR: CI mode requires DEVICE="
	@exit 1
endif
endif
ifeq ($(DEVICE),)
ifeq ($(OS),Windows_NT)
	@$(SUBMAKE) _test-integration DEVICE=windows
else
	@UNAME_S=$$(uname -s); \
	case "$$UNAME_S" in \
		Linux)  $(SUBMAKE) _test-integration DEVICE=linux ;; \
		Darwin) $(SUBMAKE) _test-integration DEVICE=macos ;; \
		*)      $(SUBMAKE) _test-integration ;; \
	esac
endif
else
	@$(SUBMAKE) _test-integration DEVICE=$(DEVICE)
endif

test-integration-no-device:
	@$(SUBMAKE) _test-integration

_test-integration:
ifneq ($(MACHINE_OUT),)
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test integration_test \
		$(if $(DEVICE),-d $(DEVICE),) --machine > $(MACHINE_OUT)
else ifeq ($(CI),1)
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test integration_test \
		$(if $(DEVICE),-d $(DEVICE),) --reporter github
else
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test integration_test \
		$(if $(DEVICE),-d $(DEVICE),)
endif

# test-integration is always run standalone; test-all no longer chains it.
