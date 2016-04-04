#
# Copyright (c) 2015-2016 Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (c) 2015, Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#########################################################################
# Description:
#   This file defines settings the SDK build process uses which are
#   specific to the Rocket kernel.
#########################################################################


# These environment variables are defined externally by the SDK
#
ARCH := ${SDK_ARCH}
BOARD := ${SDK_PLATFORM}
#
# APP_DIR - Defined as the path to the application directory where the
# application specific settings are defined
#

# Architecture-specific configuration defaults set up for the SDK
ARCH_CONF_FILE ?= $(wildcard ${PROJECT_ROOT}/rocket_kernel/config/arch/$(ARCH).conf)

# Board-specific configuration defaults set up for the SDK
BOARD_CONF_FILE ?= $(wildcard ${PROJECT_ROOT}/rocket_kernel/config/board/$(BOARD).conf)

# Board-specific debug options (E.g. enable gdb)
DEBUG_BOARD_CONF_FILE ?= $(wildcard ${PROJECT_ROOT}/rocket_kernel/config/board/debug_$(BOARD).conf)

# Configuration setting can be overwritten by various files found in the application directory
# For example: x86.conf, prj_x86.conf, galileo.conf, prj_galileo.conf, debug_galileo.conf

APP_ARCH_CONF_FILE ?= $(wildcard $(APP_DIR)/$(ARCH).conf $(APP_DIR)/prj_$(ARCH).conf)
APP_BOARD_CONF_FILE ?= $(wildcard $(APP_DIR)/$(BOARD).conf $(APP_DIR)/prj_$(BOARD).conf)
APP_DEBUG_BOARD_CONF_FILE ?= $(wildcard $(APP_DIR)/debug_$(BOARD).conf)
APP_CONF_FILE ?= $(wildcard $(APP_DIR)/app.conf)

# This variable specifies the list of conf files which get processed by kconfig. The order
# matters here! Application config files are last to allow them to override settings
# made by earlier conf files. And app.conf is absolutely last.

CONF_FILE = $(ARCH_CONF_FILE) $(BOARD_CONF_FILE) $(DEBUG_BOARD_CONF_FILE) \
	  $(APP_ARCH_CONF_FILE) $(APP_BOARD_CONF_FILE) $(APP_DEBUG_BOARD_CONF_FILE) \
	  $(APP_CONF_FILE)

SOURCE_DIR = $(APP_DIR)/src
MDEF_FILE = $(APP_DIR)/prj.mdef
KERNEL_TYPE = micro
ZEPHYR_BASE := $(PROJECT_ROOT)/rocket_kernel/zephyr
export ZEPHYR_BASE

all:

clean: clean_extra_common
	@make pristine

include ${ZEPHYR_BASE}/Makefile.inc

clean_extra_common:
	@if [ -d board ]; then \
		rm -rf board/; \
	fi
	@find ./ -name "*.o*" -exec rm {} \;
	@find ./ -name "*.a" -exec rm {} \;
	@find ./ -name "*.o.cmd" -exec rm {} \;
	@find ./ -name "*.a.cmd" -exec rm {} \;
