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
PLATFORM_CONFIG := ${SDK_PLATFORM}
#
# APP_DIR - Defined as the path to the application directory where the
# application specific settings are defined
#
SOURCE_DIR = $(APP_DIR)/src
MDEF_FILE = $(APP_DIR)/prj.mdef
KERNEL_TYPE = micro
CONF_FILE = $(APP_DIR)/prj_$(ARCH).conf
ZEPHYR_BASE := $(PROJECT_ROOT)/rocket_kernel
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

