#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <string>
#include <variant>

#include "app_permissions_plugin.h"

namespace app_permissions {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

TEST(AppPermissionsPlugin, IsAccessibilityGranted) {
  AppPermissionsPlugin plugin;
  // Save the reply value from the success callback.
  bool result = false;
  plugin.HandleMethodCall(
      MethodCall("isAccessibilityGranted", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&result](const EncodableValue* success_result) {
            result = std::get<bool>(*success_result);
          },
          nullptr, nullptr));

  EXPECT_TRUE(result);
}

}  // namespace test
}  // namespace app_permissions
