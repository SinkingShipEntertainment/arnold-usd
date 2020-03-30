// Copyright 2019 Luma Pictures
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Modifications Copyright 2019 Autodesk, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
/// @file nodes.h
///
/// Interfaces for Arnold nodes used by the Render Delegate.
#pragma once

#include <pxr/pxr.h>

#include <pxr/base/tf/token.h>

#include <ai.h>

#include <functional>
#include <unordered_map>
#include <vector>

PXR_NAMESPACE_OPEN_SCOPE

/// Installs Arnold nodes that are used by the Render Delegate.
void hdArnoldInstallNodes();

/// Uninstalls Arnold nodes that are used by the Render Delegate.
void hdArnoldUninstallNodes();

PXR_NAMESPACE_CLOSE_SCOPE
